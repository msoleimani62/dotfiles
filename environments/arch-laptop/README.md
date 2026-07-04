# محیط Arch Linux (لپ‌تاپ) / Arch Linux (Laptop) Environment

## مشخصات / Specs

- دستگاه / Device: Dell Inspiron 1525
- سیستم‌عامل / OS: Arch Linux with XFCE
- رابط گرافیکی / GUI: startx + XFCE4
- ترمینال / Terminal: Alacritty با تم Catppuccin Mocha / with Catppuccin Mocha theme

## مزایای این محیط نسبت به گوشی / Advantages over the Phone Environment

- `btop` کاملاً قابل استفاده است / `btop` is fully usable
- پیش‌نمایش تصویر/ویدیو در yazi به‌طور کامل کار می‌کند / Image/video preview in yazi works fully
- تمام ابزارها مستقیم از `pacman` با نام اصلی نصب می‌شوند (بدون alias)
  All tools install directly via `pacman` under their real names (no alias needed)
- سرعت کامپایل و اجرا بسیار بیشتر از گوشی است / Much faster compile/run speed than the phone

## اجرای نصب دستی / Manual Install

```bash
bash environments/arch-laptop/install.sh
```
