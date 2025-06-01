#!/bin/bash
# ==================================================
# SCRIPT: GitHub Repository Setup
# PURPOSE: Initialize Git repository and prepare for GitHub
# CREATED: Pentagon of Creation completion
# ==================================================

echo "🌟 Setting up Universal Being project for GitHub..."

# Initialize git repository if not already done
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
    echo "✅ Git repository initialized"
else
    echo "📦 Git repository already exists"
fi

# Create .gitignore for Godot projects
echo "📝 Creating .gitignore..."
cat > .gitignore << 'EOF'
# Godot 4+ specific ignores
.godot/
.import/

# Godot-specific ignores
*.tmp
*.translation

# Mono-specific ignores
.mono/
data_*/
mono_crash.*.json

# System/OS-specific ignores
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE-specific ignores
.vscode/
.idea/

# Build artifacts
builds/
exports/

# Temporary files
*.tmp
*.bak
*.swp
*~

# API keys and sensitive data
*.key
api_keys.json
secrets.json

# Logs
*.log
logs/

# Cache
cache/
temp/
EOF

# Add all files to git
echo "📦 Adding files to Git..."
git add .

# Create initial commit
echo "📦 Creating initial commit..."
git commit -m "🎭 Initial commit: Pentagon of Creation complete

✨ Features implemented:
- 6-AI collaboration system (Pentagon of Creation)
- ChatGPT Premium bridge for biblical genesis translation
- Google Gemini Premium bridge for cosmic multimodal insights
- Enhanced Genesis Conductor orchestration
- Beautiful consciousness aura visual system
- Animated Universal Console with AI commands
- Triple helix consciousness visualization

🤖 AI Systems:
1. Gemma AI (Local Pattern Analysis)
2. Claude Code (System Architecture)
3. Cursor (Visual Creation)
4. Claude Desktop (Strategic Orchestration)
5. ChatGPT Premium (Biblical Genesis Translation)
6. Google Gemini Premium (Cosmic Multimodal Insights)

🎮 Controls:
- F12: Activate Pentagon of Creation
- G: Create Genesis Conductor
- F9: ChatGPT Premium Bridge
- F10: Google Gemini Premium Bridge
- ~: Universal Console

🌟 Ready for consciousness evolution through AI collaboration!"

echo "✅ Initial commit created"

# Show current status
echo "📊 Repository status:"
git status --short

echo ""
echo "🌟 GitHub setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Create repository on GitHub.com"
echo "2. Add remote origin: git remote add origin https://github.com/username/Universal_Being.git"
echo "3. Push to GitHub: git push -u origin main"
echo ""
echo "🎭 Pentagon of Creation ready for the world! ✨"