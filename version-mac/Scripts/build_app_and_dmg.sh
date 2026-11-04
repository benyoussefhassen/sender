#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/Users/hassen/AI/sender-pro-mac-v2/version-mac"
DIST_DIR="$PROJECT_DIR/dist"
APP_NAME="Sender Pro.app"
APP_BUNDLE="$DIST_DIR/$APP_NAME"
DMG_PATH="$DIST_DIR/SenderPro-V4.65.6-macOS-Universal.dmg"

cd "$PROJECT_DIR"
mkdir -p "$DIST_DIR"

echo "==> 1. Compiling Apple Silicon (arm64) & Intel (x86_64) binaries..."
swiftc $(find Sources/SenderProMac -name "*.swift") -O -parse-as-library -target arm64-apple-macos13.0 -lsqlite3 -o "$DIST_DIR/SenderProMac-arm64"
swiftc $(find Sources/SenderProMac -name "*.swift") -O -parse-as-library -target x86_64-apple-macos13.0 -lsqlite3 -o "$DIST_DIR/SenderProMac-x86_64"
lipo -create "$DIST_DIR/SenderProMac-arm64" "$DIST_DIR/SenderProMac-x86_64" -output "$DIST_DIR/SenderProMac-Universal"

echo "==> 2. Assembling $APP_NAME bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$DIST_DIR/SenderProMac-Universal" "$APP_BUNDLE/Contents/MacOS/SenderProMac"
chmod +x "$APP_BUNDLE/Contents/MacOS/SenderProMac"

cat << 'PLIST' > "$APP_BUNDLE/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>Sender Pro V4</string>
    <key>CFBundleExecutable</key>
    <string>SenderProMac</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.senderprov.macos.v4</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Sender Pro</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>4.65.6</string>
    <key>CFBundleVersion</key>
    <string>4656</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2019-2026 Sender Pro V4.65.6. All rights reserved.</string>
</dict>
</plist>
PLIST

echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

echo "==> 3. Generating macOS AppIcon.icns..."
ICONSET_DIR="$DIST_DIR/AppIcon.iconset"
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

swift - << 'SWIFT_ICON'
import AppKit

let iconsetPath = "/Users/hassen/AI/sender-pro-mac-v2/version-mac/dist/AppIcon.iconset"
let sizes: [(Int, String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

for (sz, name) in sizes {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: sz, pixelsHigh: sz,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let rect = CGRect(x: 0, y: 0, width: sz, height: sz)
    let path = NSBezierPath(roundedRect: rect.insetBy(dx: CGFloat(sz)*0.06, dy: CGFloat(sz)*0.06), xRadius: CGFloat(sz)*0.22, yRadius: CGFloat(sz)*0.22)
    let grad = NSGradient(starting: NSColor(calibratedRed: 0.05, green: 0.74, blue: 0.52, alpha: 1.0),
                          ending: NSColor(calibratedRed: 0.09, green: 0.45, blue: 0.92, alpha: 1.0))!
    grad.draw(in: path, angle: -45)

    let str = "SP" as NSString
    let font = NSFont.boldSystemFont(ofSize: CGFloat(sz) * 0.44)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white
    ]
    let textSize = str.size(withAttributes: attrs)
    str.draw(at: CGPoint(x: (CGFloat(sz) - textSize.width)/2, y: (CGFloat(sz) - textSize.height)/2), withAttributes: attrs)
    NSGraphicsContext.restoreGraphicsState()

    if let png = rep.representation(using: .png, properties: [:]) {
        try? png.write(to: URL(fileURLWithPath: "\(iconsetPath)/\(name)"))
    }
}
SWIFT_ICON

iconutil -c icns "$ICONSET_DIR" -o "$APP_BUNDLE/Contents/Resources/AppIcon.icns" || true
rm -rf "$ICONSET_DIR"

echo "==> 4. Signing .app bundle with ad-hoc signature..."
codesign --force --deep --sign - "$APP_BUNDLE" 2>/dev/null || true

echo "==> 5. Creating DMG installer and ZIP distribution..."
rm -f "$DMG_PATH"
DMG_STAGING="$DIST_DIR/dmg_staging"
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"
cp -R "$APP_BUNDLE" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"
hdiutil create -volname "Sender Pro V4.65.6" -srcfolder "$DMG_STAGING" -ov -format UDZO "$DMG_PATH" 2>/dev/null || true
rm -rf "$DMG_STAGING"

cd "$DIST_DIR"
zip -qry "SenderPro-V4.65.6-macOS-Universal.app.zip" "$APP_NAME"
echo "==> Build & Packaging Complete!"
ls -lh "$DIST_DIR"
