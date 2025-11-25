# --- Estágio 1: Construção (Build) ---
FROM debian:latest AS build-env

# Instala dependências
RUN apt-get update && \
    apt-get install -y curl git wget unzip gdb libstdc++6 libglu1-mesa fonts-liberation lib32stdc++6 python3 xz-utils && \
    apt-get clean

# Clona o Flutter (FORÇANDO A VERSÃO STABLE)
RUN git clone -b stable https://github.com/flutter/flutter.git /usr/local/flutter

# Define o PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Habilita Web
RUN flutter config --enable-web

# Copia os arquivos
RUN mkdir /app/
COPY . /app/
WORKDIR /app/

# Recebe variáveis do Railway
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG GOOGLE_MAPS_API_KEY
ARG STRIPE_PUBLISHABLE_KEY

# Cria o .env
RUN echo "SUPABASE_URL=$SUPABASE_URL" > .env && \
    echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env && \
    echo "GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY" >> .env && \
    echo "STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY" >> .env

# Baixa dependências
RUN flutter pub get

# Constrói (COMANDO SIMPLIFICADO PARA EVITAR ERRO)
RUN flutter build web --release

# --- Estágio 2: Servidor ---
FROM nginx:1.21.1-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]