# محیط عمومی لینوکس / Generic Linux Environment

## مناسب برای / Suitable for

هر توزیع لینوکسی غیر از Kali NetHunter proot و Arch Linux — مثل Ubuntu، Debian خالص،
Fedora، RHEL، CentOS، openSUSE، Linux Mint، Pop!_OS و مشابه.

Any Linux distro other than Kali NetHunter proot and Arch Linux — e.g. Ubuntu,
plain Debian, Fedora, RHEL, CentOS, openSUSE, Linux Mint, Pop!_OS, and similar.

## چطور کار می‌کند / How it Works

اسکریپت نصب پکیج‌منیجر موجود روی سیستم شما را خودکار تشخیص می‌دهد (`apt`, `dnf`,
`zypper`, یا `pacman`) و اسکریپت نصب مناسب را اجرا می‌کند. هیچ mirror یا فیکس
مخصوص proot اینجا اعمال نمی‌شود — این‌ها فقط مخصوص محیط Kali NetHunter proot هستند.

The installer auto-detects the package manager on your system (`apt`, `dnf`,
`zypper`, or `pacman`) and runs the matching install script. No mirror changes
or proot-specific fixes are applied here — those are Kali NetHunter proot-only.

## اجرای نصب دستی / Manual Install

```bash
bash environments/generic-linux/install.sh
```

## محدودیت‌ها / Limitations

- `btop` فقط از طریق pacman/apt نصب می‌شود؛ روی dnf/zypper ممکن است نیاز به مخزن
  اضافه داشته باشد
  `btop` is only in the pacman/apt package lists; on dnf/zypper it may need an
  extra repo enabled

- بعضی نام پکیج‌ها بین توزیع‌ها فرق دارد و ممکن است نصب بعضی ابزارها fail شود؛
  اسکریپت این موارد را با هشدار رد می‌کند نه با توقف کامل
  Some package names differ between distros and a few tools may fail to install;
  the script skips these with a warning rather than stopping entirely
