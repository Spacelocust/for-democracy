import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class APIService {
  static const String baseUrlEnv = 'API_BASE_URL';

  static bool _adapterInitialized = false;

  // KONO DIO DA!
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.get(baseUrlEnv),
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  static Dio getDio() {
    if (_adapterInitialized) {
      return _dio;
    }

    var adapter = BrowserHttpClientAdapter();

    adapter.withCredentials = true;
    _dio.httpClientAdapter = adapter;
    _adapterInitialized = true;

    return _dio;
  }
}
