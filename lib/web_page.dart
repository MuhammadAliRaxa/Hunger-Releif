
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebPage extends StatefulWidget {
  const WebPage({super.key});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  InAppWebViewController? webViewController;
  bool _canShowWebView = false;
  bool isLoading = true;
  PullToRefreshController? pullToRefreshController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    // Initialize pull to refresh first
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      pullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(
          color: Colors.blue
        ),
        onRefresh: () async {
          if (Platform.isAndroid) {
            webViewController?.reload();
          } else if (Platform.isIOS) {
            webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl())
            );
          }
        },
      );
    }

    // CRITICAL: Delay WebView creation to avoid iOS 18 crash
    await Future.delayed(Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() {
        _canShowWebView = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (webViewController != null) {
          if (await webViewController!.canGoBack()) {
            await webViewController!.goBack();
          } else {
            if (mounted) Navigator.pop(context, true);
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (_canShowWebView)
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url:Uri.parse("https://moxo.mk/")
                  ),
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  initialOptions: InAppWebViewGroupOptions(
                    ios: IOSInAppWebViewOptions(
                      isPagingEnabled: true
                    )
                  ),
                  onLoadStart: (controller, url) {
                    if (mounted) {
                      setState(() {
                        isLoading = true;
                      });
                    }
                  },
                  onLoadStop: (controller, url) {
                    if (mounted) {
                      setState(() {
                        isLoading = false;
                      });
                    }
                    pullToRefreshController?.endRefreshing();
                  },
                  // onReceivedError: (controller, request, error) {
                  //   if (mounted) {
                  //     setState(() {
                  //       isLoading = false;
                  //     });
                  //   }
                  //   pullToRefreshController?.endRefreshing();
                    
                  //   print("WebView Error: ${error.description}");
                  // },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                      pullToRefreshController?.endRefreshing();
                    }
                  },
                ),
              
              // Loading indicator
              if (isLoading || !_canShowWebView)
                Container(
                  color: Colors.white,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    webViewController = null;
    super.dispose();
  }
}