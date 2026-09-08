FROM teddysun/xray:latest AS xray-get
FROM envoyproxy/envoy:v1.31.0

COPY --from=xray-get /usr/bin/xray /usr/local/bin/xray
COPY config.json /etc/xray/config.json
COPY envoy.yaml /etc/envoy/envoy.yaml

EXPOSE 8080

RUN apt-get update && apt-get install -y --no-install-recommends tini && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/sh", "-c", "xray run -c /etc/xray/config.json & sleep 8 && envoy -c /etc/envoy/envoy.yaml --log-level warn"]
