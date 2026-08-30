# dotfiles

**تنظیمات ترمینال شخصی M.Soleimani برای چند محیط**
**M.Soleimani's personal terminal dotfiles for multiple environments**

---

## 📖 معرفی / Overview

این مخزن شامل تنظیمات (dotfiles) محیط ترمینالی است که روی سه دسته محیط قابل نصب است:
This repo contains terminal environment dotfiles installable across three environment categories:

- **گوشی — Kali NetHunter:** Redmi Note 8 Pro با Kali Linux روی proot/chroot و Termux
  **Phone — Kali NetHunter:** Redmi Note 8 Pro running Kali Linux via proot/chroot on Termux

- **لپ‌تاپ — Arch Linux:** Dell Inspiron 1525 با Arch Linux و XFCE
  **Laptop — Arch Linux:** Dell Inspiron 1525 running Arch Linux with XFCE

- **هر توزیع دیگر — عمومی:** Ubuntu، Debian، Fedora، openSUSE و مشابه (تشخیص خودکار پکیج‌منیجر)
  **Any other distro — Generic:** Ubuntu, Debian, Fedora, openSUSE, etc. (auto-detects package manager)

---

## ✨ ویژگی‌های کلیدی / Key Features

- تشخیص خودکار محیط (کالی proot / آرچ / هر لینوکس دیگر) و اجرای نصب‌کننده‌ی مناسب
  Automatic environment detection (Kali proot / Arch / any other Linux) with matching installer

- پشتیبانی از چند پکیج‌منیجر: `apt`, `pacman`, `dnf`, `zypper`
  Support for multiple package managers: `apt`, `pacman`, `dnf`, `zypper`

- کانفیگ‌ها با **symlink** لینک می‌شوند نه کپی — هر تغییری مستقیم در ریپو هم اعمال می‌شود
  Configs are **symlinked**, not copied — any change is directly reflected in the repo

- ابزارهای GitHub (yazi, lazygit, zoxide, fzf, starship) همیشه آخرین نسخه را می‌گیرند و در صورت
  به‌روز بودن، دانلود مجدد رد می‌شود
  GitHub tools (yazi, lazygit, zoxide, fzf, starship) always fetch the latest release and skip
  re-downloading if already up to date

- تنظیمات mirror و فیکس‌های proot کالی فقط با **تأیید صریح شما** در حین نصب اجرا می‌شوند، نه
  خودکار روی هر سیستم apt
  Kali mirror setup and proot fixes only run with **your explicit confirmation** during install,
  never automatically on any apt system

- پشتیبانی از تنظیمات شخصی و خصوصی (مثل alias های SSH) از طریق `~/.zshrc.local` که هرگز به
  گیت اضافه نمی‌شود
  Support for personal/private settings (e.g. SSH aliases) via `~/.zshrc.local`, which is never
  committed to git

---

## 🛠️ ابزارهای نصب‌شده / Installed Tools

| ابزار / Tool | کاربرد / Purpose | منبع / Source |
|---|---|---|
| **yazi** | فایل‌منیجر ترمینالی سریع / Fast terminal file manager | GitHub releases |
| **starship** | پرامپت سفارشی با تم Catppuccin / Custom prompt, Catppuccin theme | GitHub releases |
| **lazygit** | رابط گرافیکی TUI برای git / Git TUI | GitHub releases |
| **zoxide** | پرش هوشمند بین دایرکتوری‌ها / Smart directory jumping | GitHub releases |
| **fzf** | جستجوی فازی فایل و تاریخچه / Fuzzy file & history search | GitHub releases |
| **eza** | جایگزین مدرن ls با آیکون / Modern ls replacement with icons | apt/pacman/dnf/zypper |
| **bat** | جایگزین cat با syntax highlighting / Modern cat with syntax highlighting | apt/pacman/dnf/zypper |
| **ncdu** | آنالیز تعاملی فضای دیسک / Interactive disk usage analyzer | apt/pacman/dnf/zypper |
| **btop** | مانیتور منابع سیستم / System resource monitor | pacman (فقط آرچ / Arch only) |
| **shellcheck** | لینتر اسکریپت‌های bash/zsh / bash/zsh script linter | apt/pacman/dnf/zypper |
| **tealdeer** | خلاصه‌ی کاربردی man pages / Fast tldr client | apt/pacman/dnf/zypper |
| **tmux** | مولتی‌پلکسر ترمینال / Terminal multiplexer | apt/pacman/dnf/zypper |
| **neovim** | ادیتور اصلی / Primary editor | apt/pacman/dnf/zypper |
| **ripgrep** | جستجوی سریع متن در فایل‌ها / Fast text search | apt/pacman/dnf/zypper |
| **zsh-autosuggestions** | پیشنهاد خودکار دستورات / Command autosuggestions | apt/pacman |
| **zsh-syntax-highlighting** | رنگی‌کردن نحو دستورات / Command syntax highlighting | apt/pacman |

