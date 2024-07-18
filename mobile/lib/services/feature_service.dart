import 'package:mobile/models/feature.dart';
import 'package:mobile/services/api_service.dart';

abstract class FeatureService {
  static const String featuresUrl = '/features';

  static Future<List<Feature>> getFeature() async {
    var dio = APIService.getDio();
    var features = await dio.get(featuresUrl);
    var featuresData = features.data as List<dynamic>;

    return [...featuresData.map((feature) => feature.fromJson(feature))];
  }

  static Future<List<Feature>> getFeatures() async {
    var dio = APIService.getDio();
    var features = await dio.get(featuresUrl);
    var featuresData = features.data as List<dynamic>;

    return [...featuresData.map((feature) => Feature.fromJson(feature))];
  }
}
