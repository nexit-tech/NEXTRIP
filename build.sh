#!/bin/bash

# Aumenta a verbosidade e encerra o script em caso de erro
set -eux

# 1. Define as variáveis de ambiente necessárias
FLUTTER_ROOT="$HOME/.flutter"
FLUTTER_BIN="$FLUTTER_ROOT/bin"

# 2. Clona o SDK do Flutter
if [ ! -d "$FLUTTER_ROOT" ]; then
    echo "Clonando o repositório do Flutter..."
    # Clona o repositório estável
    git clone https://github.com/flutter/flutter.git "$FLUTTER_ROOT" -b stable
else
    echo "SDK do Flutter já existe. Pulando clone."
fi

# 3. Exporta o binário do Flutter para o PATH GLOBAL DESTE SCRIPT
# Isso garante que todos os comandos "flutter" abaixo funcionem
export PATH="$PATH:$FLUTTER_BIN"

# 4. Garante que o SDK está pronto para o build web
echo "Configurando o Flutter para Web e pré-caching..."
flutter doctor --web
flutter config --enable-web
flutter precache --web

# 5. Instala as dependências do projeto
echo "Rodando flutter pub get..."
flutter pub get

# 6. Roda o comando de build final
echo "Rodando flutter build web --release..."
flutter build web --release