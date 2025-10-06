# --- Stage 1: Neovim, Go & Lemminx Build Environment (Builder) ---
# This stage is responsible for compiling Neovim and lemminx, and downloading Go.
FROM ubuntu:24.04 AS builder

# --- Image Metadata ---
LABEL maintainer="Your Name <you@example.com>"
LABEL description="Multi-arch Docker image for Neovim, Go & Lemminx (Builder Stage)."

# --- Build Arguments ---
# Define versions for the tools to be built or installed
ARG NVIM_VERSION=stable
ARG GO_VERSION=1.22.5
ARG LEMMINX_VERSION=0.29.0
ARG LATEXINDENT_VERSION=V3.24.7
# TARGETARCH is a built-in argument provided by buildx
ARG TARGETARCH

# --- Environment Variables ---
ENV DEBIAN_FRONTEND=noninteractive

# --- Install Dependencies and Build Tools ---
RUN \
    # 1. Update package lists and install build dependencies
    echo "Installing build dependencies..." && \
    apt-get update --allow-insecure-repositories && \
    apt-get install -y --no-install-recommends \
    git \
    cmake \
    ninja-build \
    gettext \
    unzip \
    build-essential \
    wget \
    ca-certificates \
    curl \
    zlib1g-dev \
    pkg-config \
    libssl-dev \
    && \
    \
    # 2. Clone, compile, and install Neovim
    echo "Cloning Neovim repository (branch/tag: ${NVIM_VERSION})..." && \
    git clone --depth 1 --branch ${NVIM_VERSION} https://github.com/neovim/neovim.git /tmp/neovim && \
    echo "Compiling and installing Neovim..." && \
    cd /tmp/neovim && \
    make CMAKE_BUILD_TYPE=Release && \
    make CMAKE_INSTALL_PREFIX=/usr/local install && \
    \
    # 3. Determine Go architecture and install Go
    GO_ARCH="" && \
    case ${TARGETARCH} in \
    "amd64") GO_ARCH="amd64" ;; \
    "arm64") GO_ARCH="arm64" ;; \
    *) echo "Unsupported architecture for Go: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    echo "Downloading and installing Go ${GO_VERSION} for linux-${GO_ARCH}..." && \
    wget -qO go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz" && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    \
    # 4. Conditionally build tools ONLY for arm64 architecture
    if [ "${TARGETARCH}" = "arm64" ]; then \
    echo "ARM64 detected, building lemminx and asm-lsp from source..." && \
    \
    # 4a. Install GraalVM 21.3.0 (JDK 17) for lemminx build
    echo "Installing GraalVM 21.3.0 for JDK 17..." && \
    wget -qO graalvm.tar.gz "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.3.0/graalvm-ce-java17-linux-aarch64-21.3.0.tar.gz" && \
    mkdir -p /usr/local/graalvm && \
    tar -xzf graalvm.tar.gz -C /usr/local/graalvm --strip-components=1 && \
    rm graalvm.tar.gz && \
    \
    # 4b. Download and install the native-image component from a local file to avoid network errors
    echo "Downloading and installing GraalVM native-image component from local file..." && \
    wget -qO /tmp/native-image.jar "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.3.0/native-image-installable-svm-java17-linux-aarch64-21.3.0.jar" && \
    /usr/local/graalvm/bin/gu install -L /tmp/native-image.jar && \
    rm /tmp/native-image.jar && \
    \
    # 4c. Clone and build lemminx from source using GraalVM
    echo "Cloning and building lemminx ${LEMMINX_VERSION}..." && \
    export JAVA_HOME=/usr/local/graalvm && \
    export PATH=$JAVA_HOME/bin:$PATH && \
    export MAVEN_OPTS="-Xmx4g" && \
    git clone --depth 1 --branch ${LEMMINX_VERSION} https://github.com/eclipse/lemminx.git /tmp/lemminx && \
    cd /tmp/lemminx && \
    echo "Configuring Maven to use a regional mirror for central repo to prevent download failures..." && \
    echo '<settings><mirrors><mirror><id>alimaven</id><name>aliyun maven</name><url>https://maven.aliyun.com/nexus/content/groups/public/</url><mirrorOf>central</mirrorOf></mirror></mirrors></settings>' > /tmp/settings.xml && \
    ./mvnw -s /tmp/settings.xml clean package -Dnative -DskipTests && \
    find org.eclipse.lemminx/target -name "lemminx-*" -executable -type f -exec install {} /usr/local/bin/lemminx \; && \
    \
    # 4d. Install Rust and build asm-lsp
    echo "Installing Rust toolchain to build asm-lsp..." && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    export PATH="/root/.cargo/bin:${PATH}" && \
    cargo install asm-lsp && \
    install /root/.cargo/bin/asm-lsp /usr/local/bin/asm-lsp && \
    \
    # 4e. Download latexindent.pl for arm64
    echo "Downloading latexindent.pl for arm64..." && \
    wget -qO /usr/local/bin/latexindent.pl "https://github.com/cmhughes/latexindent.pl/releases/download/${LATEXINDENT_VERSION}/latexindent-linux-arm64" && \
    chmod +x /usr/local/bin/latexindent.pl; \
    fi && \
    \
    # 5. Cleanup build stage
    echo "Cleaning up build stage..." && \
    apt-get purge -y --auto-remove git cmake ninja-build gettext unzip build-essential wget ca-certificates curl zlib1g-dev pkg-config libssl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /root/.cargo /usr/local/graalvm

