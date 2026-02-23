import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

const String websiteUrl = "https://speed-speed-4380--tmldevorg.sandbox.my.site.com/TMLDealershipPortal";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebWrapper(),
    );
  }
}

class WebWrapper extends StatefulWidget {
  const WebWrapper({super.key});

  @override
  State<WebWrapper> createState() => _WebWrapperState();
}

class _WebWrapperState extends State<WebWrapper> {
  InAppWebViewController? _controller;
  late PullToRefreshController _pullToRefreshController;

  bool isLoading = true;
  bool isConnected = true;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.blue, 
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );

    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        isConnected = result != ConnectivityResult.none;
      });
    });

    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (_controller != null) {
          await _controller!.reload();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isConnected) {
      return const Scaffold(
        body: Center(child: Text("No Internet Connection")),
      );
    }

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          if (_controller != null && await _controller!.canGoBack()) {
            _controller!.goBack();
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest:
                      URLRequest(url: WebUri.uri(Uri.parse(websiteUrl))),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    useHybridComposition: true,
                  ),
                  pullToRefreshController: _pullToRefreshController,
                  onWebViewCreated: (controller) {
                    _controller = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() => isLoading = true);
                  },
                  onLoadStop: (controller, url) async {
                    _pullToRefreshController.endRefreshing();
                    setState(() => isLoading = false);
                  },
                ),

                // if (isLoading)
                //   const Center(
                //     child: CircularProgressIndicator(
                //       color: Colors.blue,
                //     ),
                //   ),
              ],
            ),
          ),
        ),
      );
  }
}