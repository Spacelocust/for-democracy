import 'package:app/models/defence.dart';
import 'package:app/models/liberation.dart';
import 'package:app/services/api_service.dart';

class Events {
  List<Defence> defences = [];

  List<Liberation> liberations = [];

  void addLiberation(Liberation liberation) {
    liberations.add(liberation);
  }

  void addDefence(Defence defence) {
    defences.add(defence);
  }
}

abstract class EventsService {
  static const String eventsUrl = '/events';

  static Future<Events> getEvents() async {
    final dio = APIService.getDio();

    final eventsRequest = await dio.get(eventsUrl);
    final eventsData = eventsRequest.data as Map<String, dynamic>;

    final events = Events();

    eventsData.forEach((key, items) {
      if (key == 'defences') {
        for (var item in items) {
          events.addDefence(Defence.fromJson(item));
        }
      } else if (key == 'liberations') {
        for (var item in items) {
          events.addLiberation(Liberation.fromJson(item));
        }
      }
    });

    return events;
  }
}
