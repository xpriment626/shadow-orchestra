#!/bin/bash

# Shadow Orchestrator Installation Script
set -e

REPO_URL="https://api.github.com/repos/xpriment626/shadow-orchestra/contents"
CLAUDE_MD_URL="$REPO_URL/CLAUDE.md"

echo "🎭 Installing Shadow Orchestrator..."

# Check if CLAUDE.md already exists
if [ -f "CLAUDE.md" ]; then
    echo "⚠️  CLAUDE.md already exists in this directory"
    echo "   Delete it first if you want to reinitialize"
    exit 1
fi

# Function to download and decode base64 content from GitHub API
download_file() {
    local url=$1
    local output=$2
    
    echo "📄 Downloading $output..."
    curl -s "$url" | jq -r '.content' | base64 -d > "$output"
}

# Function to download directory contents
download_directory() {
    local dir_url=$1
    local local_dir=$2
    
    echo "📁 Creating $local_dir directory..."
    mkdir -p "$local_dir"
    
    # Get directory contents from GitHub API
    local files=$(curl -s "$dir_url" | jq -r '.[].name')
    
    for file in $files; do
        if [[ $file == *.md ]]; then
            local file_url="$dir_url/$file"
            download_file "$file_url" "$local_dir/$file"
        fi
    done
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required but not installed. Please install jq first:"
    echo "   macOS: brew install jq"
    echo "   Ubuntu: sudo apt-get install jq"
    exit 1
fi

# Download CLAUDE.md
download_file "$CLAUDE_MD_URL" "CLAUDE.md"

# Download roles directory
download_directory "$REPO_URL/roles" "roles"

echo ""
echo "✅ Shadow Orchestrator installed successfully!"
echo ""
echo "Files created:"
echo "  📄 CLAUDE.md"
echo "  📁 roles/"

if [ -d "roles" ]; then
    for file in roles/*.md; do
        if [ -f "$file" ]; then
            echo "     📄 $(basename "$file")"
        fi
    done
fi

echo ""
echo "🎭 You can now use semantic role-switching with Claude Code!"
echo "   Example: \"Use the planner role to create a PRD for...\""