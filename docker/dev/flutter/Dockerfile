FROM ghcr.io/cirruslabs/flutter:3.19.6

WORKDIR /app

COPY /mobile .

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    clang \
    cmake \
    libgtk-3-dev \
    ninja-build \
    pkg-config \
    && apt-get clean

RUN flutter pub get

RUN adb devices

CMD tail -f /dev/null
