FROM cgr.dev/chainguard/wolfi-base:latest@sha256:f57d9086dc184b79093d4389ed8e31ca64102d04e4551103b07a7f6b78072e3b AS build

# renovate: datasource=github-releases depName=Prowlarr/Prowlarr
ARG PROWLARR_VERSION=v1.31.2.4975
# renovate: datasource=github-releases depName=openSUSE/catatonit
ARG CATATONIT_VERSION=v0.2.1

WORKDIR /rootfs

RUN apk add --no-cache \
        curl && \
    mkdir -p app/bin etc && \
    curl -fsSL "https://github.com/Prowlarr/Prowlarr/releases/download/${PROWLARR_VERSION}/Prowlarr.master.${PROWLARR_VERSION#v}.linux-core-x64.tar.gz" | \
    tar xvz --strip-components=1 --directory=app/bin && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[d4rkfella](https://github.com/d4rkfella)\n" "master" "${PROWLARR_VERSION}" > app/package_info && \
    rm -rf app/bin/Prowlarr.Update && \
    echo "prowlarr:x:65532:65532::/nonexistent:/sbin/nologin" > etc/passwd && \
    echo "prowlarr:x:65532:" > etc/group

FROM ghcr.io/d4rkfella/wolfi-dotnet-runtime-deps:1.0.0@sha256:f830c91c552c83c41e597517e91583d3b064a9efb9f29a94142084a20f201a0f

COPY --from=build /rootfs /

USER prowlarr:prowlarr

WORKDIR /app

VOLUME ["/config"]
EXPOSE 9696

ENV XDG_CONFIG_HOME=/config \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_EnableDiagnostics="0" \
    TZ="Etc/UTC" \
    UMASK="0002" 

ENTRYPOINT [ "catatonit", "--", "/app/bin/Prowlarr" ]
CMD [ "-nobrowser" ]

LABEL org.opencontainers.image.source="https://github.com/Prowlarr/Prowlarr"
