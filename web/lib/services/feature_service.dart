import 'dart:developer';

import 'package:app/models/feature.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class FeaturesService {
  static const String featuresUrl = '/features';

  static String url = '${dotenv.get(APIService.baseUrlEnv)}$featuresUrl';

  static Future<List<Feature>> getFeatures() async {
    var dio = APIService.getDio();
    var features = await dio.get(featuresUrl);
    var featuresData = features.data as List<dynamic>;

    return [...featuresData.map((feature) => Feature.fromJson(feature))];
  }

  static Future<void> toggleFeature(Feature feature) async {
    var dio = APIService.getDio();

    try {
      await dio.patch('$featuresUrl/${feature.code}', data: {
        'enabled': !feature.enabled,
      });
    } catch (e) {
      log('Error: $e');
    }
  }
}
