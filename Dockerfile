FROM drydock-prod.workiva.net/workiva/dart2_base_image:0.0.0-dart2.13.4
WORKDIR /build/
COPY . /build
RUN pub get
RUN pub run dependency_validator
FROM scratch
