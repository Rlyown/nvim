FROM ubuntu:24.04 AS builder

ARG NVIM_VERSION=v0.12.4
ARG BUNDLE_VERSION=dev
ENV DEBIAN_FRONTEND=noninteractive
ENV XDG_CONFIG_HOME=/work/runtime/config
ENV XDG_DATA_HOME=/work/runtime/data
ENV XDG_STATE_HOME=/work/runtime/state
ENV XDG_CACHE_HOME=/work/runtime/cache
ENV PATH=/work/runtime/bin:/work/runtime/data/nvim/mason/bin:${PATH}

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl fd-find git nodejs npm python3 python3-pip ripgrep tar unzip xz-utils zstd \
    && rm -rf /var/lib/apt/lists/*

# Only needed while go.nvim and Mason prepare the bundled data. Project toolchains
# are deliberately excluded from the final archive.
RUN apt-get update && apt-get install -y --no-install-recommends golang-go \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" \
      -o /tmp/nvim.tar.gz \
    && mkdir -p /work/runtime/nvim \
    && tar -xzf /tmp/nvim.tar.gz --strip-components=1 -C /work/runtime/nvim \
    && rm /tmp/nvim.tar.gz

RUN mkdir -p /work/runtime/bin /work/runtime/lib \
    && cp /usr/bin/node /work/runtime/bin/node \
    && cp /usr/bin/rg /work/runtime/bin/rg \
    && cp /usr/bin/fdfind /work/runtime/bin/fd \
    && cp /usr/lib/x86_64-linux-gnu/libnode.so.* /work/runtime/lib/

COPY . /work/source
RUN mkdir -p /work/runtime/config /work/runtime/data /work/runtime/state /work/runtime/cache \
    && cp -a /work/source/. /work/runtime/config/nvim/ \
    && rm -rf /work/runtime/config/nvim/.git /work/runtime/config/nvim/.serena \
    && chmod +x /work/runtime/config/nvim/scripts/nvim-offline /work/runtime/config/nvim/scripts/nvim-offline-update \
    && /work/runtime/nvim/bin/nvim --headless "+Lazy! restore" +qa \
    && /work/runtime/nvim/bin/nvim --headless "+TSUpdateSync" +qa \
    && /work/runtime/nvim/bin/nvim --headless "+MasonToolsInstallSync" +qa

RUN mkdir -p /work/package/bin /work/package/runtime /work/package/backups /out \
    && cp -a /work/runtime/. /work/package/runtime/ \
    && cp /work/source/scripts/nvim-offline /work/package/bin/nvim-offline \
    && cp /work/source/scripts/nvim-offline-update /work/package/bin/nvim-offline-update \
    && chmod +x /work/package/bin/nvim-offline /work/package/bin/nvim-offline-update \
    && printf '{\n  "version": "%s",\n  "platform": "linux-x86_64-ubuntu-24.04",\n  "neovim": "%s"\n}\n' "$BUNDLE_VERSION" "$NVIM_VERSION" > /work/package/manifest.json \
    && tar --zstd -C /work/package -cf "/out/nvim-offline-linux-x86_64-${BUNDLE_VERSION}.tar.zst" . \
    && cd /out \
    && sha256sum "nvim-offline-linux-x86_64-${BUNDLE_VERSION}.tar.zst" > "nvim-offline-linux-x86_64-${BUNDLE_VERSION}.tar.zst.sha256"

FROM scratch AS bundle
COPY --from=builder /out/ /
