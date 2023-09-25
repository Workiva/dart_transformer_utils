FROM drydock-prod.workiva.net/workiva/dart2_base_image:0.0.0-dart2.18.7gha3
WORKDIR /build/
COPY . /build
RUN dart pub get
RUN dart run dependency_validator
FROM scratch
