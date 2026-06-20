-- ============================================================
-- THÊM BẢNG QUẢN LÝ QUẢN TRỊ VIÊN
-- Chạy toàn bộ script này trong Supabase SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS public.admin_profiles (
    id         UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name  TEXT        NOT NULL,
    email      TEXT        NOT NULL,
    role       TEXT        NOT NULL DEFAULT 'Biên tập viên'
               CHECK (role IN ('Quản trị viên', 'Biên tập viên')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.admin_profiles ENABLE ROW LEVEL SECURITY;

-- Chỉ người đã đăng nhập (admin) mới đọc/ghi được bảng này
CREATE POLICY "auth_read_profiles"   ON public.admin_profiles FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "auth_insert_profiles" ON public.admin_profiles FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "auth_delete_profiles" ON public.admin_profiles FOR DELETE USING (auth.role() = 'authenticated');

-- ============================================================
-- BƯỚC BẮT BUỘC: Thêm tài khoản admin HIỆN TẠI của bạn
-- Bỏ dấu -- ở 3 dòng INSERT bên dưới, thay email rồi chạy lại
-- ============================================================
INSERT INTO public.admin_profiles (id, full_name, email, role)
SELECT id, 'Diệp Thành Luân', email, 'Quản trị viên'
FROM auth.users WHERE email = 'diepthanhluan83@gmail.com';

INSERT INTO public.admin_profiles (id, full_name, email, role)
SELECT id, 'Nguyệt Nguyễn', email, 'Quản trị viên'
FROM auth.users WHERE email = 'nguyetnguyenldld@gmail.com';