# --- Stage 2: Final Runtime Image ---
# This stage creates a clean final image containing the pre-built tools and a custom config.
FROM ubuntu:24.04

# Update the final image's description
LABEL description="Final minimal Neovim runtime environment with Go and custom config from https://github.com/Rlyown/nvim.git."

# Copy the compiled tools (Neovim, Go, and conditionally Lemminx/asm-lsp/latexindent) from the "builder" stage
COPY --from=builder /usr/local /usr/local

# --- Environment Variables ---
ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH="/root/go" \
    PATH="/root/.cargo/bin:/usr/local/go/bin:/root/go/bin:${PATH}" \
    GO111MODULE=on \
    GOPROXY="https://goproxy.cn,direct" 

# Install runtime dependencies and configure the environment
RUN \
    # 1. Install runtime dependencies from apt
    echo "Installing runtime dependencies..." && \
    apt-get update --allow-insecure-repositories && \
    apt-get install -y --no-install-recommends \
    git \
    build-essential \
    ripgrep \
    fd-find \
    bear \
    xclip \
    nodejs \
    npm \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    unzip \
    wget \
    imagemagick \
    ghostscript \
    clangd \
    && \
    \
    # 2. Install lazygit
    echo "Installing lazygit..." && \
    LAZYGIT_VERSION="0.40.2" && \
    LG_ARCH="" && \
    case "$(dpkg --print-architecture)" in \
    "amd64") LG_ARCH="x86_64" ;; \
    "arm64") LG_ARCH="arm64" ;; \
    *) echo "Unsupported architecture for lazygit"; exit 1 ;; \
    esac && \
    wget -qO lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LG_ARCH}.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && \
    install lazygit /usr/local/bin && \
    rm -rf lazygit lazygit.tar.gz && \
    \
    # 3. Create a wrapper script for kitty icat to enable image previews
    echo "Creating kitty icat wrapper script..." && \
    echo '#!/bin/sh' > /usr/local/bin/kitty && \
    echo 'set -e' >> /usr/local/bin/kitty && \
    echo 'if [ "$1" = "icat" ]; then' >> /usr/local/bin/kitty && \
    echo '  shift' >> /usr/local/bin/kitty && \
    echo '  while [ $# -gt 0 ]; do' >> /usr/local/bin/kitty && \
    echo '    printf "\033_Gf=100,a=T,t=d,s=%s,v=%s,m=1;" "$(base64 -w0 "$1" | wc -c)" "$(base64 -w0 "$1")"' >> /usr/local/bin/kitty && \
    echo '    printf "\033\\"' >> /usr/local/bin/kitty && \
    echo '    shift' >> /usr/local/bin/kitty && \
    echo '  done' >> /usr/local/bin/kitty && \
    echo 'else' >> /usr/local/bin/kitty && \
    echo '  exec /usr/bin/env kitty "$@"' >> /usr/local/bin/kitty && \
    echo 'fi' >> /usr/local/bin/kitty && \
    chmod +x /usr/local/bin/kitty && \
    \
    # 4. Install Rust toolchain (for runtime dependencies like plugins)
    echo "Installing Rust toolchain..." && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    \
    # 5. Install global npm packages
    echo "Installing tree-sitter-cli..." && \
    npm install -g tree-sitter-cli && \
    \
    # 6. Conditionally set up Mason links ONLY for arm64
    if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
    echo "ARM64 detected, setting up Mason links for pre-built tools..." && \
    \
    # Set up system-installed LSPs for Mason
    mkdir -p /root/.local/share/nvim/mason/bin && \
    ln -s /usr/bin/clangd /root/.local/share/nvim/mason/bin/clangd && \
    mkdir -p /root/.local/share/nvim/mason/packages/clangd && \
    ln -s /usr/local/bin/lemminx /root/.local/share/nvim/mason/bin/lemminx && \
    mkdir -p /root/.local/share/nvim/mason/packages/lemminx && \
    ln -s /usr/local/bin/asm-lsp /root/.local/share/nvim/mason/bin/asm-lsp && \
    mkdir -p /root/.local/share/nvim/mason/packages/asm-lsp && \
    ln -s /usr/local/bin/latexindent.pl /root/.local/share/nvim/mason/bin/latexindent && \
    mkdir -p /root/.local/share/nvim/mason/packages/latexindent; \
    fi && \
    \
    # 7. Clone Neovim configuration
    echo "Cloning configuration into /root/.config/nvim" && \
    mkdir -p /root/.config && \
    git clone --depth 1 https://github.com/Rlyown/nvim.git /root/.config/nvim && \
    \
    # 8. Install Neovim plugins, parsers, and LSPs
    echo "Installing Neovim plugins, parsers, and LSPs..." && \
    nvim --headless "+Lazy! restore" +qa && \
    nvim --headless "+TSUpdate" +qa && \
    nvim --headless "+MasonToolsInstallSync" +qa && \
    \
    # 9. Create an entrypoint script for user guidance
    echo "Creating entrypoint script..." && \
    echo '#!/bin/sh' > /usr/local/bin/entrypoint.sh && \
    echo '# This script checks for AI provider environment variables and provides instructions on container start.' >> /usr/local/bin/entrypoint.sh && \
    echo '' >> /usr/local/bin/entrypoint.sh && \
    echo 'echo "--- AI Assistant Configuration ---"' >> /usr/local/bin/entrypoint.sh && \
    echo 'if [ "$(echo "$AVANTE_PROVIDER" | tr '\''[:upper:]'\'' '\''[:lower:]'\'')" = "copilot" ]; then' >> /usr/local/bin/entrypoint.sh && \
    echo '    echo "Copilot provider is selected."' >> /usr/local/bin/entrypoint.sh && \
    echo '    echo "IMPORTANT: To authenticate, please run the following command inside Neovim:"' >> /usr/local/bin/entrypoint.sh && \
    echo '    echo "  :Copilot auth"' >> /usr/local/bin/entrypoint.sh && \
    echo 'elif [ "$(echo "$AVANTE_PROVIDER" | tr '\''[:upper:]'\'' '\''[:lower:]'\'')" = "openai" ]; then' >> /usr/local/bin/entrypoint.sh && \
    echo '    echo "OpenAI provider is selected."' >> /usr/local/bin/entrypoint.sh && \
    echo '    echo "Ensure the following environment variables are set correctly:"' >> /usr/local/bin/entrypoint.sh && \
    echo '    echo "  - AVANTE_OPENAI_MODEL"' >> /usr/local/bin/entrypoint.sh && \
    echo '    echo "  - AVANTE_OPENAI_ENDPOINT"' >> /usr/local/bin/entrypoint.sh && \
    echo '    echo "  - AVANTE_OPENAI_API_KEY"' >> /usr/local/bin/entrypoint.sh && \
    echo 'else' >> /usr/local/bin/entrypoint.sh && \
    echo '    echo "No specific AI provider selected via AVANTE_PROVIDER."' >> /usr/local/bin/entrypoint.sh && \
    echo '    echo "You can set AVANTE_PROVIDER to '\''copilot'\'' or '\''openai'\''." ' >> /usr/local/bin/entrypoint.sh && \
    echo 'fi' >> /usr/local/bin/entrypoint.sh && \
    echo 'echo "---------------------------------"' >> /usr/local/bin/entrypoint.sh && \
    echo 'echo ""' >> /usr/local/bin/entrypoint.sh && \
    echo '# Execute the command passed to the entrypoint (e.g., "nvim")' >> /usr/local/bin/entrypoint.sh && \
    echo 'exec "$@"' >> /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    \
    # 10. Clean up cache files
    echo "Cleaning up..." && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --- Default Container Configuration ---
WORKDIR /root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nvim"]



