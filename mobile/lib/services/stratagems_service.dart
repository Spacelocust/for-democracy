import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/models/stratagem.dart';
import 'package:mobile/services/api_service.dart';

abstract class StratagemsService {
  static const String stratagemsUrl = '/stratagems';

  static String url = '${dotenv.get(APIService.baseUrlEnv)}$stratagemsUrl';

  static Future<List<Stratagem>> getStratagems() async {
    var dio = APIService.getDio();
    var stratagems = await dio.get(stratagemsUrl);
    var stratagemsData = stratagems.data as List<dynamic>;

    return stratagemsData
        .map((stratagem) => Stratagem.fromJson(stratagem))
        .toList();
  }
}