---

## 📂 مسیر کانفیگ‌ها / Config Paths

| کانفیگ / Config | مسیر / Path | توضیح / Description |
|---|---|---|
| yazi | `~/.config/yazi/` | فایل‌منیجر با تم Catppuccin Mocha / File manager, Catppuccin Mocha theme |
| starship | `~/.config/starship.toml` | پرامپت با تم Catppuccin Powerline / Prompt, Catppuccin Powerline theme |
| zsh | `~/.zshrc` | ورودی Zsh مخصوص محیط که ماژول‌های مشترک را بارگذاری می‌کند / Environment-specific Zsh entrypoint loading shared modules |
| زخصوصی / private | `~/.zshrc.local` (اختیاری / optional) | تنظیمات شخصی، هرگز کامیت نمی‌شود / Personal settings, never committed |

---

## ⌨️ کلیدهای سفارشی yazi / yazi Keybindings

| کلید / Key | عملکرد / Action |
|---|---|
| `h j k l` | ناوبری (vim-style) / Navigate (vim-style) |
| `Enter` | ورود هوشمند / Smart enter (dir or open file) |
| `f` | جستجوی فازی فایل با fzf / Fuzzy find with fzf |
| `z` | پرش با zoxide / Jump with zoxide |
| `g g` | باز کردن lazygit / Open lazygit |
| `g h` | رفتن به home / Go home |
| `g c` | رفتن به ~/.config / Go to ~/.config |
| `T` | تغییر دسترسی فایل (chmod) / Chmod selected files |
| `Ctrl+d` | مقایسه‌ی دو فایل / Diff files |
| `Space` | انتخاب فایل / Select file |
| `y / x / p` | کپی / برش / چسباندن / Yank / Cut / Paste |
| `u` | لغو انتخاب / Cancel selection |
| `q` | خروج / Quit |

---

## 📥 نصب / Installation

### اولین نصب / First Install

