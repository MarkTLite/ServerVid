# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /api
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart compile exe bin/vid_api_server.dart -o bin/vid_api_server

# Build minimal serving image from AOT-compiled `/vid_api_server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /api/bin/vid_api_server /api/bin/

# Start server.
EXPOSE 8080
RUN dart run /api/bin/vid_api_server.dart
# CMD ["/api/bin/vid_api_server"]