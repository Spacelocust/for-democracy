import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/services/token_service.dart';

abstract class APIService {
  static const String baseUrlEnv = 'API_BASE_URL';

  // KONO DIO DA!
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.get(baseUrlEnv),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
    ),
  )..interceptors.add(interceptorCookie());

  static Dio getDio() {
    return _dio;
  }
}

InterceptorsWrapper interceptorCookie() {
  return InterceptorsWrapper(
    onRequest: (options, handler) async {
      var token = await TokenService().getToken();

      if (token != null) {
        options.headers['cookie'] = Cookie("token", token).toString();
      }

      return handler.next(options);
    },
    onResponse: (response, handler) {
      return handler.next(response);
    },
    onError: (e, handler) async {
      if (e.response != null) {
        if (e.response!.statusCode == 401 &&
            e.response!.data!["error"] != null) {
          if (e.response!.data!["error"].contains('expired token') ||
              e.response!.data!["error"].contains('invalid token')) {
            await TokenService().deleteToken();
          }
        }
      }
      // Do something with response error
      return handler.next(e); //continue
    },
  );
}
