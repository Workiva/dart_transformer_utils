FROM google/dart:2.1.0

WORKDIR /build/
COPY . /build
RUN timeout 5m pub get && pub run dependency_validator -i coverage,dart_style
ARG BUILD_ARTIFACTS_AUDIT=/build/pubspec.lock
FROM scratch
