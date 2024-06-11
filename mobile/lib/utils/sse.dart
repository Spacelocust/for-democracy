import 'package:eventflux/eventflux.dart';

/// Create a new EventFlux stream.
EventFlux newStream({
  required String url,
  required Function onSuccess,
  Function(EventFluxException)? onError,
  Function()? onClose,
}) {
  return EventFlux.spawn()
    ..connect(
      EventFluxConnectionType.get,
      url,
      onSuccessCallback: (EventFluxResponse? response) {
        response?.stream?.listen((data) {
          onSuccess(data);
        });
      },
      onConnectionClose: onClose,
      onError: onError,
      autoReconnect: true,
      reconnectConfig: ReconnectConfig(
        mode: ReconnectMode.linear,
        interval: const Duration(seconds: 90),
        maxAttempts: 5,
        onReconnect: () {},
      ),
    );
}
