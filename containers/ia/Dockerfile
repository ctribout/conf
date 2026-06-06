FROM ubuntu:24.04

ARG UID=1000
ARG GID=1000
ENV DEBIAN_FRONTEND=noninteractive
ENV DEVCONTAINER=true
ENV HOME=/home/dev
ENV XDG_CONFIG_HOME=/home/dev/.config
ENV NPM_CONFIG_PREFIX=/home/dev/.npm-global
ENV PATH=/home/dev/.local/bin:/home/dev/.npm-global/bin:/home/dev/.cargo/bin:$PATH

# ubuntu:24.04 ships a built-in 'ubuntu' user at UID/GID 1000; remove it first
RUN userdel -r ubuntu \
    && groupadd -g ${GID} dev \
    && useradd -m -u ${UID} -g ${GID} -s /bin/bash dev

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    fd-find \
    git \
    jq \
    ninja-build \
    nodejs \
    npm \
    pipx \
    python3 \
    ripgrep \
    shellcheck \
    tree \
    unzip \
    zip \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64 \
    -o /usr/local/bin/hadolint \
    && chmod +x /usr/local/bin/hadolint

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

USER dev

RUN pipx ensurepath && \
    pipx install \
    ansible-lint \
    poetry \
    uv \
    yamllint

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

ARG NPM_CACHEBUST
RUN npm install -g @anthropic-ai/claude-code \
    && ln -s /home/dev/.npm-global/bin/claude /home/dev/.local/bin/claude
RUN npm install -g @openai/codex
RUN npm install -g @github/copilot

WORKDIR /workspace
ENTRYPOINT ["claude"]
