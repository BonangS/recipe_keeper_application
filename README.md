# Aplikasi Recipe Keeper

Aplikasi Flutter untuk menyimpan dan mengelola resep makanan pribadi.

## Fitur

- Autentikasi Pengguna (Supabase Auth)
  - Daftar dengan email dan password
  - Masuk dengan akun yang sudah ada
  - Keluar dari aplikasi
- Pengelolaan Resep
  - Tambah resep baru dengan nama, deskripsi, dan bahan-bahan
  - Lihat daftar resep tersimpan
  - Hapus resep
- Status Login Persisten
  - Menggunakan SharedPreferences untuk mempertahankan status login
- Layar Perkenalan (Get Started)
  - Ditampilkan hanya pada peluncuran aplikasi pertama kali
  - Memandu pengguna baru melalui aplikasi

## Teknologi yang Digunakan

- Flutter
- Supabase untuk autentikasi dan database
- SharedPreferences untuk penyimpanan lokal
- Provider untuk manajemen state
- GoRouter untuk navigasi
- Google Fonts untuk tipografi

## Instalasi dan Pengaturan

1. Clone repositori ini
2. Install Flutter jika belum terinstall (https://flutter.dev/docs/get-started/install)
3. Install dependensi:
   ```bash
   flutter pub get
   ```
4. Pengaturan Supabase:
   - Buat proyek Supabase baru di https://app.supabase.io/
   - Dapatkan URL dan API key dari panel Settings > API
   - Tambahkan kredensial tersebut ke aplikasi (biasanya dalam file .env atau constants)
   - Aktifkan autentikasi Email/Password di Authentication > Settings
   - Buat tabel yang diperlukan di Database

5. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Kredensial Uji

Untuk keperluan pengujian, Anda dapat menggunakan kredensial berikut:
- Email: kluv1342@gmail.com
- Password: 123456


