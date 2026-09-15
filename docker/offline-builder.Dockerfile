FROM ubuntu:24.04 AS builder

ARG NVIM_VERSION=v0.12.4
ARG BUNDLE_VERSION=dev
ARG CONFIG_PROFILE=minimal
ARG CONFIG_LANGUAGES=
ARG CONFIG_FEATURES=
ENV DEBIAN_FRONTEND=noninteractive
ENV XDG_CONFIG_HOME=/work/runtime/config
ENV XDG_DATA_HOME=/work/runtime/data
ENV XDG_STATE_HOME=/work/runtime/state
ENV XDG_CACHE_HOME=/work/runtime/cache
ENV PATH=/work/runtime/bin:/work/runtime/data/nvim/mason/bin:${PATH}

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl fd-find git nodejs python3 python3-pip ripgrep tar unzip xz-utils zstd build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" \
      -o /tmp/nvim.tar.gz \
    && mkdir -p /work/runtime/nvim \
    && tar -xzf /tmp/nvim.tar.gz --strip-components=1 -C /work/runtime/nvim \
    && rm /tmp/nvim.tar.gz

# Used only when building parsers; avoid installing the entire Node toolchain for npm.
RUN curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/download/v0.25.10/tree-sitter-linux-x64.gz" \
      -o /tmp/tree-sitter.gz \
    && gzip -dc /tmp/tree-sitter.gz > /usr/local/bin/tree-sitter \
    && chmod +x /usr/local/bin/tree-sitter \
    && rm /tmp/tree-sitter.gz

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
    && export NVIM_CONFIG_ROOT=/work/runtime/config/nvim NVIM_PROFILE="$CONFIG_PROFILE" NVIM_FEATURES="$CONFIG_FEATURES" NVIM_MAINTENANCE=1 \
    && if [ -n "$CONFIG_LANGUAGES" ]; then export NVIM_LANGUAGES="$CONFIG_LANGUAGES"; fi \
    && /work/runtime/nvim/bin/nvim --headless -u NONE -i NONE -l /work/source/scripts/save-config.lua \
    && NVIM_PACKAGES_OUTPUT=/tmp/config-packages NVIM_INSTALL_OS=Linux /work/runtime/nvim/bin/nvim --headless -u NONE -i NONE -l /work/source/scripts/system-packages.lua \
    && apt-get update \
    && if grep -qx "nodejs" /tmp/config-packages; then cat /tmp/config-packages > /tmp/install-packages; else grep -vx "npm" /tmp/config-packages > /tmp/install-packages; fi \
    && xargs apt-get install -y --no-install-recommends < /tmp/install-packages \
    && /work/runtime/nvim/bin/nvim --headless -i NONE "+lua dofile('/work/source/scripts/install-runtime.lua')" \
    && python3 /work/source/scripts/bundle-runtime.py /work/runtime \
    && NVIM_PLAN_OUTPUT=/work/runtime/config-plan.json /work/runtime/nvim/bin/nvim --headless -u NONE -i NONE -l /work/source/scripts/config-plan.lua

RUN mkdir -p /work/package/bin /work/package/runtime /work/package/backups /out \
    && cp -a /work/runtime/. /work/package/runtime/ \
    && cp /work/source/scripts/nvim-offline /work/package/bin/nvim-offline \
    && cp /work/source/scripts/nvim-offline-update /work/package/bin/nvim-offline-update \
    && chmod +x /work/package/bin/nvim-offline /work/package/bin/nvim-offline-update \
    && printf '{\n  "version": "%s",\n  "platform": "linux-x86_64-ubuntu-24.04",\n  "neovim": "%s"\n}\n' "$BUNDLE_VERSION" "$NVIM_VERSION" > /work/package/manifest.json \
    && python3 /work/source/scripts/offline-manifest.py /work/package \
    && tar --zstd -C /work/package -cf "/out/nvim-offline-linux-x86_64-${BUNDLE_VERSION}.tar.zst" . \
    && cd /out \
    && sha256sum "nvim-offline-linux-x86_64-${BUNDLE_VERSION}.tar.zst" > "nvim-offline-linux-x86_64-${BUNDLE_VERSION}.tar.zst.sha256"

FROM scratch AS bundle
COPY --from=builder /out/ /
