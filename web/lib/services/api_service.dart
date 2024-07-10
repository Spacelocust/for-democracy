import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class APIService {
  static const String baseUrlEnv = 'API_BASE_URL';

  // KONO DIO DA!
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.get(baseUrlEnv),
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  static Dio getDio() {
    return _dio;
  }
}
