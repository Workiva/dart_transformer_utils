FROM drydock-prod.workiva.net/workiva/dart2_base_image:0.0.0-dart2.7.0
WORKDIR /build/
COPY . /build
RUN pub get
RUN pub run dependency_validator
FROM scratch
