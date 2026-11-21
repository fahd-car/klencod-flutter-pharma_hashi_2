import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF050B1A),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF050B1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PharmaHashiApp());
}

class PharmaHashiApp extends StatelessWidget {
  const PharmaHashiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'فارماء حاشي | دليل الأدوية',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050B1A),
        useMaterial3: true,
      ),
      home: const PharmaWebViewPage(),
    );
  }
}

class PharmaWebViewPage extends StatefulWidget {
  const PharmaWebViewPage({super.key});

  @override
  State<PharmaWebViewPage> createState() => _PharmaWebViewPageState();
}

class _PharmaWebViewPageState extends State<PharmaWebViewPage> {
  late final WebViewController _controller;
  double _progress = 0.0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF050B1A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (!mounted) return;
            setState(() {
              _progress = progress / 100.0;
            });
          },
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() {
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              _progress = 1.0;
            });
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame ?? true) {
              if (!mounted) return;
              setState(() {
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadFlutterAsset('assets/index.html');
  }

  void _reloadPage() {
    setState(() {
      _hasError = false;
      _progress = 0.0;
    });
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF050B1A),
        body: SafeArea(
          child: Stack(
            children: [
              if (!_hasError)
                WebViewWidget(controller: _controller)
              else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 56,
                          color: Color(0xFF5FB4FF),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'تعذّر تحميل واجهة التطبيق',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'تأكد من وجود ملف assets/index.html وإعادة المحاولة.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFA8C6E8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _reloadPage,
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_progress < 1.0 && !_hasError)
                LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFD4AF37),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
