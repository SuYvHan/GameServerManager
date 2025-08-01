FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive \
    STEAM_USER=steam \
    STEAM_HOME=/root \
    STEAMCMD_DIR=/root/steamcmd \
    GAMES_DIR=/root/games \
    NODE_VERSION=22.17.0

# 将apt源改为中国镜像源（阿里云）
# RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
#     && sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装Node.js、Python、SteamCMD和常见依赖（包括32位库）
RUN apt-get update && apt-get upgrade -y \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        locales \
        wget \
        curl \
        jq \
        xdg-user-dirs \
        # Node.js相关依赖
        gnupg \
        # Python相关依赖
        python3 \
        python3-pip \
        python3-dev \
        python3-venv \
        # 游戏服务器依赖
        libncurses5:i386 \
        libbz2-1.0:i386 \
        libicu67:i386 \
        libxml2:i386 \
        libstdc++6:i386 \
        lib32gcc-s1 \
        libc6-i386 \
        lib32stdc++6 \
        libcurl4-gnutls-dev:i386 \
        libcurl4-gnutls-dev \
        libgl1-mesa-glx:i386 \
        gcc-10-base:i386 \
        libssl1.1:i386 \
        libopenal1:i386 \
        libtinfo6:i386 \
        libtcmalloc-minimal4:i386 \
        # .NET和Mono相关依赖（ECO服务器等需要）
        libgdiplus \
        libc6-dev \
        libasound2 \
        libpulse0 \
        libnss3 \
        libgconf-2-4 \
        libcap2 \
        libatk1.0-0 \
        libcairo2 \
        libcups2 \
        libgtk-3-0 \
        libgdk-pixbuf2.0-0 \
        libpango-1.0-0 \
        libx11-6 \
        libxt6 \
        # Unity游戏服务端额外依赖（7日杀等）
        libsdl2-2.0-0:i386 \
        libsdl2-2.0-0 \
        libpulse0:i386 \
        libfontconfig1:i386 \
        libfontconfig1 \
        libudev1:i386 \
        libudev1 \
        libpugixml1v5 \
        libvulkan1 \
        libvulkan1:i386 \
        libgconf-2-4:i386 \
        # 额外的Unity引擎依赖（特别针对7日杀）
        libatk1.0-0:i386 \
        libxcomposite1 \
        libxcomposite1:i386 \
        libxcursor1 \
        libxcursor1:i386 \
        libxrandr2 \
        libxrandr2:i386 \
        libxss1 \
        libxss1:i386 \
        libxtst6 \
        libxtst6:i386 \
        libxi6 \
        libxi6:i386 \
        libxkbfile1 \
        libxkbfile1:i386 \
        libasound2:i386 \
        libgtk-3-0:i386 \
        libdbus-1-3 \
        libdbus-1-3:i386 \
        # ARK: Survival Evolved（方舟生存进化）服务器额外依赖
        libelf1 \
        libelf1:i386 \
        libatomic1 \
        libatomic1:i386 \
        nano \
        net-tools \
        netcat \
        procps \
        tar \
        unzip \
        bzip2 \
        xz-utils \
        zlib1g:i386 \
        fonts-wqy-zenhei \
        fonts-wqy-microhei \
        libc6 \
        libc6:i386 \
    && rm -rf /var/lib/apt/lists/*

# 安装Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm config set registry https://registry.npmmirror.com \
    && npm install -g npm@latest

# 安装Java 21（通过Adoptium仓库）
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
        apt-transport-https \
        gnupg \
    && wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - \
    && echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        temurin-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# 设置Java环境变量
ENV JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64 \
    PATH="$JAVA_HOME/bin:$PATH"

# 设置 locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen
ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

# 创建steam用户和应用目录
RUN useradd -m -s /bin/bash ${STEAM_USER} \
    && mkdir -p ${STEAMCMD_DIR} ${GAMES_DIR} /app \
    && chown -R ${STEAM_USER}:${STEAM_USER} /home/steam \
    && chown -R ${STEAM_USER}:${STEAM_USER} /app

# 复制项目文件
COPY --chown=steam:steam . /app/

# 切换到steam用户构建项目
USER ${STEAM_USER}
WORKDIR /app

# 切换回root用户继续安装SteamCMD
USER root

# 下载并安装SteamCMD
RUN mkdir -p ${STEAMCMD_DIR} \
    && cd ${STEAMCMD_DIR} \
    && (if curl -s --connect-timeout 3 http://192.168.10.23:7890 >/dev/null 2>&1 || wget -q --timeout=3 --tries=1 http://192.168.10.23:7890 -O /dev/null >/dev/null 2>&1; then \
          echo "代理服务器可用，使用代理下载和初始化"; \
          export http_proxy=http://192.168.10.23:7890; \
          export https_proxy=http://192.168.10.23:7890; \
          wget -t 5 --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -O steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
          || wget -t 5 --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -O steamcmd_linux.tar.gz https://media.steampowered.com/installer/steamcmd_linux.tar.gz; \
          tar -xzvf steamcmd_linux.tar.gz; \
          rm steamcmd_linux.tar.gz; \
          chmod +x ${STEAMCMD_DIR}/steamcmd.sh; \
          cd ${STEAMCMD_DIR} && ./steamcmd.sh +quit; \
          unset http_proxy https_proxy; \
        else \
          echo "代理服务器不可用，使用直接连接"; \
          wget -t 5 --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -O steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
          || wget -t 5 --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -O steamcmd_linux.tar.gz https://media.steampowered.com/installer/steamcmd_linux.tar.gz; \
          tar -xzvf steamcmd_linux.tar.gz; \
          rm steamcmd_linux.tar.gz; \
          chmod +x ${STEAMCMD_DIR}/steamcmd.sh; \
          cd ${STEAMCMD_DIR} && ./steamcmd.sh +quit; \
        fi) \
    # 创建steamclient.so符号链接
    && mkdir -p ${STEAM_HOME}/.steam/sdk32 ${STEAM_HOME}/.steam/sdk64 \
    && ln -sf ${STEAMCMD_DIR}/linux32/steamclient.so ${STEAM_HOME}/.steam/sdk32/steamclient.so \
    && ln -sf ${STEAMCMD_DIR}/linux64/steamclient.so ${STEAM_HOME}/.steam/sdk64/steamclient.so \
    # 创建额外的游戏常用目录链接
    && mkdir -p ${STEAM_HOME}/.steam/sdk32/steamclient.so.dbg.sig ${STEAM_HOME}/.steam/sdk64/steamclient.so.dbg.sig \
    && mkdir -p ${STEAM_HOME}/.steam/steam \
    && ln -sf ${STEAMCMD_DIR}/linux32 ${STEAM_HOME}/.steam/steam/linux32 \
    && ln -sf ${STEAMCMD_DIR}/linux64 ${STEAM_HOME}/.steam/steam/linux64 \
    && ln -sf ${STEAMCMD_DIR}/steamcmd ${STEAM_HOME}/.steam/steam/steamcmd

# 安装依赖并构建项目
RUN npm run install:all \
    && npm run package:linux:no-zip

# 安装Python依赖
RUN pip3 install --no-cache-dir -r /app/server/src/Python/requirements.txt

# 复制构建好的应用到root目录
RUN cp -r /app/dist/package/* /root/ \
    && chmod +x /root/start.sh

# 复制启动脚本到root目录
COPY start.sh /root/start.sh
RUN chmod +x /root/start.sh

# 创建数据目录并复制默认数据
RUN mkdir -p /root/server/data \
    && cp -r /app/server/data/* /root/server/data/ \
    && chown -R root:root /root/server/data

# 创建目录用于挂载游戏数据
VOLUME ["${GAMES_DIR}"]

# 暴露GSM3管理面板端口
EXPOSE 3001

# 保持root用户
USER root
WORKDIR /root

# 启动容器时运行start.sh
ENTRYPOINT ["/root/start.sh"]