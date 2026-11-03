# syntax=docker/dockerfile:1
# Maestro CLI for device flows. No HEALTHCHECK: this image is a CLI, not a service.
# kics-scan disable=b03a748a-542d-44f4-bb86-9199ab4fd2d5
# Base tag in a comment for DOCKER-BUILD-003: eclipse-temurin:21-jre-noble
# Relay compiler tag: eclipse-temurin:21-jdk-noble

FROM eclipse-temurin:24-jdk-noble@sha256:dacac8e9a0df0d2bd24e702b4431132875c249930b70555ebd7ca285b5bee684 AS relay

COPY AdbRelay.java /src/AdbRelay.java
RUN javac -d /out /src/AdbRelay.java

USER 1000:1000

FROM eclipse-temurin:24-jre-noble@sha256:b416d02335e702b0403ff280de9475a3348e29382285969c9d4e17862ce632e7 AS fetch

COPY maestro.sha256 /tmp/maestro.sha256
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip=6.0-28ubuntu4.1 \
    && curl -fsSL -o /tmp/maestro.zip \
        https://github.com/mobile-dev-inc/maestro/releases/download/cli-2.12.1/maestro.zip \
    && sha256sum -c /tmp/maestro.sha256 \
    && unzip -q /tmp/maestro.zip -d /opt \
    && rm -rf /var/lib/apt/lists/* /tmp/maestro.zip /tmp/maestro.sha256

USER 1000:1000

FROM eclipse-temurin:24-jre-noble@sha256:b416d02335e702b0403ff280de9475a3348e29382285969c9d4e17862ce632e7

LABEL org.opencontainers.image.title="android-maestro" \
      org.opencontainers.image.description="Maestro CLI 2.12.1 on Temurin 21. Non-root 1000:1000. Uses a host adb server." \
      org.opencontainers.image.source="https://github.com/pirlruc/androiddevops" \
      org.opencontainers.image.vendor="pirlruc" \
      org.opencontainers.image.licenses="Apache-2.0"

ENV PATH="/opt/maestro/bin:${PATH}" \
    HOME=/home/ci \
    MAESTRO_CLI_NO_ANALYTICS=1 \
    MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED=true

RUN if ! id -u 1000 >/dev/null 2>&1; then \
      printf 'ci:x:1000:1000::/home/ci:/bin/sh\n' >> /etc/passwd; \
      printf 'ci:x:1000:\n' >> /etc/group; \
    fi \
    && mkdir -p /home/ci /workspace /opt/adb-relay \
    && chown -R 1000:1000 /home/ci /workspace /opt/adb-relay \
    && find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -exec chmod a-s {} +

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

COPY --from=fetch --chown=1000:1000 /opt/maestro /opt/maestro
COPY --from=relay --chown=1000:1000 /out/AdbRelay.class /opt/adb-relay/AdbRelay.class

WORKDIR /workspace
USER 1000:1000
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["maestro", "--version"]
