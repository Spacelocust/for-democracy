import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class APIService {
  static const String baseUrlEnv = 'API_BASE_URL';
  static final cookieJar = CookieJar();

  // KONO DIO DA!
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.get(baseUrlEnv),
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  static Dio getDio() {
    return _dio;
  }

  static void prepareJar() {
    _dio.interceptors.add(CookieManager(cookieJar));
  }
}
