import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/splash_screen.dart';
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
  InAppWebViewSettings settings = InAppWebViewSettings(isInspectable: kDebugMode,mediaPlaybackRequiresUserGesture: false,allowsInlineMediaPlayback: true,allowsAirPlayForMediaPlayback: true,geolocationEnabled: true,
    allowContentAccess: true,
    supportMultipleWindows: true,  
    javaScriptCanOpenWindowsAutomatically: true,  
    limitsNavigationsToAppBoundDomains: true,
        javaScriptEnabled: true,
        userAgent: Platform.isAndroid?'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Mobile Safari/537.36':
        "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) "
          "AppleWebKit/605.1.15 (KHTML, like Gecko) "
          "Version/16.0 Mobile/15E148 Safari/604.1",
        cacheMode: CacheMode.LOAD_DEFAULT,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,);
  PullToRefreshController? pullToRefreshController;
  PullToRefreshSettings pullToRefreshSettings = PullToRefreshSettings(
    color: Colors.blue,
  );
  bool pullToRefreshEnabled = true;


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
        if(webViewController!=null){
          if(await webViewController!.canGoBack()){
            await webViewController!.goBack();
          }
        }
      },
      child: Scaffold(
          body: SafeArea(
            child: InAppWebView(
            key: webViewKey,
            initialUrlRequest:
                URLRequest(url: WebUri("https://moxo.mk/")),
            initialSettings: settings,
            pullToRefreshController: pullToRefreshController,
            onWebViewCreated: (InAppWebViewController controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) => showDialog(context: context, builder: (context) => Center(child: CircularProgressIndicator(),),),
            onLoadStop: (controller, url) {
              Navigator.pop(context);
              pullToRefreshController?.endRefreshing();
            },
            onReceivedError: (controller, request, error) {
              pullToRefreshController?.endRefreshing();
            },
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                pullToRefreshController?.endRefreshing();
              }
            },   
          ),
          )),
    );
  }
}
