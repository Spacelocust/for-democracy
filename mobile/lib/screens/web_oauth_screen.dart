import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/oauth_service.dart';
import 'package:mobile/services/token_service.dart';
import 'package:mobile/states/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebOAuthScreen extends StatefulWidget {
  static const String steamOauthUrl = '/oauth/steam';

  static const String steamCallbackUrl = '/oauth/steam/callback';

  const WebOAuthScreen({super.key});

  @override
  State<WebOAuthScreen> createState() => _WebOAuthScreenState();
}

class _WebOAuthScreenState extends State<WebOAuthScreen> {
  late final WebViewController _controller;

  final cookieManager = WebviewCookieManager();

  final String baseUrl = dotenv.get(APIService.baseUrlEnv);

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
          onPageFinished: finishAuthentication,
          onHttpError: (HttpResponseError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
              ),
            );
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse('$baseUrl${WebOAuthScreen.steamOauthUrl}'));

    // Enable debugging and disable media playback requires user gesture for Android
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  /// Check if the URL contains the callback URL for Steam and finish the authentication process.
  void finishAuthentication(String url) async {
    // Check if the URL contains the callback URL for Steam
    // (this is the URL that the OAuth server will redirect to after authentication)
    if (url.contains(WebOAuthScreen.steamCallbackUrl)) {
      try {
        // Retrieve the token from the cookie of the WebView
        final token = await getCookie(url, "token");

        // Check if the token is not null
        if (token != null) {
          // Save the token to the secure storage
          await TokenService().setToken(token);

          // Retrieve the user information
          User user = await OAuthService.getMe();

          if (mounted) {
            // Set the user to the AuthState
            context.read<AuthState>().setUser(user);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to authenticate"),
            ),
          );
        }
      }

      // Clear the cookies of the WebView to prevent leaking the token
      await cookieManager.clearCookies();

      if (mounted) {
        // Close the modal after
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 1.3,
      child: WebViewWidget(controller: _controller),
    );
  }

  // Retrieve the cookie value from the WebView
  Future<String?> getCookie(String url, String name) async {
    // Retrieve the cookies from the WebView
    final cookies = await cookieManager.getCookies(url);

    // Find the cookie with the specified name
    final Cookie cookie = cookies.firstWhere(
      (cookie) => cookie.name == name,
      orElse: () => Cookie(name, ""),
    );

    return cookie.value.isEmpty ? null : cookie.value;
  }
}
