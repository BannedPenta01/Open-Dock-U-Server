#!/usr/bin/env bash
#
# Pretendo Network Server - Debian/Ubuntu Startup Script
# Builds and starts: Splatoon, Super Smash Bros. Wii U, Pokken Tournament, Mario Kart 8
# Mario Kart 7 support is DISABLED.
#
# Usage: sudo bash build_debian.sh
#   or:  chmod +x build_debian.sh && sudo ./build_debian.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error()   { echo -e "${RED}[✗]${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_info()    { echo -e "${CYAN}[i]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
cd "$SCRIPT_DIR"

echo ""
echo "========================================"
echo "  Pretendo Network Server - Quick Start"
echo "  (Mario Kart 7 DISABLED)"
echo ""
echo "  Enabled games:"
echo "    - Splatoon"
echo "    - Super Smash Bros. Wii U"
echo "    - Pokken Tournament"
echo "    - Mario Kart 8"
echo "========================================"
echo ""

# --------------------------------------------------
# Step 1: Check prerequisites
# --------------------------------------------------
print_info "Checking prerequisites..."

if ! command -v git &>/dev/null; then
    print_error "Git is not installed."
    echo "  Install: sudo apt update && sudo apt install -y git"
    exit 1
fi

if ! command -v docker &>/dev/null; then
    print_error "Docker is not installed."
    echo "  Install: curl -fsSL https://get.docker.com | sh"
    echo "  Then add your user: sudo usermod -aG docker \$USER && newgrp docker"
    exit 1
fi

if ! docker info &>/dev/null; then
    print_error "Docker daemon is not running or your user is not in the docker group."
    echo "  Start Docker: sudo systemctl enable --now docker"
    echo "  Or re-login after: sudo usermod -aG docker \$USER"
    exit 1
fi

if ! docker compose version &>/dev/null; then
    print_error "Docker Compose plugin is not installed."
    echo "  Install: sudo apt update && sudo apt install -y docker-compose-plugin"
    exit 1
fi

print_success "All prerequisites are installed."

# --------------------------------------------------
# Step 2: Reset and update submodules
# --------------------------------------------------
print_info "Resetting and updating git submodules..."

git submodule foreach --recursive "git reset --hard" 2>/dev/null || true
git submodule foreach --recursive "git clean -fd" 2>/dev/null || true

if ! git submodule update --init --checkout; then
    print_warning "Submodule update encountered issues. Retrying with force..."
    git submodule foreach --recursive "git reset --hard" 2>/dev/null || true
    git submodule foreach --recursive "git clean -fdx" 2>/dev/null || true
    git submodule update --init --checkout 2>/dev/null || true
fi

print_success "Submodules are ready."

# --------------------------------------------------
# Step 3: Build images for target game services
# --------------------------------------------------
echo ""
print_info "Building Docker images for:"
echo "    - splatoon"
echo "    - super-smash-bros-wiiu"
echo "    - pokken-tournament"
echo "    - mario-kart-8"
echo "  (Mario Kart 7 is disabled in compose.yml)"
echo ""

TARGET_SERVICES="splatoon super-smash-bros-wiiu pokken-tournament mario-kart-8"

if docker compose build $TARGET_SERVICES; then
    print_success "Docker images built successfully."
else
    print_warning "Build had some issues, continuing..."
fi

# --------------------------------------------------
# Step 4: Start containers
# --------------------------------------------------
echo ""
print_info "Starting Docker containers..."
echo "  (Infrastructure services will start automatically via depends_on)"
echo ""

if docker compose up -d $TARGET_SERVICES; then
    print_success "Docker containers started successfully!"
else
    print_error "Failed to start Docker containers."
    echo "  Check logs: docker compose logs"
    exit 1
fi

# --------------------------------------------------
# Step 5: Verify running containers
# --------------------------------------------------
echo ""
print_info "Running containers:"
docker compose ps

echo ""
echo "========================================"
echo -e "  ${GREEN}Server is running!${NC}"
echo ""
echo "  Access the web interface at:"
echo "    http://localhost"
echo ""
echo "  Enabled games:"
echo "    - Splatoon"
echo "    - Super Smash Bros. Wii U"
echo "    - Pokken Tournament"
echo "    - Mario Kart 8"
echo ""
echo "  Useful commands:"
echo "    View logs:       docker compose logs -f"
echo "    Stop server:     docker compose down"
echo "    Restart server:  docker compose restart"
echo "    Start more:      docker compose up -d [service-name]"
echo "========================================"