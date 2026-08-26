#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log_info() {
    printf '%b\n' "${CYAN}[INFO]${RESET} $*"
}

log_success() {
    printf '%b\n' "${GREEN}[✓]${RESET} $*"
}

log_warn() {
    printf '%b\n' "${YELLOW}[!]${RESET} $*"
}

log_error() {
    printf '%b\n' "${RED}[✗]${RESET} $*"
}

log_section() {
    printf '\n%b\n' "${BOLD}${BLUE}════════════════════════════════════════════════════════════${RESET}"
    printf '%b%s\n' "${BOLD}${BLUE}  ${RESET}" "$*"
    printf '%b\n\n' "${BOLD}${BLUE}════════════════════════════════════════════════════════════${RESET}"
}

die() {
    log_error "$*"
    exit 1
}

detect_environment() {
    if [ -f /etc/kali_version ] || grep -qi 'kali' /etc/os-release 2>/dev/null; then
        printf '%s\n' 'kali'
    elif [ -f /etc/arch-release ]; then
        printf '%s\n' 'arch'
    else
        printf '%s\n' 'generic'
    fi
}

detect_package_manager() {
    if command -v apt >/dev/null 2>&1; then
        printf '%s\n' 'apt'
    elif command -v pacman >/dev/null 2>&1; then
        printf '%s\n' 'pacman'
    elif command -v dnf >/dev/null 2>&1; then
        printf '%s\n' 'dnf'
    elif command -v zypper >/dev/null 2>&1; then
        printf '%s\n' 'zypper'
    else
        printf '%s\n' 'none'
    fi
}

detect_arch() {
    case "$(uname -m)" in
        x86_64)
            printf '%s\n' 'x86_64'
            ;;
        aarch64)
            printf '%s\n' 'aarch64'
            ;;
        armv7l|armv7*)
            printf '%s\n' 'armv7'
            ;;
        *)
            printf '%s\n' 'unknown'
            ;;
    esac
}

get_login_shell() {
    local shell_path

    shell_path="$(getent passwd "${USER:-$(id -un)}" 2>/dev/null | cut -d: -f7 || true)"

    if [ -n "$shell_path" ]; then
        printf '%s\n' "$shell_path"
        return 0
    fi

    printf '%s\n' "${SHELL:-}"
}

backup_path() {
    local path="$1"
    local backup
    local timestamp
    local counter

    if [ ! -e "$path" ] && [ ! -L "$path" ]; then
        return 0
    fi

    timestamp="$(date +%Y%m%d-%H%M%S)"
    backup="${path}.backup.${timestamp}"
    counter=1

    while [ -e "$backup" ] || [ -L "$backup" ]; do
        backup="${path}.backup.${timestamp}.${counter}"
        counter=$((counter + 1))
    done

    mv -- "$path" "$backup"
    log_warn "Backed up $path -> $backup"
}

make_link() {
    local src="$1"
    local dst="$2"

    [ -e "$src" ] || [ -L "$src" ] || die "Source does not exist: $src"

    mkdir -p "$(dirname "$dst")"

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
            log_success "Already linked: $dst -> $src"
            return 0
        fi

        backup_path "$dst"
    fi

    ln -s -- "$src" "$dst"
    log_success "Linked: $dst -> $src"
}

require_commands() {
    local missing=()
    local command_name

    for command_name in "$@"; do
        if ! command -v "$command_name" >/dev/null 2>&1; then
            missing+=("$command_name")
        fi
    done

    if [ "${#missing[@]}" -gt 0 ]; then
        die "Missing required commands: ${missing[*]}"
    fi
}

atomic_install_file() {
    local src="$1"
    local dst="$2"
    local mode="${3:-755}"
    local tmp

    mkdir -p "$(dirname "$dst")"

    tmp="$(mktemp "${dst}.tmp.XXXXXX")"
    cp -- "$src" "$tmp"
    chmod "$mode" "$tmp"
    mv -f -- "$tmp" "$dst"
}
