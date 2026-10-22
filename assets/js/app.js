/**
 * BNPB - Sistem Informasi Penanggulangan Bencana
 * Main Application JavaScript
 * Mengintegrasikan Hierarki Wilayah: Indonesia -> Provinsi -> Kabupaten/Kota
 */

// ============================================
// API Configuration
// ============================================
const API_BASE = './api';

// ============================================
// Utility Functions
// ============================================
function formatNumber(num) {
    return new Intl.NumberFormat('id-ID').format(num || 0);
}

function formatRupiah(num) {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(num || 0);
}

function formatDate(dateStr) {
    if (!dateStr) return '-';
    const d = new Date(dateStr);
    return d.toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
}

function getStatusBadge(status) {
    const map = {
        'terjadi': { class: 'badge-danger', icon: 'fa-circle-exclamation', label: 'Terjadi' },
        'tanggap_darurat': { class: 'badge-warning', icon: 'fa-triangle-exclamation', label: 'Tanggap Darurat' },
        'pemulihan': { class: 'badge-info', icon: 'fa-hammer', label: 'Pemulihan' },
        'selesai': { class: 'badge-success', icon: 'fa-circle-check', label: 'Selesai' }
    };
    const s = map[status] || { class: 'badge-secondary', icon: 'fa-question', label: status };
    return `<span class="badge ${s.class}"><span class="badge-dot"></span>${s.label}</span>`;
}

function getSeverityBadge(severity) {
    const sev = (severity || 'ringan').toLowerCase();
    const label = sev.replace('_', ' ');
    return `<span class="severity-badge severity-${sev}">${label}</span>`;
}

// ============================================
// Toast Notifications
// ============================================
function showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer');
    if (!container) return;
    const icons = { success: 'fa-circle-check', error: 'fa-circle-xmark', warning: 'fa-triangle-exclamation', info: 'fa-circle-info' };
    
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = `
        <i class="fas ${icons[type] || 'fa-circle-info'}"></i>
        <span class="toast-message">${message}</span>
        <button class="toast-close" onclick="this.parentElement.remove()"><i class="fas fa-times"></i></button>
    `;
    container.appendChild(toast);
    
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateX(100%)';
        setTimeout(() => toast.remove(), 300);
    }, 4000);
}

// ============================================
// API Helper (Hybrid: Real PHP Backend + Vercel / Cloud Fallback)
// ============================================
let isUsingClientStorage = false;

async function apiCall(endpoint, options = {}) {
    if (isUsingClientStorage && window.ClientStorage) {
        return window.ClientStorage.handle(endpoint, options);
    }

    try {
        const response = await fetch(`${API_BASE}/${endpoint}`, {
            headers: { 'Content-Type': 'application/json' },
            ...options
        });

        const contentType = response.headers.get('content-type') || '';
        if (!response.ok || !contentType.includes('application/json')) {
            throw new Error('API server tidak merespons JSON, beralih ke storage engine');
        }

        const data = await response.json();
        return data;
    } catch (error) {
        if (window.ClientStorage) {
            if (!isUsingClientStorage) {
                console.info('Mengaktifkan Client Storage Engine untuk Vercel / Cloud');
                isUsingClientStorage = true;
            }
            return window.ClientStorage.handle(endpoint, options);
        }
        console.error('API Error:', error);
        showToast(error.message, 'error');
        throw error;
    }
}

// ============================================
// Navigation
// ============================================
let currentPage = 'dashboard';

function navigateTo(page) {
    // Update nav
    document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('active'));
    const activeNav = document.querySelector(`.nav-item[data-page="${page}"]`);
    if (activeNav) activeNav.classList.add('active');

    // Update sections
    document.querySelectorAll('.page-section').forEach(s => s.classList.remove('active'));
    const section = document.getElementById(`page-${page}`);
    if (section) section.classList.add('active');

    // Update title
    const titles = {
        'dashboard': '<i class="fas fa-chart-line"></i> Dashboard',
        'bencana': '<i class="fas fa-house-crack"></i> Data Bencana',
        'wilayah': '<i class="fas fa-sitemap"></i> Hierarki Wilayah (Indonesia ➔ Provinsi ➔ Kab/Kota)',
        'posko': '<i class="fas fa-tent"></i> Posko Pengungsian',
        'logistik': '<i class="fas fa-boxes-stacked"></i> Logistik Bantuan',
        'relawan': '<i class="fas fa-people-group"></i> Data Relawan'
    };
    const titleEl = document.getElementById('pageTitle');
    if (titleEl) titleEl.innerHTML = titles[page] || page;

    currentPage = page;
    closeSidebar();

    // Load data
    switch(page) {
        case 'dashboard': loadDashboard(); break;
        case 'bencana': loadBencana(); break;
        case 'wilayah': loadWilayahPage(); break;
        case 'posko': loadPosko(); break;
        case 'logistik': loadLogistik(); break;
        case 'relawan': loadRelawan(); break;
    }
}

// ============================================
// Sidebar Toggle
// ============================================
function toggleSidebar() {
    document.getElementById('sidebar')?.classList.toggle('active');
    document.getElementById('sidebarOverlay')?.classList.toggle('active');
}

