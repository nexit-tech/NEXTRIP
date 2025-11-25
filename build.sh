#!/bin/bash

# Define o diretório do Flutter SDK dentro do container
FLUTTER_ROOT="$HOME/.flutter"
export PATH="$PATH:$FLUTTER_ROOT/bin"

# Clona o repositório do Flutter (usando a branch estável para garantir estabilidade)
echo "Clonando o repositório do Flutter..."
git clone https://github.com/flutter/flutter.git "$FLUTTER_ROOT" -b stable

# Roda o doctor para baixar dependências e verificar
echo "Rodando flutter doctor..."
flutter doctor

# 1. Instala as dependências do Flutter (se houver)
echo "Rodando flutter pub get..."
flutter pub get

# 2. Roda o comando de build final
echo "Rodando flutter build web --release..."
flutter build web --release