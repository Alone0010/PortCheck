#!/data/data/com.termux/files/usr/bin/bash

APP_NAME="PortCheck"
VERSION="1.1.0"
INSTALL_DIR="$HOME/.portcheck"
BIN_DIR="$PREFIX/bin"

echo
echo "================================"
echo "       $APP_NAME v$VERSION"
echo "       Installation"
echo "================================"
echo

mkdir -p "$INSTALL_DIR"

cp portcheck.sh "$INSTALL_DIR/portcheck.sh"
chmod +x "$INSTALL_DIR/portcheck.sh"

cat > "$BIN_DIR/portcheck" <<'LAUNCHER'
#!/data/data/com.termux/files/usr/bin/bash

exec "$HOME/.portcheck/portcheck.sh" "$@"
LAUNCHER

chmod +x "$BIN_DIR/portcheck"

echo "[OK] PortCheck installed."
echo
echo "Run the tool with:"
echo
echo "  portcheck"
echo

