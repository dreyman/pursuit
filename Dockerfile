FROM node:lts-slim AS webapp-build
COPY webapp webapp-src
WORKDIR /webapp-src
RUN npm ci
RUN npm run build
WORKDIR /
RUN mv webapp-src/build/ webapp-build

FROM amazoncorretto:24.0.1-alpine
COPY server /server-src
COPY engine /engine-src
RUN mkdir -p /deps
WORKDIR /deps
RUN wget https://ziglang.org/builds/zig-linux-$(uname -m)-0.15.0-dev.386+2e35fdd03.tar.xz
RUN tar xf zig-linux-$(uname -m)-0.15.0-dev.386+2e35fdd03.tar.xz
RUN mv zig-linux-$(uname -m)-0.15.0-dev.386+2e35fdd03/ local/
WORKDIR /engine-src
RUN /deps/local/zig build --release=safe

WORKDIR /
RUN mkdir -p server-build
WORKDIR /server-src
RUN ./gradlew build
RUN tar xf build/distributions/server-0.0.1-wip.tar -C /server-build
WORKDIR /server-build
COPY --from=webapp-build /webapp-build /server-build/webapp
RUN mv /engine-src/zig-out/lib/libpursuit.so .

VOLUME ["/appstorage"]
EXPOSE 7070

ENV JAVA_OPTS="--enable-native-access=ALL-UNNAMED"
ENTRYPOINT ["server-0.0.1-wip/bin/server", "/appstorage", "libpursuit.so"]
