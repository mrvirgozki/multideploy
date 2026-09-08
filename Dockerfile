# Multi-stage build: kumuha lang ng xray binary
FROM teddysun/xray:latest AS xray-get

# Base sa official Envoy image
FROM envoyproxy/envoy:v1.31.0

# Kopyahin ang Xray executable
COPY --from=xray-get /usr/bin/xray /usr/local/bin/xray

# Kopyahin ang config files
COPY config.json /etc/xray/config.json
COPY envoy.yaml /etc/envoy/envoy.yaml

# I-open ang port
EXPOSE 8080

# ✅ Fixed startup: hindi na nagfa-fail kung matagal magsimula
CMD ["/bin/sh", "-c", "\
  echo 'Starting Xray...' && \
  xray run -c /etc/xray/config.json & \
  sleep 5 && \
  echo 'Starting Envoy...' && \
  exec envoy -c /etc/envoy/envoy.yaml --log-level warn \
"]