function closeSidebar() {
    document.getElementById('sidebar')?.classList.remove('active');
    document.getElementById('sidebarOverlay')?.classList.remove('active');
}

// ============================================
// Modal
// ============================================
function openModal(modalId) {
    const el = document.getElementById(modalId);
    if (el) {
        el.classList.add('active');
        document.body.style.overflow = 'hidden';
    }
}

function closeModal(modalId) {
    const el = document.getElementById(modalId);
    if (el) {
        el.classList.remove('active');
        document.body.style.overflow = '';
    }
}

// ============================================
// DASHBOARD
// ============================================
let chartBulan, chartJenis;

async function loadDashboard() {
    try {
        const summary = await apiCall('dashboard.php?action=summary');
        const d = summary.data;

        document.getElementById('statTotalBencana').textContent = formatNumber(d.total_bencana);
        const badge = document.getElementById('navBadgeBencana');
        if (badge) badge.textContent = d.total_bencana;
        document.getElementById('statBencanaAktif').textContent = formatNumber(d.bencana_aktif);
        document.getElementById('statKorbanMeninggal').textContent = formatNumber(d.korban.meninggal);
        document.getElementById('statPengungsi').textContent = formatNumber(d.pengungsi_aktif);
        document.getElementById('statPoskoAktif').textContent = formatNumber(d.posko_aktif);
        document.getElementById('statRelawanAktif').textContent = formatNumber(d.relawan_aktif);
        document.getElementById('statKerugian').textContent = formatRupiah(d.korban.total_kerugian);
        document.getElementById('statRumahRusak').textContent = formatNumber(d.korban.rumah_rusak);

        loadChartBulan();
        loadChartJenis();
        loadBencanaTerbaru();

    } catch (error) {
        console.error('Dashboard error:', error);
    }
}

async function loadChartBulan() {
    try {
        const result = await apiCall('dashboard.php?action=bencana_per_bulan&year=2026');
        const data = result.data;

        const ctx = document.getElementById('chartBulan')?.getContext('2d');
        if (!ctx) return;
        if (chartBulan) chartBulan.destroy();

        const gradient = ctx.createLinearGradient(0, 0, 0, 300);
        gradient.addColorStop(0, 'rgba(59, 130, 246, 0.3)');
        gradient.addColorStop(1, 'rgba(59, 130, 246, 0.01)');

        chartBulan = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: data.map(d => d.bulan),
                datasets: [{
                    label: 'Kejadian Bencana',
                    data: data.map(d => d.total),
                    backgroundColor: gradient,
                    borderColor: 'rgba(59, 130, 246, 0.8)',
                    borderWidth: 2,
                    borderRadius: 8,
                    borderSkipped: false,
                    barPercentage: 0.6,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: '#1a1f35',
                        titleColor: '#f0f2f5',
                        bodyColor: '#9ca3af',
                        borderColor: 'rgba(255,255,255,0.1)',
                        borderWidth: 1,
                        padding: 12,
                        cornerRadius: 8,
                    }
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { color: '#6b7280', font: { size: 11 } }
                    },
                    y: {
                        beginAtZero: true,
                        grid: { color: 'rgba(255,255,255,0.04)' },
                        ticks: { color: '#6b7280', font: { size: 11 }, stepSize: 1 }
                    }
                }
            }
        });
    } catch (e) {}
}

async function loadChartJenis() {
    try {
        const result = await apiCall('dashboard.php?action=bencana_per_jenis');
        const data = result.data.filter(d => d.total > 0);

        const ctx = document.getElementById('chartJenis')?.getContext('2d');
        if (!ctx) return;
        if (chartJenis) chartJenis.destroy();

        chartJenis = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: data.map(d => d.nama_jenis),
                datasets: [{
                    data: data.map(d => d.total),
                    backgroundColor: data.map(d => d.warna || '#3b82f6'),
                    borderColor: '#1a1f35',
                    borderWidth: 3,
                    hoverOffset: 8,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '65%',
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: '#9ca3af',
                            font: { size: 11 },
                            padding: 16,
                            usePointStyle: true,
                            pointStyleWidth: 10,
                        }
                    },
                    tooltip: {
                        backgroundColor: '#1a1f35',
                        titleColor: '#f0f2f5',
                        bodyColor: '#9ca3af',
                        borderColor: 'rgba(255,255,255,0.1)',
                        borderWidth: 1,
                        padding: 12,
                        cornerRadius: 8,
                    }
                }
            }
        });
    } catch (e) {}
}

