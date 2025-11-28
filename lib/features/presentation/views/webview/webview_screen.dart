import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../controllers/theme_controller.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/fonts.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<XThemeController>();

    return Scaffold(
      backgroundColor: themeController.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeController.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: themeController.textColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: themeController.textColor,
            fontSize: XSizes.textSizeLg,
            fontWeight: FontWeight.bold,
            fontFamily: XFonts.lexend,
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: themeController.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
