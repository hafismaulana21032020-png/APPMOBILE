# BreakFree Mobile App

Aplikasi mobile kedai kopi modern yang dibangun menggunakan Flutter dengan pendekatan arsitektur **Feature-First Clean Architecture**.

---

## 📁 Struktur Direktori Project

Struktur folder ditata secara modular, bersih, dan profesional untuk memudahkan kolaborasi tim dan skalabilitas pengembangan fitur:

```
breakfree_app/
├── assets/
│   └── images/                       # Asset gambar lokal (banner kopi, ilustrasi, dll.)
│       └── coffee_banner.jpg
├── lib/
│   ├── app.dart                      # Konfigurasi root MaterialApp & Theme
│   ├── main.dart                     # Entry point aplikasi & initial service setup
│   │
│   ├── core/                         # Komponen global yang dipakai lintas fitur
│   │   ├── constants/                # Nilai konstan (dimensi, asset path, dll.)
│   │   │   ├── app_assets.dart       # Path asset gambar & ikon terpusat
│   │   │   ├── app_colors.dart       # Re-export AppColors (backward compatibility)
│   │   │   └── app_dimensions.dart   # Standar padding, margin, radius & tinggi widget
│   │   ├── routes/                   # Sistem navigasi & routing aplikasi
│   │   │   ├── app_router.dart       # onGenerateRoute handler & page routing
│   │   │   └── app_routes.dart       # Definisi nama route terpusat ('/login', '/home', dll.)
│   │   ├── theme/                    # Design system aplikasi
│   │   │   ├── app_colors.dart       # Palet warna resmi BreakFree
│   │   │   ├── app_text_styles.dart  # Tipografi & style teks terstandarisasi
│   │   │   └── app_theme.dart        # Konfigurasi ThemeData Flutter
│   │   └── widgets/                  # Widget umum yang dapat digunakan kembali
│   │       ├── auth_header_bar.dart  # Custom header bar (tombol back + brand BreakFree)
│   │       ├── custom_button.dart    # Tombol utama terstandarisasi (loading state ready)
│   │       └── custom_text_field.dart# Input field terstandarisasi dengan label opsional
│   │
│   └── features/                     # Modul fitur mandiri (Feature-First)
│       ├── auth/                     # Fitur Autentikasi
│       │   └── presentation/         # Tampilan UI fitur Auth
│       │       ├── pages/            # Halaman utama
│       │       │   ├── forgot_password_page.dart  # Halaman lupa password & OTP (3 step)
│       │       │   ├── login_page.dart            # Halaman login
│       │       │   └── register_page.dart         # Halaman pendaftaran akun
│       │       └── widgets/          # Komponen UI spesifik fitur Auth
│       │           ├── auth_info_card.dart        # Kartu info/promo mini
│       │           ├── coffee_banner.dart         # Banner visual kopi pada halaman login
│       │           ├── otp_input_fields.dart      # Input 4 digit OTP dengan auto-focus
│       │           └── reset_password_success_dialog.dart # Modal dialog sukses reset password
│       │
│       └── home/                     # Fitur Utama / Beranda (Katalog Kopi & Keranjang)
│           ├── domain/
│           │   └── models/
│           │       └── product_model.dart         # Model entitas produk katalog
│           └── presentation/
│               ├── pages/
│               │   └── home_page.dart             # Halaman Beranda lengkap
│               └── widgets/
│                   ├── category_filter_list.dart  # Filter kategori (Kopi, Non-Kopi, Makanan, Snack)
│                   ├── floating_cart_bar.dart     # Bar floating keranjang mengambang
│                   ├── home_bottom_nav_bar.dart   # Bottom navigation bar (Home, Pesanan, AI, Akun)
│                   ├── home_header.dart           # Header brand BreakFree Malang
│                   ├── home_promo_banner.dart     # Banner kartu promo mahasiswa
│                   ├── home_search_bar.dart       # Search bar pencarian menu
│                   └── product_card.dart          # Kartu item menu 2 kolom dengan tombol + Tambah
│
├── test/
│   └── widget_test.dart              # Smoke test & widget testing
├── pubspec.yaml                      # Konfigurasi dependensi project
└── README.md                         # Dokumentasi arsitektur project
```

---

## 🎨 Design System & Core Standards

1. **Warna (`AppColors`)**:
   - `primaryBrown` (`#6E513B`) & `darkBrown` (`#5A412F`) - Identitas brand utama BreakFree.
   - `promoBadgeColor` (`#F6C65C`) & `buttonYellow` (`#FDF0CD`) - Aksen promo dan tombol "+ Tambah" / "Lihat Keranjang".
   - `backgroundColor` (`#FAF8F5`) - Latar scaffold nuansa hangat/cream.
   - `darkText` (`#1E1E1E`) & `secondaryText` (`#757575`) - Kontras teks optimal.

2. **Routing Terpusat (`AppRoutes` & `AppRouter`)**:
   - `AppRoutes.login` (`/login`)
   - `AppRoutes.register` (`/register`)
   - `AppRoutes.forgotPassword` (`/forgot-password`)
   - `AppRoutes.home` (`/home`)

---

## 🚀 Menjalankan Project

```bash
# Pastikan dependensi terpasang
flutter pub get

# Jalankan aplikasi pada simulator / device
flutter run
```
"# Breakfree-Hub" 
