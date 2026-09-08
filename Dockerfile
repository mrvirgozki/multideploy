# Multi-stage build: kumuha lang ng xray binary
FROM teddysun/xray:latest AS xray-get

# Base sa official Envoy image
FROM envoyproxy/envoy:v1.31.0

# Kopyahin ang Xray executable
COPY --from=xray-get /usr/bin/xray /usr/local/bin/xray

# Kopyahin ang config files
COPY config.json /etc/xray/config.json
COPY envoy.yaml /etc/envoy/envoy.yaml

# ✅ Dagdag: kumuha ng netcat para sa health check
RUN apt-get update && apt-get install -y netcat-openbsd && rm -rf /var/lib/apt/lists/*

# I-open ang port
EXPOSE 8080

# ✅ Fixed startup: HINDI matutuloy hanggang ready na ang Xray
CMD ["/bin/sh", "-c", "\
  set -e; \
  echo '🔍 Checking Xray config...' && xray test -c /etc/xray/config.json; \
  echo '🚀 Starting Xray in background...' && xray run -c /etc/xray/config.json & \
  XRAY_PID=$!; \
  \
  # ✅ Hihintayin talagang bukas ang lahat ng port ng Xray
  echo '⏳ Waiting for Xray to be ready...'; \
  for PORT in 10001 10002 10003 10004; do \
    until nc -z 127.0.0.1 $PORT; do \
      sleep 0.5; \
    done; \
  done; \
  echo '✅ Xray is ready!'; \
  \
  echo '🚀 Starting Envoy...' && exec envoy -c /etc/envoy/envoy.yaml --log-level info; \
  \
  # ✅ Kung namatay ang Xray, patayin na rin ang container
  wait $XRAY_PID || exit 1; \
"]
