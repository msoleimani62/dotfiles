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
    printf '\n%b\n' "${BOLD}${BLUE}═══════════════════════════════════════════════════════${RESET}"
    printf '%s\n' "$*"
    printf '%b\n\n' "${BOLD}${BLUE}═══════════════════════════════════════════════════════${RESET}"
}

die() {
    log_error "$*"
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

detect_environment() {
    if [[ -f /etc/kali_version ]] ||
        grep -Eq '^[[:space:]]*(ID|ID_LIKE)=.*kali' /etc/os-release 2>/dev/null; then
        printf '%s\n' 'kali'
    elif [[ -f /etc/arch-release ]]; then
        printf '%s\n' 'arch'
    else
        printf '%s\n' 'generic'
    fi
}

detect_package_manager() {
    if command_exists apt; then
        printf '%s\n' 'apt'
    elif command_exists pacman; then
        printf '%s\n' 'pacman'
    elif command_exists dnf; then
        printf '%s\n' 'dnf'
    elif command_exists zypper; then
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
        aarch64|arm64)
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
    local shell_path=''

    if command_exists getent; then
        shell_path="$(
            getent passwd "${USER:-$(id -un)}" 2>/dev/null |
                cut -d: -f7
        )"
    fi

    if [[ -n "$shell_path" ]]; then
        printf '%s\n' "$shell_path"
    else
        printf '%s\n' "${SHELL:-}"
    fi
}

backup_path() {
    local path="$1"
    local backup
    local timestamp
    local counter=1

    if [[ ! -e "$path" && ! -L "$path" ]]; then
        return 0
    fi

    timestamp="$(date +%Y%m%d-%H%M%S)"
    backup="${path}.backup.${timestamp}"

    while [[ -e "$backup" || -L "$backup" ]]; do
        backup="${path}.backup.${timestamp}.${counter}"
        counter=$((counter + 1))
    done

    mv -- "$path" "$backup" ||
        die "Unable to create backup: $path"

    log_warn "Backed up $path -> $backup"
}

make_link() {
    local src="$1"
    local dst="$2"
    local current_target

    [[ -e "$src" || -L "$src" ]] ||
        die "Source does not exist: $src"

    mkdir -p -- "$(dirname "$dst")"

    if [[ -L "$dst" ]]; then
        current_target="$(readlink -- "$dst")"

        if [[ "$current_target" == "$src" ]]; then
            log_success "Already linked: $dst -> $src"
            return 0
        fi

        backup_path "$dst"
    elif [[ -e "$dst" ]]; then
        backup_path "$dst"
    fi

    ln -s -- "$src" "$dst" ||
        die "Unable to create link: $dst"

    log_success "Linked: $dst -> $src"
}

require_commands() {
    local missing=()
    local command_name

    for command_name in "$@"; do
        if ! command_exists "$command_name"; then
            missing+=("$command_name")
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        die "Missing required commands: ${missing[*]}"
    fi
}

atomic_install_file() {
    local src="$1"
    local dst="$2"
    local mode="${3:-755}"
    local tmp

    [[ -f "$src" ]] ||
        die "Installation source is not a regular file: $src"

    mkdir -p -- "$(dirname "$dst")"

    tmp="$(mktemp "${dst}.tmp.XXXXXX")" ||
        die "Unable to create temporary file: $dst"

    if ! cp -- "$src" "$tmp"; then
        rm -f -- "$tmp"
        die "Unable to copy installation source: $src"
    fi

    if ! chmod "$mode" "$tmp"; then
        rm -f -- "$tmp"
        die "Unable to set permissions on: $dst"
    fi

    if ! mv -f -- "$tmp" "$dst"; then
        rm -f -- "$tmp"
        die "Unable to install file: $dst"
    fi
}