async function loadBencanaTerbaru() {
    const container = document.getElementById('bencanaTerbaru');
    if (!container) return;

    try {
        const result = await apiCall('dashboard.php?action=bencana_terbaru&limit=5');
        if (!result.data.length) {
            container.innerHTML = '<div class="empty-state"><i class="fas fa-inbox"></i><h4>Belum ada data</h4></div>';
            return;
        }

        container.innerHTML = result.data.map(b => `
            <div class="bencana-item" onclick="showDetailBencana(${b.id})">
                <div class="bencana-icon" style="background: ${b.warna}15; color: ${b.warna}">
                    <i class="fas ${b.ikon}"></i>
                </div>
                <div class="bencana-info">
                    <h4>${b.judul}</h4>
                    <div class="bencana-meta">
                        <span><i class="fas fa-tag"></i>${b.nama_jenis}</span>
                        <span><i class="fas fa-location-dot"></i>${b.nama_provinsi}</span>
                        <span><i class="fas fa-calendar"></i>${formatDate(b.tanggal_kejadian)}</span>
                    </div>
                </div>
                <div class="bencana-status">
                    ${getStatusBadge(b.status)}
                    ${getSeverityBadge(b.tingkat_kerusakan)}
                </div>
            </div>
        `).join('');
    } catch (e) {}
}

// ============================================
// BENCANA
// ============================================
let bencanaData = [];

async function loadBencana() {
    const container = document.getElementById('bencanaTableBody');
    if (!container) return;
    container.innerHTML = '<tr><td colspan="8"><div class="loading-spinner"><div class="spinner"></div>Memuat data...</div></td></tr>';

    try {
        const params = new URLSearchParams();
        const search = document.getElementById('searchBencana')?.value;
        const status = document.getElementById('filterStatus')?.value;
        const jenis = document.getElementById('filterJenis')?.value;
        const prov = document.getElementById('filterProvinsi')?.value;
        const kab = document.getElementById('filterKabupaten')?.value;

        if (search) params.set('search', search);
        if (status) params.set('status', status);
        if (jenis) params.set('jenis', jenis);
        if (prov) params.set('provinsi_id', prov);
        if (kab) params.set('kabkota_id', kab);
        params.set('limit', '50');

        const result = await apiCall(`bencana.php?${params.toString()}`);
        bencanaData = result.data;

        if (!bencanaData.length) {
            container.innerHTML = '<tr><td colspan="8"><div class="empty-state"><i class="fas fa-inbox"></i><h4>Tidak ada data bencana sesuai filter</h4></div></td></tr>';
            return;
        }

        container.innerHTML = bencanaData.map(b => `
            <tr>
                <td class="td-bold">${b.kode_bencana}</td>
                <td>
                    <div class="d-flex align-center gap-2" style="gap:8px">
                        <span style="color:${b.warna}"><i class="fas ${b.ikon}"></i></span>
                        <span class="td-bold">${b.judul}</span>
                    </div>
                </td>
                <td>${b.nama_jenis}</td>
                <td>
                    <div class="wilayah-chip">
                        <span class="chip-flag" title="Tingkat 1: Negara"><i class="fas fa-flag"></i> ${b.nama_negara || 'Indonesia'}</span>
                        <span class="chip-arrow"><i class="fas fa-chevron-right"></i></span>
                        <span class="chip-prov" title="Tingkat 2: Provinsi">${b.nama_provinsi}</span>
                        <span class="chip-arrow"><i class="fas fa-chevron-right"></i></span>
                        <span class="chip-kab" title="Tingkat 3: Kabupaten/Kota">${b.nama_kabkota || b.nama_kabupaten || '-'}</span>
                    </div>
                </td>
                <td>${formatDate(b.tanggal_kejadian)}</td>
                <td>${getSeverityBadge(b.tingkat_kerusakan)}</td>
                <td>${getStatusBadge(b.status)}</td>
                <td>
                    <div class="btn-group">
                        <button class="btn-icon" onclick="showDetailBencana(${b.id})" title="Detail">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn-icon danger" onclick="deleteBencana(${b.id})" title="Hapus">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `).join('');

    } catch (error) {
        container.innerHTML = '<tr><td colspan="8"><div class="empty-state"><i class="fas fa-exclamation-triangle text-danger"></i><h4>Gagal memuat data</h4></div></td></tr>';
    }
}

