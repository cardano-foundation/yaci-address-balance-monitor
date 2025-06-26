ARG JDK_TAG=24.0.1_9-jre-ubi9-minimal
ARG JDK_BUILD_IMAGE=bellsoft/liberica-openjdk-alpine
ARG JDK_BUILD_TAG=21

FROM ${JDK_BUILD_IMAGE}:${JDK_BUILD_TAG} AS build
ARG YACI_STORE_GIT_REPO_URL=https://github.com/bloxbean/yaci-store.git
ARG YACI_STORE_GIT_REF=main
RUN apk add findutils git
WORKDIR /app
RUN git clone --depth 1 --branch ${YACI_STORE_GIT_REF} ${YACI_STORE_GIT_REPO_URL} /app
RUN ./gradlew clean build

FROM ${JDK_BUILD_IMAGE}:${JDK_BUILD_TAG} AS production
VOLUME /data
WORKDIR /app
RUN apk add --no-cache envsubst bash
COPY --from=build /app/applications/utxo-indexer/build/libs/yaci-store-utxo-indexer*.jar /app/yaci-store-utxo-indexer.jar
COPY --from=build /app/components/plugin-polyglot/build/libs/yaci-store-plugin-polyglot*.jar /app/plugins/yaci-store-plugin-polyglot.jar
COPY --from=build /app/components/plugin-polyglot/build/libs/plugin-libs/*.jar /app/plugins/lib/
COPY ./assets/bin/entrypoint /entrypoint
COPY ./config /app/config
COPY ./plugins /app/plugins
EXPOSE 8080
ENTRYPOINT ["/entrypoint"]
