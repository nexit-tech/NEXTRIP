#!/bin/bash
# Encerra em caso de erro e imprime comandos (ajuda na depuração)
set -eux

# 1. Define as variáveis de ambiente e PATH
FLUTTER_ROOT="$HOME/.flutter"
FLUTTER_BIN="$FLUTTER_ROOT/bin"
export PATH="$PATH:$FLUTTER_BIN"

# 2. Clona o SDK do Flutter (se ainda não existir)
if [ ! -d "$FLUTTER_ROOT" ]; then
    echo "Clonando o repositório do Flutter..."
    git clone https://github.com/flutter/flutter.git "$FLUTTER_ROOT" -b stable
fi

# 3. CRUCIAL: Habilita o target web
echo "Habilitando configuração web no SDK..."
flutter config --enable-web

# 4. Baixa dependências (pacotes)
echo "Rodando flutter pub get..."
flutter pub get

# 5. Roda o comando de build final
echo "Rodando flutter build web --release..."
flutter build web --release