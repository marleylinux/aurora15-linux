#!/usr/bin/env bash
# ==============================================================================
# Aurora 15 - Automated Setup for Arch Linux (via Bottles)
# ==============================================================================
set -euo pipefail

# Visual Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

BOTTLE_NAME="${BOTTLE_NAME:-FIFA 15}"

echo -e "${CYAN}${BOLD}"
echo "=========================================================="
echo "         Aurora 15 - Arch Linux Setup (Bottles)           "
echo "=========================================================="
echo -e "${NC}"

# 1. System & Tool Verification (Arch Linux Only)
echo -e "${YELLOW}[1/4] Checking Arch Linux prerequisites...${NC}"

if [[ ! -f /etc/arch-release ]]; then
    echo -e "${RED}Warning: This script is tailored specifically for Arch Linux.${NC}"
fi

if ! command -v bottles-cli &>/dev/null; then
    echo -e "${RED}Error: 'bottles-cli' is not installed.${NC}"
    echo "Install it via pacman:"
    echo "  sudo pacman -S bottles"
    exit 1
fi

if ! command -v wine &>/dev/null; then
    echo -e "${YELLOW}Notice: 'wine' package not detected. Installing it is recommended:${NC}"
    echo "  sudo pacman -S wine"
fi
echo -e "${GREEN}✓ Arch Linux prerequisites verified.${NC}"

# 2. Locate FIFA 15 Installation
echo -e "\n${YELLOW}[2/4] Locating FIFA 15 game files...${NC}"
GAME_DIR="${1:-}"

if [[ -z "$GAME_DIR" ]]; then
    CANDIDATES=(
        "$HOME/Games/FIFA 15"
        "$PWD"
    )
    for c in "${CANDIDATES[@]}"; do
        if [[ -f "$c/Aurora.exe" && -f "$c/fifa15.exe" ]]; then
            GAME_DIR="$c"
            break
        fi
    done
fi

if [[ -z "$GAME_DIR" || ! -f "$GAME_DIR/Aurora.exe" || ! -f "$GAME_DIR/fifa15.exe" ]]; then
    echo -e "${YELLOW}Please enter the path to your 'FIFA 15' directory:${NC}"
    read -r -p "Game Path: " USER_INPUT_PATH
    GAME_DIR="${USER_INPUT_PATH/#\~/$HOME}"
fi

if [[ ! -f "$GAME_DIR/Aurora.exe" || ! -f "$GAME_DIR/fifa15.exe" ]]; then
    echo -e "${RED}Error: Could not find 'Aurora.exe' and 'fifa15.exe' in:${NC} $GAME_DIR"
    exit 1
fi
echo -e "${GREEN}✓ Game files verified in:${NC} $GAME_DIR"

# 3. Create or Verify Bottle
echo -e "\n${YELLOW}[3/4] Configuring Gaming Bottle '${BOTTLE_NAME}'...${NC}"
EXISTING_BOTTLES=$(bottles-cli list bottles 2>/dev/null || true)

if echo "$EXISTING_BOTTLES" | grep -q -F "$BOTTLE_NAME"; then
    echo -e "${GREEN}✓ Bottle '${BOTTLE_NAME}' already exists.${NC}"
else
    echo "Creating 64-bit Gaming Bottle..."
    bottles-cli new --bottle-name "$BOTTLE_NAME" --environment gaming --arch win64
    echo -e "${GREEN}✓ Bottle created.${NC}"
fi

BOTTLES_BASE="$HOME/.local/share/bottles/bottles"
SANITIZED_NAME="${BOTTLE_NAME// /-}"
BOTTLE_PATH=""

if [[ -d "$BOTTLES_BASE/$SANITIZED_NAME" ]]; then
    BOTTLE_PATH="$BOTTLES_BASE/$SANITIZED_NAME"
elif [[ -d "$BOTTLES_BASE/$BOTTLE_NAME" ]]; then
    BOTTLE_PATH="$BOTTLES_BASE/$BOTTLE_NAME"
else
    BOTTLE_PATH=$(find "$BOTTLES_BASE" -maxdepth 1 -iname "*$(echo "$SANITIZED_NAME" | tr '[:upper:]' '[:lower:]')*" | head -n 1)
fi

if [[ -z "$BOTTLE_PATH" || ! -d "$BOTTLE_PATH" ]]; then
    echo -e "${RED}Error: Could not find bottle directory in $BOTTLES_BASE${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Bottle prefix:${NC} $BOTTLE_PATH"

# 4. Critical DLL Override & Dependencies
echo -e "\n${YELLOW}[4/4] Setting 'dinput8' override & shortcuts...${NC}"
# Set override in registry
bottles-cli reg add -b "$BOTTLE_NAME" -k 'HKCU\Software\Wine\DllOverrides' -v 'dinput8' -d 'native,builtin' -t REG_SZ >/dev/null 2>&1 || true

# Set override in bottle.yml for GUI sync
BOTTLE_YML="$BOTTLE_PATH/bottle.yml"
if [[ -f "$BOTTLE_YML" ]]; then
    python3 -c "
path = '$BOTTLE_YML'
with open(path, 'r') as f:
    c = f.read()
if 'dinput8: native,builtin' not in c:
    if 'DLL_Overrides: {}' in c:
        c = c.replace('DLL_Overrides: {}', 'DLL_Overrides:\n    dinput8: native,builtin')
    elif 'DLL_Overrides:' in c:
        c = c.replace('DLL_Overrides:\n', 'DLL_Overrides:\n    dinput8: native,builtin\n')
    with open(path, 'w') as f:
        f.write(c)
"
fi
echo -e "${GREEN}✓ 'dinput8' override set to native,builtin (EA-MITM proxy hooked).${NC}"

# Install local VC++ 2012 runtimes if present
if [[ -d "$GAME_DIR/_Redist" ]]; then
    echo "Installing Microsoft Visual C++ 2012 redistributables..."
    if [[ -f "$GAME_DIR/_Redist/vcredist_x64_2012_x64.exe" ]]; then
        WINEPREFIX="$BOTTLE_PATH" wine "$GAME_DIR/_Redist/vcredist_x64_2012_x64.exe" /quiet /norestart >/dev/null 2>&1 || true
    fi
    if [[ -f "$GAME_DIR/_Redist/vcredist_x86_2012_x86.exe" ]]; then
        WINEPREFIX="$BOTTLE_PATH" wine "$GAME_DIR/_Redist/vcredist_x86_2012_x86.exe" /quiet /norestart >/dev/null 2>&1 || true
    fi
    echo -e "${GREEN}✓ VC++ 2012 runtimes installed.${NC}"
fi

# Register program shortcut
PROGRAMS=$(bottles-cli programs -b "$BOTTLE_NAME" 2>/dev/null || true)
if echo "$PROGRAMS" | grep -q -F "Aurora"; then
    echo -e "${GREEN}✓ 'Aurora' shortcut already present in Bottles.${NC}"
else
    bottles-cli add -b "$BOTTLE_NAME" -n "Aurora" -p "$GAME_DIR/Aurora.exe" >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ 'Aurora' shortcut added to Bottles.${NC}"
fi

echo -e "\n${GREEN}${BOLD}==========================================================${NC}"
echo -e "${GREEN}${BOLD}                 Setup Finished Successfully!             ${NC}"
echo -e "${GREEN}${BOLD}==========================================================${NC}"
echo -e "Launch options:"
echo -e "  • GUI:      Open Bottles -> '${BOTTLE_NAME}' -> click Play on 'Aurora'"
echo -e "  • Terminal: bottles-cli run -b \"${BOTTLE_NAME}\" -p \"Aurora\"\n"
