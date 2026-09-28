#!/data/data/com.termux/files/usr/bin/bash

APP_NAME="PortCheck"
SOURCE="$HOME/PortCheck/portcheck.sh"
TARGET="$HOME/.portcheck/portcheck.sh"

echo
echo "================================"
echo "       $APP_NAME Updater"
echo "================================"
echo

if [ ! -f "$SOURCE" ]; then
    echo "[ERROR] Source file not found:"
    echo "$SOURCE"
    exit 1
fi

if [ ! -d "$HOME/.portcheck" ]; then
    echo "[ERROR] PortCheck is not installed."
    echo "Run the installer first."
    exit 1
fi

echo "[*] Updating PortCheck..."

cp "$SOURCE" "$TARGET"

if [ $? -ne 0 ]; then
    echo "[ERROR] Update failed."
    exit 1
fi

chmod +x "$TARGET"

echo
echo "[OK] PortCheck updated successfully."
echo
echo "Source : $SOURCE"
echo "Target : $TARGET"
echo
echo "Run:"
echo "  portcheck"
echo

