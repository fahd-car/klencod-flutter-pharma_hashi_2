import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // لإخفاء شريط التصحيح
      title: 'فارماء حاشي',
      home: WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    // إعداد متحكم WebView
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // تفعيل الجافاسكريبت (ضروري ليعمل Firebase والبحث)
      ..setBackgroundColor(const Color(0xFF050b1a)) // وضع لون خلفية داكن يطابق تطبيقك
      ..loadFlutterAsset('assets/index.html'); // تحميل ملف الـ HTML الخاص بك
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // WebViewWidget هو الذي سيعرض تطبيقك HTML
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}