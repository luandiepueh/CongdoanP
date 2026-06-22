# Công Đoàn Cơ Sở — Developer Guide

## Tech Stack
- **Frontend:** HTML5 + Bootstrap 5 (CDN) + JavaScript thuần
- **Backend/DB:** Supabase (PostgreSQL + Auth + Storage)
- **Hosting:** Cloudflare Pages (static site, auto-deploy từ GitHub)
- **Repo GitHub:** https://github.com/luandiepueh/Congdoancauonglanh
- **URL live:** https://congdoanp.pages.dev

## Cấu trúc thư mục
```
congdoan-supabase/
├── index.html              # Trang chủ công khai
├── thong-bao.html          # Trang thông báo công khai
├── tai-lieu.html           # Trang tài liệu công khai
├── gop-y.html              # Form góp ý công khai
├── admin/
│   ├── login.html          # Đăng nhập admin
│   ├── index.html          # Dashboard admin
│   ├── thong-bao.html      # Quản lý thông báo (Quill editor)
│   ├── tai-lieu.html       # Quản lý tài liệu
│   ├── gop-y.html          # Quản lý + phản hồi góp ý
│   └── quan-tri-vien.html  # Quản lý tài khoản admin
├── js/
│   └── config.js           # Supabase client + utils dùng chung
├── css/
│   └── style.css           # CSS toàn app
├── _headers                # Security headers cho Cloudflare Pages
├── setup.sql               # Schema gốc (đã chạy 1 lần)
└── setup_admin_profiles.sql # Thêm bảng admin_profiles (đã chạy)
```

## Supabase
- **Project URL:** https://adcqrxupqlluqyffsykw.supabase.co
- **Config:** `js/config.js` — chứa SUPABASE_URL, SUPABASE_ANON_KEY, APP_CONFIG
- **Tables:** `announcements`, `documents`, `feedback`, `admin_profiles`
- **Storage buckets:** `tai-lieu` (50MB, Office/PDF), `attachments` (10MB, mọi loại)
- **Auth:** Email + Password. Mọi `authenticated` user đều có quyền ghi.

### Bảng admin_profiles
Kiểm soát ai được vào trang admin. Logic trong `requireAdmin()` (config.js):
- Nếu bảng **rỗng** → chế độ bootstrap, mọi tài khoản Supabase đều vào được
- Nếu bảng **có data** → chỉ email có trong `admin_profiles` mới đăng nhập được admin

### Thêm admin mới
**Cách 1 (từ web):** Đăng nhập admin → Hệ thống → Quản trị viên → Thêm quản trị viên  
**Cách 2 (SQL):** Chạy trong Supabase SQL Editor:
```sql
INSERT INTO public.admin_profiles (id, full_name, email, role)
SELECT id, 'Tên Người Dùng', email, 'Quản trị viên'
FROM auth.users WHERE email = 'email@example.com';
```

## Workflow phát triển

### Xem trước giao diện (không cần deploy)
1. Cài VS Code extension **Live Server** (của Ritwick Dey)
2. Mở thư mục `congdoan-supabase` trong VS Code
3. Chuột phải vào file HTML → **Open with Live Server**
4. Browser mở `http://127.0.0.1:5500/...` và tự refresh khi save file
5. Supabase là cloud nên data vẫn hoạt động bình thường từ localhost

### Deploy lên web (sau khi sửa xong)
```bash
git add .
git commit -m "mô tả thay đổi"
git push
```
Cloudflare Pages tự deploy trong ~30–60 giây. Kiểm tra tại https://congdoanp.pages.dev.

## Cloudflare Pages
- Project kết nối với GitHub repo `luandiepueh/Congdoancauonglanh`, branch `main`
- Build command: *(để trống — không cần build)*
- Build output directory: `/` (root)
- File `_headers` khai báo security headers (X-Frame-Options, Cache-Control admin, v.v.)
- Để đổi domain: Cloudflare Dashboard → Pages → congdoanp → Custom domains

## Phân quyền vai trò
| Vai trò | Quyền |
|---|---|
| Quản trị viên | Toàn quyền, bao gồm quản lý tài khoản admin |
| Biên tập viên | Đăng thông báo, thêm tài liệu, trả lời góp ý |

## Tài khoản admin hiện tại
- diepthanhluan83@gmail.com — Quản trị viên
- nguyetnguyenldld@gmail.com — Quản trị viên
