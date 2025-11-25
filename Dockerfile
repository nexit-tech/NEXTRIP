# --- Estágio 1: Construção (Build) ---
FROM debian:latest AS build-env

# 1. Instala dependências do sistema
RUN apt-get update && \
    apt-get install -y curl git wget unzip gdb libstdc++6 libglu1-mesa fonts-liberation lib32stdc++6 python3 xz-utils && \
    apt-get clean

# 2. Baixa o Flutter (Stable)
RUN git clone -b stable https://github.com/flutter/flutter.git /usr/local/flutter

# 3. Configura o PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# 4. Habilita Web
RUN flutter config --enable-web

# 5. Copia os arquivos
RUN mkdir /app/
COPY . /app/
WORKDIR /app/

# 6. Recebe variáveis do Railway (Build Args)
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG GOOGLE_MAPS_API_KEY
ARG STRIPE_PUBLISHABLE_KEY

# 7. Cria o arquivo .env físico
RUN echo "SUPABASE_URL=$SUPABASE_URL" > .env && \
    echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env && \
    echo "GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY" >> .env && \
    echo "STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY" >> .env

# 8. LIMPEZA E ATUALIZAÇÃO DE PACOTES (A CORREÇÃO ESTÁ AQUI)
# Força a atualização dos pacotes para serem compatíveis com o Flutter Stable atual
RUN flutter pub upgrade --major-versions
RUN flutter pub get

# 9. Compila (com -v para ver detalhes se der erro)
RUN flutter build web --release -v

# --- Estágio 2: Servidor Nginx ---
FROM nginx:1.21.1-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]