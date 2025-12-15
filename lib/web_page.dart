import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';


class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final GlobalKey webViewKey = GlobalKey();
  
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    javaScriptEnabled: true,
    javaScriptCanOpenWindowsAutomatically: true,
    useOnDownloadStart: true,
    useOnLoadResource: true,
    useShouldInterceptAjaxRequest: true,
    useShouldInterceptFetchRequest: true,
  );

  PullToRefreshController? pullToRefreshController;
  String url = '';
  double progress = 0;
  bool isSecure = false;
  String pageTitle = '';

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Theme.of(context).platform == TargetPlatform.android) {
          webViewController?.reload();
        } else if (Theme.of(context).platform == TargetPlatform.iOS) {
          webViewController?.loadUrl(
            urlRequest: URLRequest(url: await webViewController?.getUrl()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if(webViewController!=null){
          if(await webViewController!.canGoBack()){
            await webViewController!.goBack();
          }
        }
      },
      child: Scaffold(
        
        body: SafeArea(
          child: Column(
            children: [
              if (progress < 1.0)
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                ),
              Expanded(
                child: InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(
                    url: WebUri('https://moxo.mk'),
                  ),
                  initialSettings: settings,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      isSecure = url?.scheme == 'https';
                    });
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController?.endRefreshing();
                    setState(() {
                      this.url = url.toString();
                    });
                    
                    final title = await controller.getTitle();
                    setState(() {
                      pageTitle = title ?? '';
                    });
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController?.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, isReload) {
                    setState(() {
                      this.url = url.toString();
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print('Console: ${consoleMessage.message}');
                  },
                  onDownloadStartRequest: (controller, request) async {
                    print('Download started: ${request.url}');
                    // Handle download here
                  },
                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                    final uri = navigationAction.request.url;
                    
                    // Block specific URLs (example)
                    if (uri != null && uri.host.contains('example.com')) {
                      return NavigationActionPolicy.CANCEL;
                    }
                    
                    return NavigationActionPolicy.ALLOW;
                  },
                  onReceivedError: (controller, request, error) {
                    pullToRefreshController?.endRefreshing();
                  },
                  onReceivedHttpError: (controller, request, errorResponse) {
                    pullToRefreshController?.endRefreshing();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}