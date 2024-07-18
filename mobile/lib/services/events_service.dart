import 'dart:convert';
import 'package:eventflux/eventflux.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/models/defence.dart';
import 'package:mobile/models/liberation.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/utils/sse.dart';

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
  static const String eventsStreamUrl = '/events-stream';

  static String streamUrl =
      '${dotenv.get(APIService.baseUrlEnv)}$eventsStreamUrl';

  static Future<Events> getEvents() async {
    final dio = APIService.getDio();

    final eventsRequest = await dio.get(eventsUrl);
    final eventsData = eventsRequest.data as Map<String, dynamic>;

    return dataToEvents(eventsData);
  }

  static EventFlux getEventsStream({
    required Function(Events) onSuccess,
    required Function(EventFluxException) onError,
    Function()? onClose,
  }) {
    return newStream(
      url: streamUrl,
      onSuccess: (planets) {
        final events = dataToEvents(jsonDecode(planets.data));

        onSuccess(events);
      },
      onError: onError,
      onClose: onClose,
    );
  }

  static Events dataToEvents(Map<String, dynamic> data) {
    final events = Events();

    data.forEach((key, items) {
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
