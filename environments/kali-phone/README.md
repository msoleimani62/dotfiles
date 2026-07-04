# محیط Kali NetHunter (گوشی) / Kali NetHunter (Phone) Environment

## مشخصات / Specs

- دستگاه / Device: Redmi Note 8 Pro (begonia)
- سیستم‌عامل / OS: Android + Termux + Kali NetHunter proot
- معماری / Architecture: aarch64 (ARM64)

## نکات خاص این محیط / Environment-specific Notes

- `btop` در این محیط به‌دلیل محدودیت `/proc` در proot کار نمی‌کند؛ از `top` یا `htop` استفاده شود
  `btop` doesn't work here due to `/proc` restrictions in proot; use `top` or `htop` instead

- پیش‌نمایش تصویر در yazi به‌دلیل محدودیت پروتکل‌های گرافیکی در proot در دسترس نیست
  Image preview in yazi isn't available due to graphics protocol limitations in proot

- `bat` به‌صورت `batcat` نصب می‌شود و اسکریپت نصب به‌صورت خودکار symlink می‌سازد
  `bat` installs as `batcat`; the install script automatically creates a symlink

- `fd` به‌صورت `fdfind` نصب می‌شود و اسکریپت نصب به‌صورت خودکار symlink می‌سازد
  `fd` installs as `fdfind`; the install script automatically creates a symlink

- تنظیم mirror و رفع مشکل dpkg در proot فقط با تأیید صریح شما در حین نصب انجام می‌شود
  (سؤال «آیا داخل proot کالی هستید؟» در `scripts/install_apt.sh`)
  Mirror setup and the proot dpkg fix only run with your explicit confirmation during
  install (the "Running inside Kali NetHunter proot?" prompt in `scripts/install_apt.sh`)

## اجرای نصب دستی / Manual Install

```bash
bash environments/kali-phone/install.sh
```
