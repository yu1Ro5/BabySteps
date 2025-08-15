#!/bin/bash

# Swift Format Script for Local Development
# 使用方法: ./scripts/format.sh [check|format]

set -e

# 色付きの出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# swift-formatがインストールされているかチェック
if ! command -v swift-format &> /dev/null; then
    echo -e "${RED}❌ swift-formatがインストールされていません。${NC}"
    echo ""
    echo "Xcode 16.4以降を使用している場合:"
    echo "  xcrun swift-format --help"
    echo ""
    echo "手動インストールの場合:"
    echo "  git clone https://github.com/apple/swift-format.git"
    echo "  cd swift-format"
    echo "  swift build -c release"
    echo "  sudo cp .build/release/swift-format /usr/local/bin/"
    exit 1
fi

# モードの設定
MODE=${1:-format}

case $MODE in
    "check")
        echo -e "${YELLOW}🔍 Swiftコードのスタイルをチェック中...${NC}"
        if xcrun swift-format lint --recursive Sources/ Tests/; then
            echo -e "${GREEN}✅ すべてのSwiftファイルが正しくフォーマットされています。${NC}"
        else
            echo -e "${RED}❌ フォーマットの問題が見つかりました。${NC}"
            echo "修正するには: ./scripts/format.sh format"
            exit 1
        fi
        ;;
    "format")
        echo -e "${YELLOW}✨ Swiftコードをフォーマット中...${NC}"
        xcrun swift-format format --in-place --recursive Sources/ Tests/
        echo -e "${GREEN}✅ フォーマット完了！${NC}"
        
        # 変更されたファイルを表示
        if [[ -n "$(git status --porcelain)" ]]; then
            echo ""
            echo -e "${YELLOW}📝 変更されたファイル:${NC}"
            git status --porcelain
            echo ""
            echo -e "${GREEN}💡 変更をコミットしてください:${NC}"
            echo "  git add -A"
            echo "  git commit -m 'Apply swift-format formatting'"
        else
            echo -e "${GREEN}✨ 変更はありません。${NC}"
        fi
        ;;
    *)
        echo -e "${YELLOW}使用方法: $0 [check|format]${NC}"
        echo "  check  - コードスタイルをチェック"
        echo "  format - コードを自動フォーマット（デフォルト）"
        echo ""
        echo -e "${GREEN}例:${NC}"
        echo "  ./scripts/format.sh check   # スタイルチェックのみ"
        echo "  ./scripts/format.sh format  # 自動フォーマット"
        exit 1
        ;;
esac