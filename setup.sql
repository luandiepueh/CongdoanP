-- ============================================================
-- CÔNG ĐOÀN CƠ SỞ - SUPABASE SCHEMA
-- Chạy toàn bộ file này trong Supabase SQL Editor
-- ============================================================

-- ANNOUNCEMENTS (Thông báo)
CREATE TABLE public.announcements (
    id          UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    title       TEXT        NOT NULL,
    content     TEXT        NOT NULL,
    category    TEXT        NOT NULL DEFAULT 'Thông báo chung',
    is_pinned   BOOLEAN     DEFAULT FALSE,
    attach_url  TEXT,
    attach_name TEXT,
    created_by  UUID        REFERENCES auth.users(id),
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- DOCUMENTS (Tài liệu & Biểu mẫu)
CREATE TABLE public.documents (
    id             UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    title          TEXT        NOT NULL,
    description    TEXT,
    category       TEXT        NOT NULL DEFAULT 'Biểu mẫu',
    file_url       TEXT        NOT NULL,
    file_name      TEXT,
    version        TEXT        DEFAULT '1.0',
    download_count INTEGER     DEFAULT 0,
    created_by     UUID        REFERENCES auth.users(id),
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    updated_at     TIMESTAMPTZ DEFAULT NOW()
);

-- FEEDBACK (Góp ý / Hỏi đáp)
CREATE TABLE public.feedback (
    id            UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    sender_name   TEXT        NOT NULL,
    unit          TEXT,
    category      TEXT        DEFAULT 'Góp ý chung',
    content       TEXT        NOT NULL,
    status        TEXT        DEFAULT 'Chờ xử lý' CHECK (status IN ('Chờ xử lý', 'Đã phản hồi')),
    reply_content TEXT,
    replied_at    TIMESTAMPTZ,
    replied_by    UUID        REFERENCES auth.users(id),
    created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback      ENABLE ROW LEVEL SECURITY;

-- Announcements: public đọc, admin ghi
CREATE POLICY "anon_read_announcements"  ON public.announcements FOR SELECT USING (TRUE);
CREATE POLICY "auth_all_announcements"   ON public.announcements FOR ALL   USING (auth.role() = 'authenticated');

-- Documents: public đọc, admin ghi
CREATE POLICY "anon_read_documents"  ON public.documents FOR SELECT USING (TRUE);
CREATE POLICY "auth_all_documents"   ON public.documents FOR ALL   USING (auth.role() = 'authenticated');

-- Feedback: ai cũng gửi được + đọc được; admin mới sửa/xóa
CREATE POLICY "anon_insert_feedback" ON public.feedback FOR INSERT WITH CHECK (TRUE);
CREATE POLICY "anon_read_feedback"   ON public.feedback FOR SELECT USING (TRUE);
CREATE POLICY "auth_update_feedback" ON public.feedback FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "auth_delete_feedback" ON public.feedback FOR DELETE USING (auth.role() = 'authenticated');

-- ============================================================
-- STORAGE BUCKETS
-- ============================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
    ('tai-lieu',    'tai-lieu',    TRUE, 52428800, ARRAY[
        'application/pdf',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-powerpoint',
        'application/vnd.openxmlformats-officedocument.presentationml.presentation'
    ]),
    ('attachments', 'attachments', TRUE, 10485760, NULL)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "public_read_tai_lieu"   ON storage.objects FOR SELECT USING (bucket_id = 'tai-lieu');
CREATE POLICY "auth_upload_tai_lieu"   ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'tai-lieu' AND auth.role() = 'authenticated');
CREATE POLICY "auth_delete_tai_lieu"   ON storage.objects FOR DELETE USING (bucket_id = 'tai-lieu' AND auth.role() = 'authenticated');

CREATE POLICY "public_read_attach"     ON storage.objects FOR SELECT USING (bucket_id = 'attachments');
CREATE POLICY "auth_upload_attach"     ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'attachments' AND auth.role() = 'authenticated');
CREATE POLICY "auth_delete_attach"     ON storage.objects FOR DELETE USING (bucket_id = 'attachments' AND auth.role() = 'authenticated');

-- ============================================================
-- FUNCTION: tăng lượt tải tài liệu
-- ============================================================
CREATE OR REPLACE FUNCTION increment_download(doc_id UUID)
RETURNS VOID LANGUAGE sql SECURITY DEFINER AS $$
    UPDATE public.documents SET download_count = download_count + 1 WHERE id = doc_id;
$$;
