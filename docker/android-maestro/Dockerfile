# syntax=docker/dockerfile:1
# Maestro CLI for device flows. No HEALTHCHECK: this image is a CLI, not a service.
# kics-scan disable=b03a748a-542d-44f4-bb86-9199ab4fd2d5
# Base tag in a comment for DOCKER-BUILD-003: eclipse-temurin:25-jre-noble
# Relay compiler tag: eclipse-temurin:25-jdk-noble

FROM eclipse-temurin:25-jdk-noble@sha256:95e350ad1eb738f943e141640f7e3d797e483359a3b33c3864255bfd1ad71f8a AS relay

COPY AdbRelay.java /src/AdbRelay.java
RUN javac -d /out /src/AdbRelay.java

USER 1000:1000

FROM eclipse-temurin:25-jre-noble@sha256:a98128a57de944a72bd31fbc79b898edd5a5864d3652071d5bbd2160ab7d7dce AS fetch

COPY maestro.sha256 /tmp/maestro.sha256
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         curl=8.5.0-2ubuntu10.16 \
         unzip=6.0-28ubuntu4.1 \
    && curl -fsSL -o /tmp/maestro.zip \
        https://github.com/mobile-dev-inc/maestro/releases/download/cli-2.12.1/maestro.zip \
    && sha256sum -c /tmp/maestro.sha256 \
    && unzip -q /tmp/maestro.zip -d /opt \
    && rm -rf /var/lib/apt/lists/* /tmp/maestro.zip /tmp/maestro.sha256

USER 1000:1000

FROM eclipse-temurin:25-jre-noble@sha256:a98128a57de944a72bd31fbc79b898edd5a5864d3652071d5bbd2160ab7d7dce

LABEL org.opencontainers.image.title="android-maestro" \
      org.opencontainers.image.description="Maestro CLI 2.12.1 on Temurin 25. Non-root 1000:1000. Uses a host adb server." \
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
