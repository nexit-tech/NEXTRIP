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

# Configurar o PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Habilitar web
RUN flutter config --enable-web

WORKDIR /app
COPY . .

# --- CORREÇÃO AQUI ---
# Cria um arquivo .env temporário para o build não falhar.
# O ideal é injetar as chaves reais aqui se você precisar delas no app.
RUN touch .env

# Opcional: Se quiser que o app funcione com as chaves reais, descomente e preencha abaixo:
# RUN echo "SUPABASE_URL=sua_url_aqui" > .env
# RUN echo "SUPABASE_ANON_KEY=sua_chave_aqui" >> .env
# ---------------------

RUN flutter pub get
RUN flutter build web --release --no-tree-shake-icons

# --- Estágio 2: Servidor (Nginx) ---
FROM nginx:1.21.1-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]