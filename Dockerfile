FROM google/dart:2.5

WORKDIR /build/
COPY . /build
RUN timeout 5m pub get && pub run dependency_validator
ARG BUILD_ARTIFACTS_AUDIT=/build/pubspec.lock
FROM scratch
