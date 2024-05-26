import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:mobile/services/api_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebOauthScreen extends StatefulWidget {
  const WebOauthScreen({super.key});

  @override
  State<WebOauthScreen> createState() => _WebOauthScreenState();
}

class _WebOauthScreenState extends State<WebOauthScreen> {
  final controller = WebViewController();

  String baseUrl = dotenv.get(APIService.baseUrlEnv);

  @override
  void initState() {
    super.initState();

    controller
      ..setBackgroundColor(const Color(0xff171d25))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            if (url.contains('oauth/steam/callback')) {
              String? value = await getCookieValue();
              if (value != null) {
                log('Steam OAuth session_id: $value');
              }

              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse('$baseUrl/oauth/steam'));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 1.3,
      child: WebViewWidget(controller: controller),
    );
  }

  Future<String?> getCookieValue({name = 'session_key'}) async {
    final cookies = await controller.runJavaScript('document.cookie') as String;
    String? value;

    cookies.split(';').forEach((cookie) {
      if (cookie.contains(name)) {
        value = cookie.split('=')[1];
      }
    });

    return value;
  }
}
