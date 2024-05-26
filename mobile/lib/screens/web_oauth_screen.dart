import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/secure_storage_service.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebOauthScreen extends StatefulWidget {
  const WebOauthScreen({super.key});

  @override
  State<WebOauthScreen> createState() => _WebOauthScreenState();
}

class _WebOauthScreenState extends State<WebOauthScreen> {
  late final WebViewController _controller;
  final cookieManager = WebviewCookieManager();

  String baseUrl = dotenv.get(APIService.baseUrlEnv);
  String steamOauthUrl = '/oauth/steam';
  String steamCallbackUrl = '/oauth/steam/callback';

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    params = const PlatformWebViewControllerCreationParams();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setBackgroundColor(const Color(0xff171d25))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            if (url.contains(steamCallbackUrl)) {
              try {
                final value = await getCookie(url, "token");
                await storeToken(value);
              } catch (e) {
                log(e.toString());
              }

              await cookieManager.clearCookies();

              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          onHttpError: (HttpResponseError error) {
            log(error.toString());
          },
          onWebResourceError: (WebResourceError error) {
            log(error.toString());
          },
        ),
      )
      ..loadRequest(Uri.parse('$baseUrl$steamOauthUrl'));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 1.3,
      child: WebViewWidget(controller: _controller),
    );
  }

  // Retrieve the cookie value from the WebView
  Future<String> getCookie(String url, String name) async {
    final cookies = await cookieManager.getCookies(url);

    final Cookie cookie = cookies.firstWhere((cookie) => cookie.name == name);
    return cookie.value;
  }

  // Store the token in the secure storage
  Future<void> storeToken(String token) async {
    await SecureStorageService().writeSecureData("token", token);
  }
}
