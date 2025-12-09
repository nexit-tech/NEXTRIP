# --- Estágio 1: Construção (Build) ---
FROM ubuntu:20.04 AS builder

# Instalar dependências necessárias para o Flutter
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Clonar o Flutter SDK (Branch stable)
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable

# Configurar o PATH para reconhecer o comando 'flutter'
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Habilitar web e aceitar licenças (boa prática)
RUN flutter config --enable-web

# Copiar os arquivos do projeto para dentro do container
WORKDIR /app
COPY . .

# Rodar os comandos de build (igual ao seu build.sh, mas dentro do Docker)
RUN flutter pub get
RUN flutter build web --release

# --- Estágio 2: Servidor (Nginx) ---
FROM nginx:1.21.1-alpine

# Copiar a configuração do Nginx (se você tiver uma personalizada)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar APENAS os arquivos compilados do estágio anterior (builder)
# Note que a origem é --from=builder /app/build/web
COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]