```bash
git clone https://github.com/msoleimani62/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

اسکریپت محیط را خودکار تشخیص می‌دهد (کالی proot / آرچ / هر لینوکس دیگر) و نصب‌کننده‌ی مناسب را اجرا می‌کند.
The script auto-detects the environment (Kali proot / Arch / any other Linux) and runs the matching installer.

> اگر داخل proot کالی هستید، حین نصب یک سؤال درباره‌ی فعال‌سازی فیکس mirror/dpkg پرسیده می‌شود. روی سایر توزیع‌ها این سؤال پرسیده نمی‌شود.
> If you're inside Kali proot, you'll be asked during install whether to enable the mirror/dpkg fix. This question doesn't appear on other distros.

### آپدیت به آخرین نسخه‌ها / Update to Latest

```bash
cd ~/dotfiles
git pull
bash install.sh
```

---

## 🔁 رفتار نصب و آپدیت / Install & Update Behavior

اسکریپت نصب، نسخه‌ی نصب‌شده را در فایلی بیرون از ریپو ذخیره می‌کند (`~/.local/share/dotfiles/.version`):
The installer stores the installed version in a file outside the repository (`~/.local/share/dotfiles/.version`):

- در هر اجرای `bash install.sh`، محیط دوباره تشخیص داده می‌شود و installer مربوط به آن اجرا می‌شود.
  Every `bash install.sh` invocation detects the environment again and runs the matching installer.

- نسخه‌ی نصب‌شده و نسخه‌ی هدف فقط برای گزارش وضعیت نگهداری می‌شوند و باعث skip کردن نصب نمی‌شوند.
  The installed and target versions are informational and do not cause the installation to be skipped.

- اجرای دوباره‌ی installer برای اعمال تغییرات جدید، اصلاح configurationها و اطمینان از idempotent بودن مراحل نصب مجاز و مورد انتظار است.
  Re-running the installer is supported and expected when applying configuration changes or validating installer idempotency.

- فایل version هرگز داخل ریپو نیست و بنابراین باعث تغییر در `git status` نمی‌شود.
  The version file is never stored inside the repository, so it does not affect `git status`.

---
## 🔒 تنظیمات شخصی و خصوصی / Personal & Private Settings

هیچ IP، یوزرنیم یا اطلاعات شبکه‌ی خصوصی در این ریپو وجود ندارد. برای alias های شخصی (مثل SSH به دستگاه‌های دیگر خودتان):
No IPs, usernames, or private network info live in this repo. For personal aliases (e.g. SSH to your own other devices):

```bash
cp configs/zsh/.zshrc.local.example ~/.zshrc.local
nvim ~/.zshrc.local
```

`~/.zshrc.local` به‌طور خودکار توسط ماژول `50-local.zsh` لود می‌شود و هرگز بخشی از این ریپو نیست.
`~/.zshrc.local` is automatically loaded by the `50-local.zsh` module and is never part of this repo.

---

## 🗂️ ساختار پروژه / Project Structure

```
dotfiles/
├── install.sh                       ← نقطه‌ی ورود اصلی / Main entry point
├── README.md                        ← این فایل / This file
├── .gitignore
│
├── environments/
│   ├── kali-phone/
│   │   ├── install.sh              ← نصب محیط گوشی / Phone install
│   │   └── README.md
│   ├── arch-laptop/
│   │   ├── install.sh              ← نصب محیط لپ‌تاپ / Laptop install
│   │   └── README.md
│   └── generic-linux/
│       ├── install.sh              ← نصب هر توزیع دیگر / Any other distro install
│       └── README.md
│
├── configs/
│   ├── yazi/                       ← کانفیگ yazi (مشترک) / yazi config (shared)
│   │   ├── yazi.toml
│   │   ├── keymap.toml
│   │   ├── theme.toml
│   │   └── init.lua
│   ├── starship.toml               ← کانفیگ starship (مشترک) / starship config (shared)
│   └── zsh/
│       ├── environments/
│       │   ├── kali-phone.zsh       ← ورودی Kali / Kali entrypoint
│       │   ├── arch-laptop.zsh      ← ورودی Arch / Arch entrypoint
│       │   └── generic.zsh          ← ورودی عمومی / Generic entrypoint
│       ├── modules/
│       │   ├── 00-core.zsh          ← هسته مشترک / Shared core
│       │   ├── 10-path.zsh          ← مدیریت PATH / PATH management
│       │   ├── 20-completion.zsh    ← تکمیل دستورات / Completion
│       │   ├── 30-tools.zsh         ← ابزارها / Tools
│       │   ├── 40-aliases.zsh       ← aliasها / Aliases
│       │   ├── 50-local.zsh         ← تنظیمات خصوصی / Private settings
│       │   ├── 90-plugins.zsh       ← پلاگین‌ها / Plugins
│       │   └── loader.zsh            ← بارگذار ماژول‌ها / Module loader
│       └── .zshrc.local.example     ← نمونه تنظیمات خصوصی / Private settings template
│
└── scripts/
    ├── install_binaries.sh         ← دانلود باینری از GitHub / GitHub binary downloads
    ├── install_apt.sh              ← نصب apt (کالی/دبیان/اوبونتو) / apt install (Kali/Debian/Ubuntu)
    ├── install_pacman.sh           ← نصب pacman (آرچ) / pacman install (Arch)
    ├── install_dnf.sh              ← نصب dnf (فدورا/RHEL) / dnf install (Fedora/RHEL)
    ├── install_zypper.sh           ← نصب zypper (openSUSE) / zypper install (openSUSE)
    └── link_configs.sh             ← ساخت symlink کانفیگ‌ها / Symlink configs
```

---

## 📝 نکات مهم / Important Notes

- کانفیگ‌ها با **symlink** به مسیر اصلی وصل می‌شن، نه کپی — یعنی هر تغییری مستقیم در ریپو هم اعمال می‌شه و فقط یک `git push` لازمه
  Configs are **symlinked**, not copied — any edit is directly reflected in the repo, just needs a `git push`

- اسکریپت نصب محیط را خودکار تشخیص می‌دهد (کالی proot / آرچ / هر لینوکس دیگر)
  The installer auto-detects the environment (Kali proot / Arch / any other Linux)

- ابزارهایی که از GitHub نصب می‌شن همیشه آخرین نسخه رو می‌گیرن و اگه از قبل نصب باشن و نسخه‌شون یکسان باشه، بدون دانلود مجدد رد می‌شن
  GitHub-installed tools always fetch the latest version and skip re-downloading if already up to date

- تنظیمات mirror و فیکس proot کالی هرگز بدون تأیید صریح شما روی هیچ سیستمی اجرا نمی‌شود
  Kali mirror and proot fixes never run on any system without your explicit confirmation

---

## 📋 مجوز / License

MIT — استفاده و تغییر آزاد است.
MIT — Feel free to use and adapt.

---

**توسعه‌دهنده / Developer:** msoleimani62