async function showDetailBencana(id) {
    try {
        const result = await apiCall(`bencana.php?id=${id}`);
        const b = result.data;

        document.getElementById('detailBencanaContent').innerHTML = `
            <div class="mb-3">
                <div class="d-flex align-center justify-between" style="display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;flex-wrap:wrap;gap:10px">
                    <div>
                        <h3 style="font-size:20px;font-weight:700;margin-bottom:4px">${b.judul}</h3>
                        <p style="color:var(--text-muted);font-size:13px">${b.kode_bencana} • ${b.nama_jenis}</p>
                    </div>
                    <div style="display:flex;gap:8px">
                        ${getStatusBadge(b.status)}
                        ${getSeverityBadge(b.tingkat_kerusakan)}
                    </div>
                </div>

                <!-- Hierarki Wilayah Box -->
                <div class="wilayah-crumb-box" style="margin-bottom:18px">
                    <i class="fas fa-sitemap" style="color:var(--accent-primary); font-size:14px"></i>
                    <span style="font-weight:700; color:var(--text-primary); font-size:13px">Lokasi Berjenjang:</span>
                    <div class="wilayah-chip">
                        <span class="chip-flag"><i class="fas fa-flag"></i> ${b.nama_negara || 'Indonesia'}</span>
                        <span class="chip-arrow"><i class="fas fa-chevron-right"></i></span>
                        <span class="chip-prov"><i class="fas fa-map"></i> ${b.nama_provinsi}</span>
                        <span class="chip-arrow"><i class="fas fa-chevron-right"></i></span>
                        <span class="chip-kab"><i class="fas fa-city"></i> ${b.nama_kabkota || b.nama_kabupaten || '-'}</span>
                    </div>
                </div>

                ${b.deskripsi ? `<p style="color:var(--text-secondary);font-size:14px;margin-bottom:20px">${b.deskripsi}</p>` : ''}
            </div>

            <h4 style="font-size:14px;font-weight:700;margin-bottom:12px;color:var(--accent-primary)"><i class="fas fa-users"></i> Data Korban & Kerusakan</h4>
            <div class="detail-grid mb-3">
                <div class="detail-item">
                    <div class="detail-label">Meninggal</div>
                    <div class="detail-value" style="color:var(--danger)">${formatNumber(b.meninggal || 0)}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Hilang</div>
                    <div class="detail-value" style="color:var(--warning)">${formatNumber(b.hilang || 0)}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Luka Berat</div>
                    <div class="detail-value">${formatNumber(b.luka_berat || 0)}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Luka Ringan</div>
                    <div class="detail-value">${formatNumber(b.luka_ringan || 0)}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Mengungsi</div>
                    <div class="detail-value" style="color:var(--info)">${formatNumber(b.mengungsi || 0)}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Rumah Rusak Berat</div>
                    <div class="detail-value">${formatNumber(b.rumah_rusak_berat || 0)}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Rumah Rusak Sedang</div>
                    <div class="detail-value">${formatNumber(b.rumah_rusak_sedang || 0)}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Rumah Rusak Ringan</div>
                    <div class="detail-value">${formatNumber(b.rumah_rusak_ringan || 0)}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Estimasi Kerugian</div>
                    <div class="detail-value small">${formatRupiah(b.kerugian_estimasi || 0)}</div>
                </div>
            </div>

            ${b.posko && b.posko.length ? `
                <h4 style="font-size:14px;font-weight:700;margin-bottom:12px;color:var(--accent-primary)"><i class="fas fa-tent"></i> Posko (${b.posko.length})</h4>
                <div class="table-wrapper mb-3">
                    <table class="data-table">
                        <thead><tr><th>Nama Posko</th><th>Kapasitas</th><th>Pengungsi</th><th>PJ</th><th>Status</th></tr></thead>
                        <tbody>
                            ${b.posko.map(p => `
                                <tr>
                                    <td class="td-bold">${p.nama_posko}</td>
                                    <td>${formatNumber(p.kapasitas)}</td>
                                    <td>${formatNumber(p.jumlah_pengungsi)}</td>
                                    <td>${p.penanggung_jawab || '-'}</td>
                                    <td>${p.status === 'aktif' ? '<span class="badge badge-success"><span class="badge-dot"></span>Aktif</span>' : '<span class="badge badge-secondary">Nonaktif</span>'}</td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            ` : ''}

            ${b.relawan && b.relawan.length ? `
                <h4 style="font-size:14px;font-weight:700;margin-bottom:12px;color:var(--accent-primary)"><i class="fas fa-people-group"></i> Relawan (${b.relawan.length})</h4>
                <div class="table-wrapper mb-3">
                    <table class="data-table">
                        <thead><tr><th>Nama</th><th>Organisasi</th><th>Keahlian</th><th>Status</th></tr></thead>
                        <tbody>
                            ${b.relawan.map(r => `
                                <tr>
                                    <td class="td-bold">${r.nama}</td>
                                    <td>${r.organisasi || '-'}</td>
                                    <td>${r.keahlian || '-'}</td>
                                    <td>${r.status === 'aktif' ? '<span class="badge badge-success"><span class="badge-dot"></span>Aktif</span>' : '<span class="badge badge-secondary">Selesai</span>'}</td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            ` : ''}
        `;

        openModal('modalDetailBencana');
    } catch (error) {
        showToast('Gagal memuat detail bencana', 'error');
    }
}

async function deleteBencana(id) {
    if (!confirm('Yakin ingin menghapus data bencana ini?')) return;
    try {
        await apiCall(`bencana.php?id=${id}`, { method: 'DELETE' });
        showToast('Data bencana berhasil dihapus', 'success');
        loadBencana();
        loadDashboard();
    } catch (error) {}
}

// ============================================
// FORM BENCANA (Hierarki Wilayah: IDN -> Prov -> Kab)
// ============================================
function openFormBencana() {
    const form = document.getElementById('formBencana');
    if (form) form.reset();

    const crumbProv = document.getElementById('crumbProvText');
    const crumbKab = document.getElementById('crumbKabText');
    if (crumbProv) crumbProv.textContent = 'Pilih Provinsi';
    if (crumbKab) crumbKab.textContent = 'Pilih Kab/Kota';

    const kabSelect = document.getElementById('inputKabKota');
    if (kabSelect) kabSelect.innerHTML = '<option value="">-- Pilih Kab/Kota (Pilih Provinsi dahulu) --</option>';

    loadReferensiJenisBencana();
    loadReferensiProvinsi();
    openModal('modalFormBencana');
}

async function loadReferensiJenisBencana() {
    try {
        const result = await apiCall('referensi.php?type=jenis_bencana');
        const select = document.getElementById('inputJenisBencana');
        if (!select) return;
        select.innerHTML = '<option value="">-- Pilih Jenis --</option>' +
            result.data.map(j => `<option value="${j.id}">${j.nama_jenis}</option>`).join('');

        // Juga isi filterJenis jika belum terisi
        const filterJenis = document.getElementById('filterJenis');
        if (filterJenis && filterJenis.options.length <= 1) {
            filterJenis.innerHTML = '<option value="">Semua Jenis Bencana</option>' +
                result.data.map(j => `<option value="${j.id}">${j.nama_jenis}</option>`).join('');
        }
    } catch (e) {}
}

async function loadReferensiProvinsi() {
    try {
        const result = await apiCall('referensi.php?type=provinsi&indonesia_id=1');
        const select = document.getElementById('inputProvinsi');
        if (select) {
            select.innerHTML = '<option value="">-- Pilih Provinsi --</option>' +
                result.data.map(p => `<option value="${p.id}">${p.nama_provinsi}</option>`).join('');
        }

        // Isi dropdown filter provinsi di halaman bencana
        const filterProv = document.getElementById('filterProvinsi');
        if (filterProv && filterProv.options.length <= 1) {
            filterProv.innerHTML = '<option value="">Semua Provinsi</option>' +
                result.data.map(p => `<option value="${p.id}">${p.nama_provinsi}</option>`).join('');
        }
    } catch (e) {}
}

async function onInputProvinsiChange(provId) {
    const provSelect = document.getElementById('inputProvinsi');
    const provName = provSelect?.options[provSelect.selectedIndex]?.text || 'Pilih Provinsi';
    const crumbProv = document.getElementById('crumbProvText');
    const crumbKab = document.getElementById('crumbKabText');

    if (crumbProv) crumbProv.textContent = provId ? provName : 'Pilih Provinsi';
    if (crumbKab) crumbKab.textContent = 'Pilih Kab/Kota';

    const select = document.getElementById('inputKabKota');
    if (!select) return;

    if (!provId) {
        select.innerHTML = '<option value="">-- Pilih Kab/Kota (Pilih Provinsi dahulu) --</option>';
        return;
    }

    select.innerHTML = '<option value="">Memuat kabupaten/kota...</option>';
    try {
        const result = await apiCall(`referensi.php?type=kabupaten_kota&provinsi_id=${provId}`);
        select.innerHTML = '<option value="">-- Pilih Kabupaten / Kota --</option>' +
            result.data.map(k => `<option value="${k.id}">${k.nama_kabupaten || k.nama_kabkota}</option>`).join('');
    } catch (e) {
        select.innerHTML = '<option value="">Gagal memuat kabupaten</option>';
    }
}

function updateWilayahPreview() {
    const kabSelect = document.getElementById('inputKabKota');
    const kabName = kabSelect?.options[kabSelect.selectedIndex]?.text || 'Pilih Kab/Kota';
    const crumbKab = document.getElementById('crumbKabText');
    if (crumbKab) crumbKab.textContent = kabSelect?.value ? kabName : 'Pilih Kab/Kota';
}

// Cascading Filter di Page Bencana
async function onFilterProvinsiChange(provId) {
    const kabSelect = document.getElementById('filterKabupaten');
    if (!kabSelect) return;

    if (!provId) {
        kabSelect.innerHTML = '<option value="">Semua Kab/Kota</option>';
        loadBencana();
        return;
    }

    kabSelect.innerHTML = '<option value="">Memuat kab/kota...</option>';
    try {
        const result = await apiCall(`referensi.php?type=kabupaten_kota&provinsi_id=${provId}`);
        kabSelect.innerHTML = '<option value="">Semua Kab/Kota di Prov. Ini</option>' +
            result.data.map(k => `<option value="${k.id}">${k.nama_kabupaten || k.nama_kabkota}</option>`).join('');
    } catch (e) {
        kabSelect.innerHTML = '<option value="">Gagal memuat kab/kota</option>';
    }

    loadBencana();
}

async function submitBencana(e) {
    e.preventDefault();
    const form = e.target;

    const data = {
        jenis_bencana_id: form.jenis_bencana_id.value,
        provinsi_id: form.provinsi_id.value,
        kabkota_id: form.kabkota_id?.value || null,
        judul: form.judul.value,
        deskripsi: form.deskripsi.value,
        tanggal_kejadian: form.tanggal_kejadian.value,
        waktu_kejadian: form.waktu_kejadian.value || null,
        latitude: form.latitude.value || null,
        longitude: form.longitude.value || null,
        tingkat_kerusakan: form.tingkat_kerusakan.value,
        status: form.status.value,
        korban: {
            meninggal: parseInt(form.meninggal.value) || 0,
            hilang: parseInt(form.hilang.value) || 0,
            luka_berat: parseInt(form.luka_berat.value) || 0,
            luka_ringan: parseInt(form.luka_ringan.value) || 0,
            mengungsi: parseInt(form.mengungsi.value) || 0,
            rumah_rusak_berat: parseInt(form.rumah_rusak_berat.value) || 0,
            rumah_rusak_sedang: parseInt(form.rumah_rusak_sedang.value) || 0,
            rumah_rusak_ringan: parseInt(form.rumah_rusak_ringan.value) || 0,
            kerugian_estimasi: parseFloat(form.kerugian_estimasi.value) || 0
        }
    };

    try {
        await apiCall('bencana.php', {
            method: 'POST',
            body: JSON.stringify(data)
        });
        showToast('Data bencana berhasil ditambahkan ke wilayah tersebut', 'success');
        closeModal('modalFormBencana');
        loadBencana();
        loadDashboard();
    } catch (error) {}
}

// ============================================
// HIERARKI WILAYAH EXPLORER (Indonesia -> Prov -> Kab)
// ============================================
let wilayahTreeData = [];
let selectedProvId = null;

async function loadWilayahPage() {
    loadWilayahSummary();
    loadWilayahTree();
}

async function loadWilayahSummary() {
    try {
        const res = await apiCall('wilayah.php?action=summary');
        const s = res.data;
        document.getElementById('statWilayahNegara').textContent = `${s.total_negara} Negara`;
        document.getElementById('statWilayahProvinsi').textContent = s.total_provinsi;
        document.getElementById('statWilayahKabupaten').textContent = s.total_kabupaten;
        document.getElementById('statWilayahTerdampak').textContent = `${s.kabupaten_terdampak} Kab/Kota (${s.provinsi_terdampak} Prov)`;
    } catch (e) {}
}

async function loadWilayahTree() {
    const listContainer = document.getElementById('listProvinsiContainer');
    if (!listContainer) return;
    listContainer.innerHTML = '<div class="loading-spinner"><div class="spinner"></div>Memuat data wilayah...</div>';

    try {
        const res = await apiCall('wilayah.php?action=tree');
        wilayahTreeData = res.data[0]?.provinsi || [];

        renderProvinsiList(wilayahTreeData);

        // Pilih provinsi pertama secara otomatis
        if (wilayahTreeData.length > 0) {
            selectProvinsiForDetail(wilayahTreeData[0].id);
        }
    } catch (e) {
        listContainer.innerHTML = '<div class="empty-state"><i class="fas fa-exclamation-triangle text-danger"></i><h4>Gagal memuat data wilayah</h4></div>';
    }
}

function renderProvinsiList(list) {
    const listContainer = document.getElementById('listProvinsiContainer');
    if (!listContainer) return;

    const countEl = document.getElementById('countProvinsi');
    if (countEl) countEl.textContent = list.length;

    if (!list.length) {
        listContainer.innerHTML = '<div class="empty-state"><p>Tidak ada provinsi yang cocok</p></div>';
        return;
    }

    listContainer.innerHTML = list.map(p => `
        <div class="wilayah-prov-item ${p.id === selectedProvId ? 'active' : ''}" onclick="selectProvinsiForDetail(${p.id})">
            <div>
                <div style="font-weight:600; color:var(--text-primary); font-size:14px">
                    <i class="fas fa-map-pin" style="color:var(--accent-primary); margin-right:6px"></i> ${p.nama_provinsi}
                </div>
                <div style="font-size:11px; color:var(--text-muted); margin-top:2px">
                    🇮🇩 Indonesia &bull; ${p.total_kabupaten} Kab/Kota
                </div>
            </div>
            <div style="display:flex; align-items:center; gap:8px">
                ${p.total_bencana > 0 
                    ? `<span class="badge badge-danger" title="${p.total_bencana} kejadian bencana"><i class="fas fa-triangle-exclamation"></i> ${p.total_bencana} Bencana</span>` 
                    : `<span class="badge badge-success" style="opacity:0.6"><i class="fas fa-check"></i> Aman</span>`}
                <i class="fas fa-chevron-right" style="color:var(--text-muted); font-size:11px"></i>
            </div>
        </div>
    `).join('');
}

function filterProvinsiList(keyword) {
    const q = (keyword || '').toLowerCase();
    const filtered = wilayahTreeData.filter(p => p.nama_provinsi.toLowerCase().includes(q));
    renderProvinsiList(filtered);
}

function selectProvinsiForDetail(provId) {
    selectedProvId = provId;

    // Update active highlight
    document.querySelectorAll('.wilayah-prov-item').forEach(el => el.classList.remove('active'));
    const items = document.querySelectorAll('.wilayah-prov-item');
    // Cari item yang sesuai
    const prov = wilayahTreeData.find(p => p.id === provId);
    if (!prov) return;

    // Update title & subtitle
    const title = document.getElementById('detailProvinsiTitle');
    const subtitle = document.getElementById('detailProvinsiSubtitle');
    const badge = document.getElementById('badgeTotalKabKota');

    if (title) title.innerHTML = `<i class="fas fa-city" style="color:var(--accent-primary)"></i> Tingkat 3: Kabupaten & Kota di ${prov.nama_provinsi}`;
    if (subtitle) subtitle.innerHTML = `Hierarki Wilayah: <strong>🇮🇩 Indonesia</strong> &rarr; <strong>${prov.nama_provinsi}</strong> (${prov.kabupaten_kota?.length || 0} Daerah Tingkat II)`;
    if (badge) badge.textContent = `${prov.kabupaten_kota?.length || 0} Kab/Kota`;

    const kabContainer = document.getElementById('listKabupatenContainer');
    if (!kabContainer) return;

    const kabList = prov.kabupaten_kota || [];
    if (!kabList.length) {
        kabContainer.innerHTML = '<div class="empty-state"><i class="fas fa-city"></i><h4>Belum ada data kabupaten/kota</h4></div>';
        return;
    }

    kabContainer.innerHTML = `
        <div style="padding:12px 18px; background:rgba(255,255,255,0.02); border-bottom:1px solid var(--border-color); display:flex; align-items:center; justify-content:space-between">
            <span style="font-size:12px; color:var(--text-muted)"><i class="fas fa-list-check"></i> Menampilkan ${kabList.length} Kabupaten/Kota di ${prov.nama_provinsi}</span>
            <button class="btn btn-secondary btn-sm" onclick="filterBencanaByProvinsi(${prov.id})" title="Lihat semua kejadian bencana di provinsi ini">
                <i class="fas fa-arrow-up-right-from-square"></i> Lihat Bencana di ${prov.nama_provinsi}
            </button>
        </div>
        ${kabList.map((k, idx) => `
            <div class="wilayah-kab-item">
                <div style="display:flex; align-items:center; gap:12px">
                    <span style="font-size:12px; color:var(--text-muted); width:24px; font-weight:600">${idx + 1}.</span>
                    <div>
                        <div style="font-weight:600; color:var(--text-primary); font-size:14px">
                            ${k.nama_kabupaten || k.nama_kabkota}
                        </div>
                        <div style="font-size:11px; color:var(--text-muted); margin-top:2px">
                            Hierarki: Indonesia &rarr; ${prov.nama_provinsi} &rarr; ${k.nama_kabupaten || k.nama_kabkota}
                        </div>
                    </div>
                </div>
                <div style="display:flex; align-items:center; gap:8px">
                    ${k.total_bencana > 0 
                        ? `<button class="btn btn-secondary btn-sm" onclick="filterBencanaByKabupaten(${prov.id}, ${k.id})" style="color:var(--danger); border-color:rgba(239,68,68,0.3)">
                             <i class="fas fa-triangle-exclamation"></i> ${k.total_bencana} Bencana Tercatat
                           </button>` 
                        : `<span class="badge badge-success" style="opacity:0.5"><i class="fas fa-shield"></i> Nihil Kejadian</span>`}
                </div>
            </div>
        `).join('')}
    `;

    // Re-highlight active
    document.querySelectorAll('.wilayah-prov-item').forEach(el => {
        if (el.textContent.includes(prov.nama_provinsi)) {
            el.classList.add('active');
        }
    });
}

function filterBencanaByProvinsi(provId) {
    navigateTo('bencana');
    setTimeout(() => {
        const provSelect = document.getElementById('filterProvinsi');
        if (provSelect) {
            provSelect.value = provId;
            onFilterProvinsiChange(provId);
        }
    }, 200);
}

function filterBencanaByKabupaten(provId, kabId) {
    navigateTo('bencana');
    setTimeout(async () => {
        const provSelect = document.getElementById('filterProvinsi');
        if (provSelect) {
            provSelect.value = provId;
            await onFilterProvinsiChange(provId);
            const kabSelect = document.getElementById('filterKabupaten');
            if (kabSelect) {
                kabSelect.value = kabId;
                loadBencana();
            }
        }
    }, 200);
}

// ============================================
// POSKO
// ============================================
async function loadPosko() {
    const container = document.getElementById('poskoTableBody');
    if (!container) return;
    container.innerHTML = '<tr><td colspan="7"><div class="loading-spinner"><div class="spinner"></div>Memuat data...</div></td></tr>';

    try {
        const result = await apiCall('posko.php');
        if (!result.data.length) {
            container.innerHTML = '<tr><td colspan="7"><div class="empty-state"><i class="fas fa-tent"></i><h4>Tidak ada data posko</h4></div></td></tr>';
            return;
        }

        container.innerHTML = result.data.map(p => {
            const usage = p.kapasitas > 0 ? Math.round((p.jumlah_pengungsi / p.kapasitas) * 100) : 0;
            const usageColor = usage >= 90 ? 'var(--danger)' : usage >= 70 ? 'var(--warning)' : 'var(--success)';
            return `
            <tr>
                <td class="td-bold">${p.nama_posko}</td>
                <td>${p.nama_bencana}</td>
                <td>${formatNumber(p.kapasitas)}</td>
                <td>
                    <div style="display:flex;align-items:center;gap:8px">
                        <span>${formatNumber(p.jumlah_pengungsi)}</span>
                        <div style="width:60px;height:6px;background:rgba(255,255,255,0.06);border-radius:3px;overflow:hidden">
                            <div style="width:${Math.min(usage, 100)}%;height:100%;background:${usageColor};border-radius:3px;transition:width 0.5s ease"></div>
                        </div>
                        <span style="font-size:11px;color:${usageColor}">${usage}%</span>
                    </div>
                </td>
                <td>${p.penanggung_jawab || '-'}</td>
                <td>${p.kontak || '-'}</td>
                <td>${p.status === 'aktif' ? '<span class="badge badge-success"><span class="badge-dot"></span>Aktif</span>' : '<span class="badge badge-secondary">Nonaktif</span>'}</td>
            </tr>
        `}).join('');
    } catch (error) {
        container.innerHTML = '<tr><td colspan="7"><div class="empty-state"><i class="fas fa-exclamation-triangle text-danger"></i><h4>Gagal memuat data</h4></div></td></tr>';
    }
}

// ============================================
// LOGISTIK
// ============================================
async function loadLogistik() {
    const container = document.getElementById('logistikTableBody');
    if (!container) return;
    container.innerHTML = '<tr><td colspan="8"><div class="loading-spinner"><div class="spinner"></div>Memuat data...</div></td></tr>';

    try {
        const result = await apiCall('logistik.php');
        if (!result.data.length) {
            container.innerHTML = '<tr><td colspan="8"><div class="empty-state"><i class="fas fa-boxes-stacked"></i><h4>Tidak ada data logistik</h4></div></td></tr>';
            return;
        }

        const kategoriIcons = {
            makanan: 'fa-utensils', minuman: 'fa-glass-water', obat: 'fa-pills',
            pakaian: 'fa-shirt', tenda: 'fa-tent', selimut: 'fa-bed',
            peralatan: 'fa-screwdriver-wrench', lainnya: 'fa-box'
        };

        container.innerHTML = result.data.map(l => `
            <tr>
                <td class="td-bold">${l.nama_barang}</td>
                <td>
                    <span class="badge badge-info" style="gap:4px">
                        <i class="fas ${kategoriIcons[l.kategori] || 'fa-box'}" style="font-size:10px"></i>
                        ${l.kategori}
                    </span>
                </td>
                <td>${formatNumber(l.jumlah)} ${l.satuan}</td>
                <td>${l.sumber || '-'}</td>
                <td>${l.nama_bencana}</td>
                <td>${l.nama_posko || '-'}</td>
                <td>${formatDate(l.tanggal_masuk)}</td>
                <td>
                    ${l.status === 'tersedia' ? '<span class="badge badge-success"><span class="badge-dot"></span>Tersedia</span>' :
                      l.status === 'didistribusikan' ? '<span class="badge badge-info"><span class="badge-dot"></span>Didistribusikan</span>' :
                      '<span class="badge badge-danger"><span class="badge-dot"></span>Habis</span>'}
                </td>
            </tr>
        `).join('');
    } catch (error) {
        container.innerHTML = '<tr><td colspan="8"><div class="empty-state"><i class="fas fa-exclamation-triangle text-danger"></i><h4>Gagal memuat data</h4></div></td></tr>';
    }
}

// ============================================
// RELAWAN
// ============================================
async function loadRelawan() {
    const container = document.getElementById('relawanTableBody');
    if (!container) return;
    container.innerHTML = '<tr><td colspan="7"><div class="loading-spinner"><div class="spinner"></div>Memuat data...</div></td></tr>';

    try {
        const result = await apiCall('relawan.php');
        if (!result.data.length) {
            container.innerHTML = '<tr><td colspan="7"><div class="empty-state"><i class="fas fa-people-group"></i><h4>Tidak ada data relawan</h4></div></td></tr>';
            return;
        }

        container.innerHTML = result.data.map(r => `
            <tr>
                <td class="td-bold">${r.nama}</td>
                <td>${r.organisasi || '-'}</td>
                <td>${r.keahlian || '-'}</td>
                <td>${r.no_telepon || '-'}</td>
                <td>${r.nama_bencana}</td>
                <td>${formatDate(r.tanggal_bergabung)}</td>
                <td>${r.status === 'aktif' ? '<span class="badge badge-success"><span class="badge-dot"></span>Aktif</span>' : '<span class="badge badge-secondary">Selesai</span>'}</td>
            </tr>
        `).join('');
    } catch (error) {
        container.innerHTML = '<tr><td colspan="7"><div class="empty-state"><i class="fas fa-exclamation-triangle text-danger"></i><h4>Gagal memuat data</h4></div></td></tr>';
    }
}

// ============================================
// INIT
// ============================================
document.addEventListener('DOMContentLoaded', () => {
    // Nav click handlers
    document.querySelectorAll('.nav-item[data-page]').forEach(item => {
        item.addEventListener('click', () => navigateTo(item.dataset.page));
    });

    // Search debounce
    let searchTimeout;
    const searchInput = document.getElementById('searchBencana');
    if (searchInput) {
        searchInput.addEventListener('input', () => {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => loadBencana(), 400);
        });
    }

    // Filter changes
    ['filterStatus', 'filterJenis'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.addEventListener('change', () => loadBencana());
    });

    // Load filter options (Provinsi & Jenis) saat startup
    loadReferensiProvinsi();
    loadReferensiJenisBencana();

    // Load initial page
    navigateTo('dashboard');
});
