FROM amazoncorretto:21-alpine AS server-builder

RUN apk update
RUN apk add curl jq

WORKDIR /app

RUN WEBX_DEMO_SERVER_VERSION=$(curl -fsSL https://api.github.com/repos/ILLGrenoble/webx-demo-server/releases/latest | jq -r .tag_name); \
    echo "Downloading webx-demo-server ${WEBX_DEMO_SERVER_VERSION}"; \
    curl -fsSL -o webx-demo-server.tar.gz https://github.com/ILLGrenoble/webx-demo-server/archive/refs/tags/${WEBX_DEMO_SERVER_VERSION}.tar.gz; \
    tar -xzf webx-demo-server.tar.gz; \
    mv webx-demo-server-${WEBX_DEMO_SERVER_VERSION} webx-demo-server

RUN cd webx-demo-server; \
    ./mvnw clean package -B -DskipTests=true


FROM node:22-alpine AS client-builder

RUN apk update
RUN apk add curl jq

WORKDIR /app

RUN WEBX_DEMO_CLIENT_VERSION=$(curl -fsSL https://api.github.com/repos/ILLGrenoble/webx-demo-client/releases/latest | jq -r .tag_name); \
    echo "Downloading webx-demo-client ${WEBX_DEMO_CLIENT_VERSION}"; \
    curl -fsSL -o webx-demo-client.tar.gz https://github.com/ILLGrenoble/webx-demo-client/archive/refs/tags/${WEBX_DEMO_CLIENT_VERSION}.tar.gz; \
    tar -xzf webx-demo-client.tar.gz; \
    mv webx-demo-client-${WEBX_DEMO_CLIENT_VERSION} webx-demo-client

RUN cd webx-demo-client; \
    npm install; \
    npm run build

FROM ghcr.io/illgrenoble/webx-dev-env-ubuntu:24.04

RUN apt update
RUN apt install -y \ 
    jq \
    openjdk-21-jre-headless \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Download and install webx-router
RUN WEBX_ROUTER_VERSION=$(curl -fsSL https://api.github.com/repos/ILLGrenoble/webx-router/releases/latest | jq -r .tag_name); \
    ARCH=$(dpkg --print-architecture); \
    echo "Downloading webx-router ${WEBX_ROUTER_VERSION}"; \
    curl -fsSL -o /tmp/webx-router.deb https://github.com/ILLGrenoble/webx-router/releases/download/${WEBX_ROUTER_VERSION}/webx-router_${WEBX_ROUTER_VERSION}_ubuntu_24.04_${ARCH}.deb
RUN dpkg -i /tmp/webx-router.deb

# Download and install webx-engine
RUN WEBX_ENGINE_VERSION=$(curl -fsSL https://api.github.com/repos/ILLGrenoble/webx-engine/releases/latest | jq -r .tag_name); \
    ARCH=$(dpkg --print-architecture); \
    echo "Downloading webx-engine ${WEBX_ENGINE_VERSION}"; \
    curl -fsSL -o /tmp/webx-engine.deb https://github.com/ILLGrenoble/webx-engine/releases/download/${WEBX_ENGINE_VERSION}/webx-engine_${WEBX_ENGINE_VERSION}_ubuntu_24.04_${ARCH}.deb
RUN dpkg -i /tmp/webx-engine.deb

# Create standard users
RUN useradd -m -U -s /bin/bash -p $(openssl passwd -6 'mario') mario \
    && useradd -m -U -s /bin/bash -p $(openssl passwd -6 'luigi') luigi \
    && useradd -m -U -s /bin/bash -p $(openssl passwd -6 'peach') peach \
    && useradd -m -U -s /bin/bash -p $(openssl passwd -6 'toad') toad \
    && useradd -m -U -s /bin/bash -p $(openssl passwd -6 'bowser') bowser \
    && useradd -m -U -s /bin/bash -p $(openssl passwd -6 'yoshi') yoshi

# Update X config to allow creation of Xorg and xfce4 desktop manager by non-root user
RUN sed -i 's/console/anybody/g' /etc/X11/Xwrapper.config \
    && echo "needs_root_rights = no" | tee -a /etc/X11/Xwrapper.config \
    && cp /etc/X11/xrdp/xorg.conf /etc/X11/xorg.conf

WORKDIR /app

# copy webx-demo-server
COPY --from=server-builder /app/webx-demo-server/target/webx-demo.jar /app

# copy webx-demo-client
COPY --from=client-builder /app/webx-demo-client/dist /usr/share/nginx/html

# --- Nginx config ---
RUN rm /etc/nginx/sites-enabled/default
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /etc/nginx/certs
RUN openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -keyout /etc/nginx/certs/web.key -out /etc/nginx/certs/web.crt -subj "/CN=*"

# --- Supervisor config ---
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor

ENV WEBX_ROUTER_LOGGING_LEVEL=debug
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
