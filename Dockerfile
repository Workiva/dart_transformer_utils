FROM drydock-prod.workiva.net/workiva/dart2_base_image:1
WORKDIR /build/
COPY . /build
RUN dart pub get
RUN dart run dependency_validator
FROM scratch
