#!/bin/bash

# Swift Format Script
# 使用方法: ./scripts/format.sh [check|format]

set -e

# swift-formatがインストールされているかチェック
if ! command -v swift-format &> /dev/null; then
    echo "swift-formatがインストールされていません。"
    echo "インストール方法:"
    echo "git clone https://github.com/apple/swift-format.git"
    echo "cd swift-format"
    echo "swift build -c release"
    echo "sudo cp .build/release/swift-format /usr/local/bin/"
    exit 1
fi

# 設定ファイルの存在チェック
if [ ! -f ".swiftformat" ]; then
    echo ".swiftformat設定ファイルが見つかりません。"
    exit 1
fi

# モードの設定
MODE=${1:-format}

case $MODE in
    "check")
        echo "コードスタイルをチェック中..."
        swift-format format \
            --mode lint \
            --configuration .swiftformat \
            --recursive Sources/ Tests/
        echo "チェック完了"
        ;;
    "format")
        echo "コードをフォーマット中..."
        swift-format format \
            --mode inplace \
            --configuration .swiftformat \
            --recursive Sources/ Tests/
        echo "フォーマット完了"
        ;;
    *)
        echo "使用方法: $0 [check|format]"
        echo "  check  - コードスタイルをチェック"
        echo "  format - コードを自動フォーマット（デフォルト）"
        exit 1
        ;;
esac