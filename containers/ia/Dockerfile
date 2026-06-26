FROM ubuntu:24.04

ARG UID=1000
ARG GID=1000
ENV DEBIAN_FRONTEND=noninteractive
ENV DEVCONTAINER=true
ENV LANG=C.UTF-8
ENV TZ=Europe/Paris
ENV DISABLE_AUTOUPDATER=1
ENV RTK_TELEMETRY_DISABLED=1
ENV HOME=/home/dev
ENV XDG_CONFIG_HOME=/home/dev/.config
ENV NPM_CONFIG_PREFIX=/home/dev/.npm-global
ENV PATH=/home/dev/.local/bin:/home/dev/.npm-global/bin:/home/dev/.cargo/bin:$PATH

# fail RUN pipelines if any stage fails (also enables bash features)
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ubuntu:24.04 ships a built-in 'ubuntu' user at UID/GID 1000; remove it first.
# Pre-create /home/dev/.config so docker's bind-mount auto-creation (in ia.sh)
# doesn't make it root-owned and lock dev-run tools out of it.
RUN userdel -r ubuntu \
    && groupadd -g ${GID} dev \
    && useradd -l -m -u ${UID} -g ${GID} -s /bin/bash dev \
    && install -d -o dev -g dev -m 0755 /home/dev/.config

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    bubblewrap \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    fd-find \
    ghostscript \
    git \
    graphviz \
    imagemagick \
    jq \
    latexmk \
    less \
    lmodern \
    ltrace \
    lua-check \
    ncat \
    ninja-build \
    nodejs \
    npm \
    pandoc \
    pipx \
    poppler-utils \
    python3 \
    python3-openpyxl \
    python3-venv \
    ripgrep \
    samba-common-bin \
    shellcheck \
    socat \
    sqlite3 \
    strace \
    tesseract-ocr \
    texlive-fonts-extra \
    texlive-fonts-recommended \
    texlive-lang-french \
    texlive-latex-extra \
    texlive-latex-recommended \
    texlive-plain-generic \
    tree \
    tzdata \
    unzip \
    zip \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64 \
    -o /usr/local/bin/hadolint \
    && chmod +x /usr/local/bin/hadolint

RUN ARCH=$(dpkg --print-architecture) \
    && curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}" \
        -o /usr/local/bin/yq \
    && SHFMT_VER=$(curl -fsSL https://api.github.com/repos/mvdan/sh/releases/latest | jq -r .tag_name) \
    && curl -fsSL "https://github.com/mvdan/sh/releases/download/${SHFMT_VER}/shfmt_${SHFMT_VER}_linux_${ARCH}" \
        -o /usr/local/bin/shfmt \
    && chmod +x /usr/local/bin/yq /usr/local/bin/shfmt

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

RUN ARCH=$(dpkg --print-architecture) \
    && GLAB_URL=$(curl -sSfL "https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases/permalink/latest" \
        | jq -r --arg s "linux_${ARCH}.deb" '.assets.links[] | select(.name | endswith($s)) | .url') \
    && curl -fsSL "$GLAB_URL" -o /tmp/glab.deb \
    && dpkg -i /tmp/glab.deb \
    && rm /tmp/glab.deb

# Neovim: latest stable from GitHub (matches the host, not the distro package) so
# core config can be load-tested headless with `nvim -l` / `nvim --headless`
RUN ARCH=$(dpkg --print-architecture) \
    && case "$ARCH" in \
         amd64) NVIM_ARCH=x86_64 ;; \
         arm64) NVIM_ARCH=arm64 ;; \
         *) echo "unsupported arch: $ARCH" >&2; exit 1 ;; \
       esac \
    && curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz" \
        -o /tmp/nvim.tar.gz \
    && tar -C /opt -xzf /tmp/nvim.tar.gz \
    && ln -s "/opt/nvim-linux-${NVIM_ARCH}/bin/nvim" /usr/local/bin/nvim \
    && rm /tmp/nvim.tar.gz

# tree-sitter CLI: nvim-treesitter (main branch) compiles parsers with it
RUN ARCH=$(dpkg --print-architecture) \
    && case "$ARCH" in \
         amd64) TS_ARCH=x64 ;; \
         arm64) TS_ARCH=arm64 ;; \
         *) echo "unsupported arch: $ARCH" >&2; exit 1 ;; \
       esac \
    && curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-${TS_ARCH}.gz" \
        | gunzip > /usr/local/bin/tree-sitter \
    && chmod +x /usr/local/bin/tree-sitter

USER dev

RUN pipx ensurepath && \
    pipx install \
    ansible-lint \
    poetry \
    pre-commit \
    prek \
    uv \
    yamllint

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

ARG NPM_CACHEBUST
RUN npm install -g @anthropic-ai/claude-code \
    && ln -s /home/dev/.npm-global/bin/claude /home/dev/.local/bin/claude
RUN npm install -g @openai/codex
RUN npm install -g @github/copilot
RUN curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

COPY entrypoint.sh /usr/local/bin/ia-entrypoint

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/ia-entrypoint"]
