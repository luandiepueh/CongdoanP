-- ============================================================
-- Chạy 1 lần trong Supabase SQL Editor
-- Cho phép thêm admin từ email đã có sẵn trong auth.users
-- ============================================================
CREATE OR REPLACE FUNCTION add_admin_by_email(
  p_email     TEXT,
  p_full_name TEXT,
  p_role      TEXT DEFAULT 'Biên tập viên'
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_user_id UUID;
BEGIN
  SELECT id INTO v_user_id FROM auth.users WHERE email = p_email LIMIT 1;

  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Email chưa có tài khoản trong hệ thống Supabase');
  END IF;

  IF EXISTS (SELECT 1 FROM public.admin_profiles WHERE id = v_user_id) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Tài khoản này đã có quyền quản trị rồi');
  END IF;

  INSERT INTO public.admin_profiles (id, full_name, email, role)
  VALUES (v_user_id, p_full_name, p_email, p_role);

  RETURN jsonb_build_object('success', true);
END;
$$;
