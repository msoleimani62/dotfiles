if command -v apt >/dev/null 2>&1; then
    alias update="sudo apt update && sudo apt upgrade"
elif command -v dnf >/dev/null 2>&1; then
    alias update="sudo dnf upgrade"
elif command -v zypper >/dev/null 2>&1; then
    alias update="sudo zypper update"
elif command -v pacman >/dev/null 2>&1; then
    alias update="sudo pacman -Syu"
fi
