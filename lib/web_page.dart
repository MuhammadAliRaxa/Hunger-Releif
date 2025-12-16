
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebPage extends StatefulWidget {
  const WebPage({super.key});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  bool _isWebViewReady = false; // IMPORTANT: Add this
  
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    cacheEnabled: true,
    clearCache: false,
    hardwareAcceleration: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    allowsAirPlayForMediaPlayback: true,
    geolocationEnabled: true,
    allowContentAccess: true,
    supportMultipleWindows: true,
    javaScriptCanOpenWindowsAutomatically: true,
    javaScriptEnabled: true,
    // REMOVED: limitsNavigationsToAppBoundDomains: true,
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
    cacheMode: CacheMode.LOAD_DEFAULT,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    useOnLoadResource: false,
    useShouldInterceptAjaxRequest: false,
    useShouldInterceptFetchRequest: false,
  );

  PullToRefreshController? pullToRefreshController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    
    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(color: Colors.blue),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                    urlRequest: URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
    
    // CRITICAL: Delay WebView initialization for iOS 18+
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isWebViewReady = true;
        });
      }
    });
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
              if (_isWebViewReady)
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(url: WebUri("https://moxo.mk/")),
                  initialSettings: settings,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    if (mounted) setState(() => isLoading = true);
                  },
                  onLoadStop: (controller, url) {
                    if (mounted) setState(() => isLoading = false);
                    pullToRefreshController?.endRefreshing();
                  },
                  onReceivedError: (controller, request, error) {
                    if (mounted) setState(() => isLoading = false);
                    pullToRefreshController?.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      if (mounted) setState(() => isLoading = false);
                      pullToRefreshController?.endRefreshing();
                    }
                  },
                ),
              
              if (isLoading || !_isWebViewReady)
                Container(
                  color: Colors.white,
                  child: const Center(
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