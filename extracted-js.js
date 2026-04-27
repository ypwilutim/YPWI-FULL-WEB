// Extracted JavaScript from complete-profile.html for syntax testing
console.log('Script loaded - Clean Version');

// Global variables for tags
let selectedUnits = [];
let selectedJabatans = [];

// Toast function
function showToast(message) {
    const toast = new bootstrap.Toast(document.getElementById('alertToast'));
    document.querySelector('#alertToast .toast-body').textContent = message;
    toast.show();
}

// Add jabatan
function addJabatan() {
    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('jabatanModal'));
    modal.show();
}

// Global variable for units data
let allUnits = [];

// Add unit (placeholder - will be called from modal)
function addUnit(unit = null) {
    if (!unit) {
        // Show modal and load units
        loadUnitsForModal();
        const modal = new bootstrap.Modal(document.getElementById('unitModal'));
        modal.show();
        return;
    }

    // Add selected unit
    if (selectedUnits.some(u => u.code === unit.code)) {
        showToast('Unit sudah ditambahkan');
        return;
    }

    selectedUnits.push(unit);
    renderUnitTags();

    // Close modal
    const modal = bootstrap.Modal.getInstance(document.getElementById('unitModal'));
    if (modal) modal.hide();
}

// Render unit list in modal
function renderUnitList(units) {
    const container = document.getElementById('unitList');
    container.innerHTML = '';

    if (!units || units.length === 0) {
        container.innerHTML = '<p class="text-gray-500 p-4">Tidak ada unit tersedia</p>';
        return;
    }

    units.forEach(unit => {
        const item = document.createElement('div');
        item.className = 'unit-item p-3 border-b border-gray-200 cursor-pointer hover:bg-gray-50';
        item.onclick = () => addUnit(unit);
        item.innerHTML = `
            <div class="font-medium">${unit.name || unit.code}</div>
            <div class="text-sm text-gray-500">${unit.code || ''}</div>
        `;
        container.appendChild(item);
    });
}

// Load units for modal
function loadUnitsForModal() {
    fetch('/api/tenants')
        .then(res => res.json())
        .then(units => {
            allUnits = units;
            renderUnitList(units);
        })
        .catch(err => {
            console.error('Error loading units:', err);
            showToast('Gagal memuat daftar unit');
        });
}

// Select unit from modal
function selectUnit(unitCode) {
    if (selectedUnits.includes(unitCode)) {
        showToast('Unit sudah ditambahkan');
        return;
    }

    selectedUnits.push(unitCode);
    renderUnitTags();

    // Close modal
    const modal = bootstrap.Modal.getInstance(document.getElementById('unitModal'));
    modal.hide();

    showToast('Unit berhasil ditambahkan');
}

// Initialize form data
function initializeFormData() {
    console.log('initializeFormData called');
    const urlParams = new URLSearchParams(window.location.search);
    const teacherId = urlParams.get('teacherId');
    console.log('URL teacherId:', teacherId);

    if (teacherId) {
        document.getElementById('teacherId').value = teacherId;
        localStorage.setItem('currentTeacherId', teacherId);
        console.log('Set teacherId field to:', teacherId);
        return teacherId;
    } else {
        const storedTeacherId = localStorage.getItem('currentTeacherId');
        if (storedTeacherId) {
            document.getElementById('teacherId').value = storedTeacherId;
            console.log('Restored teacherId from localStorage:', storedTeacherId);
            return storedTeacherId;
        } else {
            console.error('No teacherId found!');
            showToast('Error: Teacher ID tidak ditemukan. Silakan kembali ke halaman login.');
            return null;
        }
    }
}

