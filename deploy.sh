#!/bin/bash
# Deploy to Sileo Repository
# This script helps you package and prepare the tweak for Sileo distribution

set -e

PROJECT_NAME="CarPlay Guard"
BUNDLE_ID="com.window8.carplayguard"
VERSION="1.0.0"
ARCH="iphoneos-arm64"

echo "🚀 Deploying $PROJECT_NAME to Sileo..."
echo ""

# Step 1: Build
echo "📦 Step 1: Building tweak..."
make clean
make
make package

# Step 2: Find the deb file
DEB_FILE=$(find packages -name "*.deb" -type f | head -1)
if [ -z "$DEB_FILE" ]; then
    echo "❌ Error: .deb file not found"
    exit 1
fi

echo "✅ Built: $DEB_FILE"
echo ""

# Step 3: Extract package info
echo "📝 Step 2: Package information:"
dpkg -I "$DEB_FILE"
echo ""

# Step 4: Instructions
echo "🛠️ Step 3: Setup instructions for Sileo repo:"
echo ""
echo "Option A: Host on GitHub (Recommended)"
echo "  1. Create a 'debs' folder in your GitHub repo"
echo "  2. Upload $DEB_FILE to 'debs/' folder"
echo "  3. Commit and push to GitHub"
echo "  4. Users add repo: https://github.com/window8/carplay-guard"
echo ""
echo "Option B: Host on Web Server"
echo "  1. Upload $DEB_FILE to your server"
echo "  2. Generate Packages file:"
echo "     dpkg-scanpackages . > Packages"
echo "     gzip -c Packages > Packages.gz"
echo "  3. Create Release file (see SILEO_REPO_TEMPLATE.md)"
echo "  4. Users add repo: https://your-server.com"
echo ""
echo "Option C: Direct Install (Development)"
echo "  1. Copy $DEB_FILE to iPhone"
echo "  2. Open with Sileo or Filza"
echo "  3. Install directly"
echo ""

# Step 5: Show stats
echo "📊 Package Statistics:"
ls -lh "$DEB_FILE"
echo ""

echo "✅ Deploy preparation complete!"
echo ""
echo "📚 Next steps:"
echo "1. Read SILEO_INSTALL.md for detailed instructions"
echo "2. Choose your hosting option (GitHub / Web Server / Direct)"
echo "3. Test on device before public release"
echo ""
