FROM alpine:latest as tailscale
WORKDIR /app
ENV TSFILE=tailscale_1.36.0_amd64.tgz
RUN wget https://pkgs.tailscale.com/stable/${TSFILE} && \
  tar xzf ${TSFILE} --strip-components=1

FROM debian:bullseye-slim AS builder
RUN \
  apt-get update -y \
  && apt-get install -y \
    curl
WORKDIR /app
RUN curl -sSL https://router.apollo.dev/download/nix/latest | sh
RUN curl -sSL https://supergraph.demo.starstuff.dev/ > supergraph-schema.graphql

FROM debian:bullseye-slim
RUN apt-get update -y && apt-get install -y ca-certificates iptables
# ip6tables

COPY --from=tailscale /app/tailscaled /app/tailscaled
COPY --from=tailscale /app/tailscale /app/tailscale
COPY --from=builder /app/router /app/router
COPY --from=builder /app/supergraph-schema.graphql /app/supergraph-schema.graphql
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

COPY run.sh /app/run.sh
COPY router.yaml .
CMD ["/app/run.sh"]
