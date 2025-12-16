
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';

class WebPage extends StatefulWidget {
  const WebPage({super.key});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    
    // Performance optimizations
    cacheEnabled: true,
    clearCache: false,
    hardwareAcceleration: true,
    
    // Media settings
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    allowsAirPlayForMediaPlayback: true,
    
    // Permission settings
    geolocationEnabled: true,
    allowContentAccess: true,
    
    // Multiple windows support
    supportMultipleWindows: true,
    javaScriptCanOpenWindowsAutomatically: true,
    
    // JavaScript
    javaScriptEnabled: true,
    
    // User agent
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
    
    // Cache and content
    cacheMode: CacheMode.LOAD_DEFAULT,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    
    // Disable resource-intensive callbacks
    useOnLoadResource: false,
    useShouldInterceptAjaxRequest: false,
    useShouldInterceptFetchRequest: false,
  );

  PullToRefreshController? pullToRefreshController;
  PullToRefreshSettings pullToRefreshSettings = PullToRefreshSettings(
    color: Colors.blue,
  );
  bool pullToRefreshEnabled = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: pullToRefreshSettings,
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
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
            Navigator.pop(context, true);
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: WebUri("https://moxo.mk/")),
                initialSettings: settings,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (InAppWebViewController controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    isLoading = true;
                  });
                },
                onLoadStop: (controller, url) {
                  setState(() {
                    isLoading = false;
                  });
                  pullToRefreshController?.endRefreshing();
                },
                onReceivedError: (controller, request, error) {
                  setState(() {
                    isLoading = false;
                  });
                  pullToRefreshController?.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    setState(() {
                      isLoading = false;
                    });
                    pullToRefreshController?.endRefreshing();
                  }
                },
              ),
              
              // Loading indicator overlay
              if (isLoading)
                Container(
                  color: Colors.white.withOpacity(0.1),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
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