// Initialize page when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOMContentLoaded fired - starting initialization');

    // Unit search functionality
    const unitSearch = document.getElementById('unitSearch');
    if (unitSearch) {
        unitSearch.addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            const filteredUnits = allUnits.filter(unit =>
                unit.name.toLowerCase().includes(searchTerm) ||
                unit.code.toLowerCase().includes(searchTerm)
            );
            renderUnitList(filteredUnits);
        });
    }

    // Load jabatan options
    fetch('/api/jabatan-options')
        .then(res => res.json())
        .then(jabatans => {
            const jabatanSelect = document.getElementById('jabatan');
            jabatanSelect.innerHTML = '<option value="">-- Pilih Jabatan --</option>';

            jabatans.forEach(jabatan => {
                const option = document.createElement('option');
                option.value = jabatan.nama_jabatan;
                option.textContent = jabatan.nama_jabatan;
                jabatanSelect.appendChild(option);
            });
        })
        .catch(err => {
            console.error('Error loading jabatan options:', err);
            // Fallback to static options
            document.getElementById('jabatan').innerHTML = `
                <option value="">-- Pilih Jabatan --</option>
                <option value="Ketua">Ketua</option>
                <option value="Kepala Sekolah">Kepala Sekolah</option>
                <option value="Walikelas">Walikelas</option>
                <option value="Mapel">Mapel</option>
                <option value="Mengaji">Mengaji</option>
                <option value="TU">TU</option>
                <option value="Bendahara">Bendahara</option>
                <option value="Lainnya">Lainnya</option>
            `;
        });

    // Load sebagai options
    fetch('/api/sebagai-options')
        .then(res => res.json())
        .then(sebagais => {
            const sebagaiSelect = document.getElementById('sebagai');
            sebagaiSelect.innerHTML = '<option value="">-- Pilih Role --</option>';

            sebagais.forEach(sebagai => {
                const option = document.createElement('option');
                option.value = sebagai.nama_sebagai;
                option.textContent = sebagai.nama_sebagai;
                sebagaiSelect.appendChild(option);
            });
        })
        .catch(err => {
            console.error('Error loading sebagai options:', err);
            // Fallback to static options
            document.getElementById('sebagai').innerHTML = `
                <option value="">-- Pilih --</option>
                <option value="Guru">Guru</option>
                <option value="Siswa">Siswa</option>
                <option value="Karyawan">Karyawan</option>
                <option value="Staf">Staf</option>
            `;
        });

    // Handle jabatan lainnya radio button
    document.querySelectorAll('input[name="jabatanOption"]').forEach(radio => {
        radio.addEventListener('change', function() {
            const customDiv = document.getElementById('customJabatanDiv');
            if (this.value === 'Lainnya') {
                customDiv.style.display = 'block';
                document.getElementById('customJabatan').focus();
            } else {
                customDiv.style.display = 'none';
                document.getElementById('customJabatan').value = '';
            }
        });
    });

    console.log('Starting form initialization');
    // Initialize form data and fetch teacher data
    const teacherId = initializeFormData();
    console.log('Teacher ID from initializeFormData:', teacherId);
    if (!teacherId) {
        console.log('No teacher ID found, returning');
        return;
    }

    // Fetch teacher data
    fetch('/api/teacher-data/' + teacherId)
        .then(res => res.json())
        .then(data => {
            console.log('API Response:', data);

            // Fill form fields
            Object.keys(data).forEach(key => {
                const element = document.getElementById(key);
                if (element) {
                    let value = data[key];
                    if (value && (key === 'tanggal_lahir' || key === 'tmt')) {
                        value = value.split('T')[0];
                    }
                    element.value = value || '';
                    console.log(`Set ${key} to:`, value);
                }
            });

            // Handle tenant/unit information
            if (data.tenant_id) {
                fetch('/api/tenants?code=' + data.tenant_id)
                    .then(res => res.json())
                    .then(tenants => {
                        if (tenants.length > 0) {
                            const tenant = tenants[0];
                            // Update UI if needed
                            console.log('Tenant info:', tenant);
                        }
                    })
                    .catch(err => console.error('Error fetching tenant:', err));
            }

            // Handle jabatan tags if any
            if (data.jabatan_tambahan) {
                try {
                    const jabatanArray = JSON.parse(data.jabatan_tambahan);
                    if (Array.isArray(jabatanArray)) {
                        jabatanArray.forEach(jab => {
                            if (jab && !selectedJabatans.includes(jab)) {
                                selectedJabatans.push(jab);
                            }
                        });
                        renderJabatanTags();
                    }
                } catch (e) {
                    console.error('Error parsing jabatan_tambahan:', e);
                }
            }

            // Handle accessible units if any
            if (data.accessible_units) {
                try {
                    const unitsArray = JSON.parse(data.accessible_units);
                    if (Array.isArray(unitsArray)) {
                        selectedUnits = unitsArray;
                        renderUnitTags();
                    }
                } catch (e) {
                    console.error('Error parsing accessible_units:', e);
                }
            }

        })
        .catch(err => {
            console.error('Error fetching teacher data:', err);
            showToast('Gagal memuat data guru. Silakan refresh halaman.');
        });

}); // Close DOMContentLoaded event listener

