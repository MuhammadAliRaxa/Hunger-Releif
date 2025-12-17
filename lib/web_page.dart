
import 'package:flutter_inappwebview_quill/flutter_inappwebview_quill.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class WebPage extends StatefulWidget {
  const WebPage({super.key});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  PullToRefreshOptions options=PullToRefreshOptions(
    color: Colors.blue
  );
  bool pullToRefreshEnabled = true;


  @override
  void initState() {
    super.initState();

    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            options: options,
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
                URLRequest(url: Uri.parse("https://moxo.mk/")),
            pullToRefreshController: pullToRefreshController,
            initialOptions: InAppWebViewGroupOptions(
              ios: IOSInAppWebViewOptions(
                allowingReadAccessTo: Uri.parse("https://moxo.mk"),
              ),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              webViewController = controller;
            },
            onLoadStop: (controller, url) {
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