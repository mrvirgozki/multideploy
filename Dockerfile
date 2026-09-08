FROM teddysun/xray:latest AS xray-get
FROM envoyproxy/envoy:v1.31.0

COPY --from=xray-get /usr/bin/xray /usr/local/bin/xray
COPY config.json /etc/xray/config.json
COPY envoy.yaml /etc/envoy/envoy.yaml

EXPOSE 8080

# ✅ FIXED: Mas mahabang paghihintay, siguradong tuloy na si Xray bago si Envoy
CMD ["/bin/sh", "-c", "\
  echo 'Starting Xray...' && \
  xray run -c /etc/xray/config.json & \
  XRAY_PID=$! && \
  echo 'Waiting 10s for Xray to initialize...' && \
  sleep 10 && \
  echo 'Starting Envoy...' && \
  exec envoy -c /etc/envoy/envoy.yaml --log-level warn & \
  ENVOY_PID=$! && \
  wait $ENVOY_PID \
"]

