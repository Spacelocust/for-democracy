import 'package:mobile/enum/feature.dart';
import 'package:mobile/services/api_service.dart';

abstract class FeatureService {
  static const String featuresUrl = '/features';

  static Future<List<Feature>> getFeature() async {
    var dio = APIService.getDio();
    var features = await dio.get(featuresUrl);
    var featuresData = features.data as List<dynamic>;

    return [...featuresData.map((feature) => feature.fromJson(feature))];
  }
}
