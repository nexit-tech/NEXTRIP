# --- Estágio 1: Construção (Build) ---
FROM debian:latest AS build-env

# Instala dependências necessárias para o Flutter
RUN apt-get update && \
    apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 && \
    apt-get clean

# Clona o Flutter (Versão Stable)
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Define o PATH do Flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Habilita Web
RUN flutter config --enable-web

# Copia os arquivos do projeto para o container
RUN mkdir /app/
COPY . /app/
WORKDIR /app/

# Recebe as variáveis do Railway durante o build (ARG)
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG GOOGLE_MAPS_API_KEY
ARG STRIPE_PUBLISHABLE_KEY

# Cria o arquivo .env manualmente antes do build
# (O flutter_dotenv precisa que o arquivo exista fisicamente)
RUN echo "SUPABASE_URL=$SUPABASE_URL" > .env && \
    echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env && \
    echo "GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY" >> .env && \
    echo "STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY" >> .env

# Baixa dependências e constrói para Web
RUN flutter pub get
RUN flutter build web --release --web-renderer html

# --- Estágio 2: Servidor (Production) ---
FROM nginx:1.21.1-alpine

# Copia a configuração do Nginx (vamos criar no passo 2)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copia os arquivos compilados do Flutter para o Nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expõe a porta padrão
EXPOSE 80

# Inicia o Nginx
CMD ["nginx", "-g", "daemon off;"]