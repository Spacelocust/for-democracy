FROM ghcr.io/cirruslabs/flutter:3.19.6

WORKDIR /app

COPY /mobile/pubspec.lock .
COPY /mobile/pubspec.yaml .

RUN adb devices

RUN flutter pub get

CMD tail -f /dev/null