// Submit form function
async function submitForm() {
    console.log('Submit button clicked');

    const teacherIdField = document.getElementById('teacherId');
    const teacherIdValue = teacherIdField ? teacherIdField.value : null;

    if (!teacherIdValue) {
        showToast('Error: Teacher ID tidak ditemukan.');
        return;
    }

    // Combine jabatan utama dengan jabatan tambahan
    const jabatanUtama = document.getElementById('jabatan').value;
    const jabatanLainnya = document.getElementById('jabatan_lainnya') ? document.getElementById('jabatan_lainnya').value.trim() : '';

    // Set final jabatan value
    let finalJabatan = jabatanUtama;
    if (jabatanUtama === 'Lainnya' && jabatanLainnya) {
        finalJabatan = jabatanLainnya;
    }
    if (selectedJabatans.length > 0) {
        finalJabatan += ', ' + selectedJabatans.join(', ');
    }

    const form = document.getElementById('completeProfileForm');
    const formData = new FormData(form);
    formData.set('teacherId', teacherIdValue);
    formData.set('jabatan', finalJabatan);

    // Debug logging
    console.log('Form data entries:');
    for (let [key, value] of formData.entries()) {
        console.log(key + ':', value);
    }

    try {
        const response = await fetch('/complete-profile', {
            method: 'POST',
            body: formData
        });

        const result = await response.json();
        console.log('Submit result:', result);

        if (result.success) {
            showToast('Data berhasil disimpan!');

            // Send WhatsApp message
            const nama = document.getElementById('nama').value;
            const jenis_kelamin = document.getElementById('jenis_kelamin').value;
            let no_wa = document.getElementById('no_wa').value;
            if (no_wa && no_wa.startsWith('08')) no_wa = '62' + no_wa.slice(1);

            const ustadz = jenis_kelamin === 'Laki-laki' ? 'Ustadz' : 'Ustadzah';
            const message = `🕌 *Assalamu'alaikum Warahmatullahi Wabarakatuh* 🕌\n\n${ustadz} ${nama} yang terhormat,\n\nAlhamdulillah! 🌟 Profil Anda telah berhasil dilengkapi di sistem YPWI Luwu Timur. Terima kasih atas dedikasi dan komitmen yang luar biasa dalam mengemban amanah sebagai pendidik.\n\n📚 Bersama kita, mari kita bangun generasi unggul yang beriman, berilmu, dan bermanfaat untuk umat.\n\n*Wassalamu'alaikum Warahmatullahi Wabarakatuh* ✨\n\n*YPWI Luwu Timur*`;

            fetch('/api/whatsapp-send', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ number: no_wa, message: message })
            }).catch(err => console.log('WhatsApp send failed:', err));

            setTimeout(() => window.location.href = '/guru/index.html', 2000);
        } else {
            showToast(result.message || 'Terjadi kesalahan saat menyimpan data.');

            // Highlight required fields
            const requiredFields = ['nama', 'niy', 'nik', 'jenis_kelamin', 'tempat_lahir', 'tanggal_lahir', 'alamat', 'no_wa', 'email', 'jenjang', 'jabatan', 'sebagai', 'status_kepegawaian', 'status_aktif', 'keterangan'];
            requiredFields.forEach(field => {
                const element = document.getElementById(field);
                if (element && !element.value.trim()) {
                    element.style.border = '2px solid red';
                }
            });

            const foto = document.getElementById('foto');
            if (foto && foto.files.length === 0) {
                foto.style.border = '2px solid red';
            }
        }
    } catch (error) {
        console.error('Submit error:', error);
        showToast('Terjadi kesalahan: ' + error.message);
    }
}