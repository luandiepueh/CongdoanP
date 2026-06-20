// ============================================================
// SUPABASE CONFIG — thay 2 dòng dưới bằng thông tin project của bạn
// Lấy tại: Supabase Dashboard → Project Settings → API
// ============================================================
const SUPABASE_URL      = 'https://adcqrxupqlluqyffsykw.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFkY3FyeHVwcWxsdXF5ZmZzeWt3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2NzY3NzQsImV4cCI6MjA5NzI1Mjc3NH0.K7P9uSwldj8FsR4Py0VaLFR3UCb6wipXd_wpMQysKTQ';

const sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// ============================================================
// CẤU HÌNH TỔ CHỨC — chỉnh sửa theo đơn vị của bạn
// ============================================================
const APP_CONFIG = {
  orgName:    'Công đoàn Phường Cầu Ông Lãnh',
  orgSubName: 'Trực thuộc Liên đoàn Lao động TP Hồ Chí Minh ',
  email:      'congdoanp.cauonglanh@gmail.com',
  address:    '275 Nguyễn Trãi, phường Cầu Ông Lãnh, TP.HCM'
};

// ============================================================
// UTILITIES DÙNG CHUNG
// ============================================================

function escHtml(str) {
  if (str == null) return '';
  return String(str)
    .replace(/&/g,'&amp;').replace(/</g,'&lt;')
    .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function fmtDate(d) {
  if (!d) return '';
  return new Date(d).toLocaleDateString('vi-VN', { day:'2-digit', month:'2-digit', year:'numeric' });
}

function fmtDateTime(d) {
  if (!d) return '';
  return new Date(d).toLocaleString('vi-VN', { day:'2-digit', month:'2-digit', year:'numeric', hour:'2-digit', minute:'2-digit' });
}

function showToast(msg, type = 'success') {
  const colors = { success:'#2e7d32', danger:'#b71c1c', warning:'#e65100', info:'#0277bd' };
  const icons  = { success:'bi-check-circle-fill', danger:'bi-x-circle-fill', warning:'bi-exclamation-triangle-fill', info:'bi-info-circle-fill' };
  let box = document.getElementById('toastBox');
  if (!box) {
    box = Object.assign(document.createElement('div'), { id:'toastBox' });
    box.style.cssText = 'position:fixed;bottom:1.5rem;right:1.5rem;z-index:9999;display:flex;flex-direction:column;gap:.5rem;pointer-events:none';
    document.body.appendChild(box);
  }
  const el = Object.assign(document.createElement('div'), { innerHTML:`<i class="bi ${icons[type]||icons.info}"></i><span>${escHtml(msg)}</span>` });
  el.style.cssText = `background:${colors[type]||colors.info};color:#fff;border-radius:10px;padding:.75rem 1.1rem;display:flex;align-items:center;gap:.6rem;box-shadow:0 4px 16px rgba(0,0,0,.25);max-width:340px;animation:toastIn .3s ease;pointer-events:auto`;
  box.appendChild(el);
  setTimeout(() => { el.style.opacity='0'; el.style.transition='opacity .3s'; setTimeout(()=>el.remove(),300); }, 3500);
}

function showLoading(show) {
  let ov = document.getElementById('loadingOv');
  if (show && !ov) {
    ov = Object.assign(document.createElement('div'), { id:'loadingOv', className:'loading-overlay' });
    ov.innerHTML = '<div class="spinner-border text-light" style="width:3rem;height:3rem"></div><p class="text-white mt-3 mb-0">Đang xử lý...</p>';
    document.body.appendChild(ov);
  } else if (!show && ov) {
    ov.remove();
  }
}

async function getAdminSession() {
  const { data: { session } } = await sb.auth.getSession();
  return session;
}

async function requireAdmin(redirectPath = 'login.html') {
  const session = await getAdminSession();
  if (!session) { window.location.href = redirectPath; return null; }

  // Kiểm tra bảng admin_profiles: nếu bảng chưa có data → chế độ bootstrap (cho qua)
  // Khi đã có ít nhất 1 profile → chỉ người trong danh sách mới được vào
  try {
    const { data: myProfile } = await sb.from('admin_profiles')
      .select('id').eq('id', session.user.id).maybeSingle();
    if (!myProfile) {
      const { count } = await sb.from('admin_profiles')
        .select('*', { count: 'exact', head: true });
      if (count > 0) {
        await sb.auth.signOut();
        window.location.href = redirectPath;
        return null;
      }
    }
  } catch (_) { /* bảng chưa tồn tại → bỏ qua, cho phép truy cập */ }

  return session;
}

async function adminLogout() {
  await sb.auth.signOut();
  window.location.href = 'login.html';
}

// Constants dùng chung
const CAT_COLORS = {
  'Thông báo chung':      { bg:'#fce4ec', text:'#b71c1c' },
  'Hoạt động công đoàn':  { bg:'#e3f2fd', text:'#1565c0' },
  'Thông tin nội bộ':     { bg:'#e8f5e9', text:'#2e7d32' },
  'Khẩn':                 { bg:'#fff3e0', text:'#e65100' },
};

const DOC_META = {
  'Biểu mẫu':   { icon:'📊', bg:'#e8eaf6' },
  'Hướng dẫn':  { icon:'📖', bg:'#e3f2fd' },
  'Quy chế':    { icon:'📋', bg:'#e8f5e9' },
  'Quyết định': { icon:'📜', bg:'#fff3e0' },
  'Khác':       { icon:'📄', bg:'#f5f5f5' },
};

function catBadge(cat) {
  const c = CAT_COLORS[cat] || { bg:'#f5f5f5', text:'#555' };
  return `<span class="badge badge-cat" style="background:${c.bg};color:${c.text}">${escHtml(cat)}</span>`;
}
