# 🐾 Cozypaws – Implementasi Sistem Database pada Aplikasi Petcare

Aplikasi **Cozypaws** merupakan proyek akhir mata kuliah **Basis Data** yang dikembangkan oleh mahasiswa Program Studi **Informatika Universitas Negeri Surabaya (Kampus 5)**.  Proyek ini mengimplementasikan sistem basis data **MongoDB** untuk aplikasi **manajemen perawatan hewan peliharaan** berbasis **(Flutter)**.

---

## 📚 Deskripsi Proyek

Cozypaws adalah aplikasi layanan yang membantu pemilik hewan peliharaan dalam:
- Mengelola **profil pengguna dan staf layanan**.
- Melakukan **pemesanan (appointment)** layanan perawatan hewan.
- Menyediakan **produk dan pemesanan barang** untuk kebutuhan hewan.
- Memberikan **ulasan (review)** terhadap layanan yang digunakan.

Aplikasi ini dirancang menggunakan **arsitektur client-server** dengan teknologi modern:
- **Frontend:** Flutter  
- **Backend:** Node.js  
- **Database:** MongoDB  

---

## 🗃️ Struktur Database (MongoDB)

Database terdiri dari 7 koleksi utama:

| Collection | Deskripsi |
|-------------|------------|
| **users** | Menyimpan data pengguna aplikasi (pemilik hewan/pelanggan) termasuk profil, kontak, dan autentikasi. |
| **staff** | Menyimpan data dokter hewan, groomer, atau staf penyedia layanan. |
| **appointments** | Menyimpan data pemesanan layanan seperti konsultasi, vaksinasi, dan grooming. |
| **products** | Menyimpan data produk yang dijual (makanan, perlengkapan, vitamin, dll). |
| **orders** | Menyimpan data pesanan produk dari pengguna, terhubung ke `users` dan `products`. |
| **payments** | Menyimpan data transaksi pembayaran untuk layanan maupun pesanan produk. |
| **reviews** | Menyimpan ulasan dan rating pengguna terhadap layanan atau produk yang telah digunakan/dibeli. |


## 👨‍💻 Tim Pengembang

Dibuat oleh:

1. Muhhmmad Rifqi Iqbal Ghufron (24111814073)

2. Febriana Nur Aini (24111814006)

3. Faqih Rafasha Argandhi (24111814032)

4. M.Amrullah Widyapratama (24111814136)

5. Muhammad Dava Khoirur Roziqy (24111814068)

**Dosen Pengampu:** Bonda Sisephaputra, M.Kom  
**Mata Kuliah:** Basis Data – Semester 3  
**Program Studi:** S1 Informatika – Universitas Negeri Surabaya (UNESA) Kampus 5
