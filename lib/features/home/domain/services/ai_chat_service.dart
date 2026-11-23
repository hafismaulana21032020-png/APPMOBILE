import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../../core/services/api_service.dart';
import '../../data/menu_data.dart';
import '../../domain/models/product_model.dart';
import '../../../order/domain/services/order_service.dart';
import '../models/chat_message_model.dart';

/// Service that powers the BreakFree AI Barista chat bot.
/// Provides intelligent conversation handling, menu recommendations,
/// cafe information, and direct menu-item linking via Gemini API backend.
class AiChatService extends ChangeNotifier {
  AiChatService._() {
    _initializeChat();
  }

  static final AiChatService instance = AiChatService._();

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  /// Default quick suggestion chips to help the user ask clear questions.
  static const List<String> defaultQuickSuggestions = [
    'Kopi Manis & Creamy',
    'Kopi Strong / Nugas',
    'Non-Kopi Segar',
    'Makanan Lapar',
    'Camilan Nongkrong',
    'Info Promo BREAK20',
    'Jam Buka & Wi-Fi',
    'Lacak Status Pesanan',
    'Kopi Aman di Lambung',
  ];

  void _initializeChat() {
    _messages.clear();

    final starterProducts = _findProducts(['ic-3', 'nk-s-5', 'snack-2']);

    _messages.add(
      ChatMessage(
        id: 'msg-welcome',
        text:
            'Halo kak! Selamat datang di BreakFree Coffee.\n\n'
            'Saya **Barista AI BreakFree**. Saya siap bantu kamu menemukan racikan menu yang paling cocok dengan seleramu, rekomendasi camilan, hingga info promo hari ini.\n\n'
            'Ada yang ingin kamu tanyakan atau cari hari ini?',
        isUser: false,
        timestamp: DateTime.now(),
        products: starterProducts,
        quickReplies: defaultQuickSuggestions,
      ),
    );
  }

  /// Resets the conversation back to the initial greeting.
  void resetChat() {
    _initializeChat();
    _isTyping = false;
    notifyListeners();
  }

  /// Finds a product by ID safely from [breakfreeMenuItems].
  ProductModel? _findProduct(String id) {
    try {
      return breakfreeMenuItems.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Finds multiple products matching IDs safely.
  List<ProductModel> _findProducts(List<String> ids) {
    final list = <ProductModel>[];
    for (final id in ids) {
      final p = _findProduct(id);
      if (p != null) list.add(p);
    }
    return list;
  }

  /// Sends a user message and triggers the AI Barista bot response via Backend Gemini API.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // 1. Add user message
    final userMsg = ChatMessage(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isTyping = true;
    notifyListeners();

    try {
      // 2. Prepare conversation history for Gemini API
      final history = <Map<String, String>>[];
      for (int i = 0; i < _messages.length - 1; i++) {
        final m = _messages[i];
        if (m.id == 'msg-welcome') continue;
        history.add({
          'role': m.isUser ? 'user' : 'model',
          'text': m.text,
        });
      }

      // 3. Request backend live Barista AI
      final response = await ApiService.instance.chatWithBarista(
        message: trimmed,
        history: history,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final reply = data['reply']?.toString() ?? 'Halo kak, ada yang bisa saya bantu?';
        final rawProducts = data['recommendedProducts'] as List? ?? [];
        final products = <ProductModel>[];

        for (final p in rawProducts) {
          if (p is Map<String, dynamic>) {
            products.add(ProductModel.fromJson(p));
          }
        }

        final now = DateTime.now();
        final botResponse = ChatMessage(
          id: 'bot-${now.millisecondsSinceEpoch}',
          text: reply,
          isUser: false,
          timestamp: now,
          products: products,
          quickReplies: _getFollowUpSuggestions(trimmed, products),
        );
        _messages.add(botResponse);
      } else {
        // Fallback to intelligent local keyword response if backend returns non-success
        final botResponse = _generateBaristaResponse(trimmed);
        _messages.add(botResponse);
      }
    } catch (e) {
      debugPrint('Error in AiChatService.sendMessage: $e');
      final botResponse = _generateBaristaResponse(trimmed);
      _messages.add(botResponse);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  List<String> _getFollowUpSuggestions(String query, List<ProductModel> products) {
    if (products.isNotEmpty) {
      return [
        'Kopi Manis & Creamy',
        'Kopi Strong / Nugas',
        'Camilan Pendamping',
        'Info Promo BREAK20',
        'Jam Buka Kafe',
      ];
    }
    return defaultQuickSuggestions;
  }

  ChatMessage _generateBaristaResponse(String query) {
    final q = query.toLowerCase();
    final now = DateTime.now();
    final id = 'bot-${now.millisecondsSinceEpoch}';

    // ---------------------------------------------------------
    // 0. DETEKSI NEGASI / PENGECUALIAN (BUKAN NASI, JANGAN YANG NASI, BUKAN KOPI, DLL)
    // ---------------------------------------------------------
    bool hasNegation(String keyword) {
      final reg = RegExp(
        r'(bukan|tanpa|selain|gak\s*mau|nggak\s*mau|gak\s*pake|nggak\s*pake|jangan|hindari|tidak\s*mau|tidak\s*pake)\s*(yang\s*|menu\s*|makanan\s*|minuman\s*|pake\s*)?' +
            keyword,
        caseSensitive: false,
      );
      return reg.hasMatch(q);
    }

    final excludeNasi = hasNegation('nasi');
    final excludeMie = hasNegation('mie') || hasNegation('indomie');
    final excludeKopi = hasNegation('kopi') ||
        hasNegation('coffee') ||
        hasNegation('kafein') ||
        q.contains('non-kopi') ||
        q.contains('non kopi') ||
        q.contains('bukan kopi') ||
        q.contains('tanpa kafein');

    // ---------------------------------------------------------
    // 0.1 PRIORITAS NEGASI NASI (MISAL: "JANGAN YANG NASI KAK")
    // ---------------------------------------------------------
    if (excludeNasi) {
      return ChatMessage(
        id: id,
        text:
            'Siap kak! Kalau lagi gak mau makan nasi, tenang aja ya. Dapur BreakFree punya sajian olahan mie dan camilan kenyang yang gurih nikmat:\n\n'
            '• **Indomie Nyemek**: Menu terfavorit kami! Mie dengan kuah kental gurih berempah dan telur.\n'
            '• **Indomie Goreng**: Indomie klasik dengan taburan bawang goreng renyah.\n'
            '• **Mix Platter**: Porsi komplit isi sosis, kentang goreng, dan nugget buat ganjal lapar!',
        isUser: false,
        timestamp: now,
        products: _findProducts(['m-in-1', 'm-ig-1', 'snack-6']),
        quickReplies: ['Minuman Pendamping', 'Paket Indomie + Es Teh', 'Camilan Tambahan'],
      );
    }

    // ---------------------------------------------------------
    // 0.2 PRIORITAS NEGASI MIE (MISAL: "JANGAN MIE", "BUKAN MIE")
    // ---------------------------------------------------------
    if (excludeMie) {
      return ChatMessage(
        id: id,
        text:
            'Siap kak! Kalau lagi nggak mau mie, kami punya menu nasi hangat yang siap mengenyangkan:\n\n'
            '• **Nasi Goreng Telur**: Nasi goreng hangat harum bumbu khas lengkap dengan telur.\n'
            '• **Nasi Telur Barendo**: Nasi pulen dengan telur barendo crispy gurih.\n'
            '• **Nasi Ayam Krispi**: Potongan ayam krispi renyah dengan sambal mantap.',
        isUser: false,
        timestamp: now,
        products: _findProducts(['m-np-1', 'm-np-2', 'm-np-3']),
        quickReplies: ['Minuman Pendamping', 'Es Teh Segar', 'Info Promo'],
      );
    }

    // ---------------------------------------------------------
    // 1. PROMO / VOUCHER / DISKON / HEMAT
    // ---------------------------------------------------------
    if (_matches(q, ['promo', 'voucher', 'diskon', 'kode', 'break20', 'potongan', 'murah', 'hemat'])) {
      return ChatMessage(
        id: id,
        text:
            'Kabar baik kak! Hari ini ada promo spesial untukmu di BreakFree:\n\n'
            '• **Voucher BREAK20**: Diskon 20% untuk semua pesanan di keranjang belanja. Cukup masukkan kode **BREAK20** saat checkout.\n'
            '• **Paket Berdua**: Dapatkan 2 Ice Kopi Susu hanya **Rp28.000** (hemat Rp4.000)!\n'
            '• **Cashback Poin**: Kumpulkan poin setiap transaksi untuk ditukar diskon dan kopi gratis.\n\n'
            'Mau langsung coba pesan menu favoritmu?',
        isUser: false,
        timestamp: now,
        products: _findProducts(['ic-3', 'ic-2', 'm-np-1']),
        quickReplies: ['Pakai Voucher BREAK20', 'Lihat Menu Kopi', 'Camilan Favorit'],
      );
    }

    // ---------------------------------------------------------
    // 2. MINUMAN COKLAT / CHOCOLATE (DIPRIORITASKAN AGAR TIDAK KELUAR KOPI)
    // ---------------------------------------------------------
    if (_matches(q, ['coklat', 'cokelat', 'chocolate', 'choco', 'kakao'])) {
      return ChatMessage(
        id: id,
        text:
            'Pilihan mantap buat kamu pencinta cokelat! Di BreakFree kami punya racikan cokelat manis yang lembut dan lumer:\n\n'
            '• **Signature Coklat**: Coklat dingin khas yang manis, creamy, dan pekat.\n'
            '• **Hot Coklat Milk**: Seduhan coklat hangat berpadu susu segar yang menenangkan.\n'
            '• **Hot Coklat Ori**: Cita rasa kakao original yang kaya dan harum.',
        isUser: false,
        timestamp: now,
        products: _findProducts(['nk-s-2', 'nk-c-2', 'nk-c-1']),
        quickReplies: ['Camilan Pendamping Coklat', 'Minuman Non-Kopi Lain', 'Info Promo BREAK20'],
      );
    }

    // ---------------------------------------------------------
    // 3. MATCHA / GREEN TEA
    // ---------------------------------------------------------
    if (_matches(q, ['matcha', 'green tea', 'teh hijau'])) {
      return ChatMessage(
        id: id,
        text:
            'Untuk pencinta matcha, kami punya **Signature Matcha** premium dengan karakter teh hijau autentik yang dipadukan susu creamy lembut.',
        isUser: false,
        timestamp: now,
        products: _findProducts(['nk-s-5']),
        quickReplies: ['Camilan Teman Matcha', 'Menu Red Velvet & Taro', 'Minuman Segar Lain'],
      );
    }

    // ---------------------------------------------------------
    // 4. MAKANAN & LAPAR (MEMPERHATIKAN NEGASI "BUKAN NASI" / "BUKAN MIE")
    // ---------------------------------------------------------
    if (_matches(q, ['makan', 'lapar', 'kenyang', 'laper'])) {
      if (excludeNasi) {
        return ChatMessage(
          id: id,
          text:
              'Mau makan tapi lagi nggak pengen nasi? Pas banget kak! Dapur BreakFree punya sajian mie gurih dan camilan kenyang:\n\n'
              '• **Indomie Nyemek**: Menu terfavorit kami! Mie dengan kuah kental gurih berempah dan telur.\n'
              '• **Indomie Goreng**: Indomie klasik dengan taburan bawang goreng renyah.\n'
              '• **Mix Platter**: Porsi komplit isi sosis, kentang goreng, dan nugget buat ganjal lapar!',
          isUser: false,
          timestamp: now,
          products: _findProducts(['m-in-1', 'm-ig-1', 'snack-6']),
          quickReplies: ['Minuman Pendamping', 'Paket Indomie + Es Teh', 'Camilan Tambahan'],
        );
      } else if (excludeMie) {
        return ChatMessage(
          id: id,
          text:
              'Kalau lagi nggak mau mie, kami punya menu nasi hangat yang siap mengenyangkan:\n\n'
              '• **Nasi Goreng Telur**: Nasi goreng hangat harum bumbu khas lengkap dengan telur.\n'
              '• **Nasi Telur Barendo**: Nasi pulen dengan telur barendo crispy gurih.\n'
              '• **Nasi Ayam Krispi**: Potongan ayam krispi renyah dengan sambal mantap.',
          isUser: false,
          timestamp: now,
          products: _findProducts(['m-np-1', 'm-np-2', 'm-np-3']),
          quickReplies: ['Minuman Pendamping', 'Es Teh Segar', 'Info Promo'],
        );
      } else {
        return ChatMessage(
          id: id,
          text:
              'Lagi lapar berat kak? Dapur BreakFree siap menyajikan hidangan hangat dan lezat:\n\n'
              '• **Indomie Nyemek**: Best seller kami! Kuah kental gurih dengan telur dan rempah nikmat.\n'
              '• **Nasi Goreng Telur**: Nasi goreng wangi disajikan hangat.\n'
              '• **Nasi Telur Barendo**: Nasi pulen dengan telur crispy gurih.',
          isUser: false,
          timestamp: now,
          products: _findProducts(['m-in-1', 'm-np-1', 'm-np-2']),
          quickReplies: ['Minuman Pendamping Makanan', 'Camilan Tambahan', 'Pakai Promo BREAK20'],
        );
      }
    }

    // ---------------------------------------------------------
    // 5. MIE / INDOMIE SECARA SPESIFIK
    // ---------------------------------------------------------
    if (_matches(q, ['mie', 'indomie', 'nyemek'])) {
      return ChatMessage(
        id: id,
        text:
            'Indomie lovers merapat! Kami punya pilihan olahan mie andalan:\n\n'
            '• **Indomie Nyemek**: Kuah medok berempah dengan telur dan sayur segar.\n'
            '• **Indomie Goreng**: Gurih nikmat klasik favorit sepanjang masa.',
        isUser: false,
        timestamp: now,
        products: _findProducts(['m-in-1', 'm-ig-1']),
        quickReplies: ['Minuman Pendamping', 'Tambah Telur', 'Camilan Goreng'],
      );
    }

    // ---------------------------------------------------------
    // 6. NASI SECARA SPESIFIK (JIKA TIDAK DI-EXCLUDE)
    // ---------------------------------------------------------
    if (_matches(q, ['nasi']) && !excludeNasi) {
      return ChatMessage(
        id: id,
        text:
            'Menu nasi hangat BreakFree siap bikin kenyang:\n\n'
            '• **Nasi Goreng Telur**: Porsi pas dengan cita rasa gurih nagih.\n'
            '• **Nasi Telur Barendo**: Telur khas renyah berpadu nasi hangat pulen.',
        isUser: false,
        timestamp: now,
        products: _findProducts(['m-np-1', 'm-np-2']),
        quickReplies: ['Minuman Pendamping', 'Tambah Es Teh', 'Info Promo'],
      );
    }

    // ---------------------------------------------------------
    // 7. KOPI MANIS & CREAMY (JIKA TIDAK DI-EXCLUDE)
    // ---------------------------------------------------------
    if (!excludeKopi && _matches(q, ['manis', 'creamy', 'susu', 'aren', 'caramel', 'vanilla', 'hazelnut', 'legit'])) {
      return ChatMessage(
        id: id,
        text:
            'Untuk kamu yang suka rasa kopi manis, lembut, dan creamy, ini menu juara rekomendasi Barista kami:\n\n'
            '1. **Breakfree Aren Latte**: Perpaduan espresso mantap, susu ekstra creamy, dan gula aren asli yang legit.\n'
            '2. **Caramel Macchiato**: Sentuhan saus karamel gurih-manis yang lumer di lidah.\n'
            '3. **Kopi Susu Sarijan**: Pilihan hangat klasik dengan paduan susu creamy lembut.\n\n'
            'Silakan klik **+ Tambah** di bawah untuk langsung memasukkannya ke keranjangmu!',
        isUser: false,
        timestamp: now,
        products: _findProducts(['ic-3', 'ic-4', 'hc-3']),
        quickReplies: ['Ada rekomendasi snack?', 'Kopi yang strong?', 'Minuman non-kopi?'],
      );
    }

    // ---------------------------------------------------------
    // 8. KOPI STRONG / PAHIT / BEGADANG / NUGAS (JIKA TIDAK DI-EXCLUDE)
    // ---------------------------------------------------------
    if (!excludeKopi && _matches(q, ['strong', 'kuat', 'pahit', 'begadang', 'nugas', 'melek', 'kafein', 'hitam', 'americano', 'espresso', 'mata segar'])) {
      return ChatMessage(
        id: id,
        text:
            'Butuh suntikan energi ekstra untuk nugas malam atau fokus kerja? Ini rekomendasi kopi mantap tanpa kompromi:\n\n'
            '1. **Ice Kopi Ori**: Espresso murni dingin tanpa pemanis berlebih, bold dan menyegarkan mata.\n'
            '2. **Kopi Hitam Sarijan**: Diseduh tradisional dari biji pilihan, rasa roasted kuat yang khas.\n'
            '3. **Kopi Ijo**: Racikan legendaris khas Malang dengan aroma sangrai unik yang bikin fresh sepanjang hari.',
        isUser: false,
        timestamp: now,
        products: _findProducts(['ic-1', 'hc-1', 'hc-5']),
        quickReplies: ['Kopi Manis & Creamy', 'Camilan Teman Nugas', 'Info Wi-Fi & Colokan'],
      );
    }

    // ---------------------------------------------------------
    // 4. ASAM LAMBUNG / MAAG / SENSITIF KOPI
    // ---------------------------------------------------------
    if (_matches(q, ['lambung', 'maag', 'asam', 'perut', 'sensitif', 'aman'])) {
      return ChatMessage(
        id: id,
        text:
            'Tips dari Barista BreakFree untuk yang sensitif asam lambung atau maag:\n\n'
            '• **Pilih kopi dengan susu**: Seperti **Breakfree Aren Latte** atau **Kopi Susu Sarijan** karena kandungan susu membantu menetralkan keasaman espresso di lambung.\n'
            '• **Pastikan perut terisi**: Pesan dulu camilan seperti French Fries atau Nasi Telur Barendo.\n'
            '• **Opsi Non-Kopi**: Varian **Signature Matcha** atau **Signature Red Velvet** kami 100% bebas kafein kopi dan sangat ramah di lambung!',
        isUser: false,
        timestamp: now,
        products: _findProducts(['ic-3', 'nk-s-5', 'snack-2']),
        quickReplies: ['Minuman Non-Kopi Lainnya', 'Pesan Nasi Telur Barendo', 'Kopi Manis'],
      );
    }

    // ---------------------------------------------------------
    // 5. NON-KOPI SEGAR & BUAH (DINGIN / TEH)
    // ---------------------------------------------------------
    if (_matches(q, ['segar', 'fresh', 'buah', 'leci', 'lychee', 'lemon', 'teh', 'dingin', 'haus', 'fizz'])) {
      return ChatMessage(
        id: id,
        text:
            'Lagi pengen yang seger-seger dingin pelepas dahaga? Ini deretan minuman non-kopi paling favorit di siang hari:\n\n'
            '• **Lychee Tea**: Teh manis dingin dengan aroma leci tropis yang super wangi.\n'
            '• **Lemon Tea**: Perpaduan teh dan perasan lemon segar yang cerah dan membangkitkan mood.\n'
            '• **Grape Fizz**: Minuman anggur berkarbonasi ringan yang bikin tenggorokan plong!',
        isUser: false,
        timestamp: now,
        products: _findProducts(['nk-t-3', 'nk-t-2', 'nk-t-6']),
        quickReplies: ['Non-Kopi Creamy', 'Camilan Goreng', 'Menu Makanan'],
      );
    }

    // ---------------------------------------------------------
    // 9. CAMILAN / SNACK / NGEMIL / CIRENG / KENTANG / FRIES
    // ---------------------------------------------------------
    if (_matches(q, ['snack', 'camilan', 'cemilan', 'ngemil', 'kentang', 'fries', 'cireng', 'bakso', 'gyoza', 'platter', 'pao'])) {
      return ChatMessage(
        id: id,
        text:
            'Nongkrong tanpa ngemil rasanya kurang lengkap! Ini camilan paling renyah & gurih buat temen ngobrol:\n\n'
            '• **French Fries**: Kentang goreng renyah keemasan dengan saus cocolan gurih.\n'
            '• **Cireng**: Tekstur kenyal renyah di luar dengan cocolan saus pedas manis mantap.\n'
            '• **Mix Platter**: Porsi komplit isi nugget ayam, kentang, dan sosis buat rame-rame!',
        isUser: false,
        timestamp: now,
        products: _findProducts(['snack-2', 'snack-3', 'snack-6', 'snack-4']),
        quickReplies: ['Rekomendasi Kopi', 'Minuman Segar', 'Paket Berdua'],
      );
    }

    // ---------------------------------------------------------
    // 9. JAM BUKA, LOKASI, FASILITAS, WI-FI, COLOKAN
    // ---------------------------------------------------------
    if (_matches(q, ['jam', 'buka', 'tutup', 'lokasi', 'alamat', 'dimana', 'wifi', 'wi-fi', 'colokan', 'stopkontak', 'fasilitas', 'nongkrong', 'tempat'])) {
      return ChatMessage(
        id: id,
        text:
            'Berikut informasi lengkap tentang BreakFree Coffee:\n\n'
            '• **Jam Operasional**: Buka setiap hari pukul **08.00 - 23.00 WIB**.\n'
            '• **Lokasi**: Pusat kota Malang, Jawa Timur (akses mudah & parkir luas).\n'
            '• **Fasilitas**: \n'
            '  - Free High-Speed Wi-Fi (cocok buat nugas & WFC)\n'
            '  - Stopkontak/colokan di hampir setiap meja\n'
            '  - Area Indoor ber-AC & Outdoor semi-terbuka yang asri\n'
            '  - Musholla & toilet bersih\n\n'
            'Yuk mampir atau pesan menu favoritmu sekarang!',
        isUser: false,
        timestamp: now,
        products: _findProducts(['ic-3', 'snack-2']),
        quickReplies: ['Lihat Menu Kopi', 'Promo Hari Ini', 'Cara Pesan'],
      );
    }

    // ---------------------------------------------------------
    // 10. CARA PESAN & METODE PEMBAYARAN
    // ---------------------------------------------------------
    if (_matches(q, ['cara pesan', 'order', 'pesan', 'bayar', 'pembayaran', 'qris', 'gopay', 'ovo', 'tunai'])) {
      return ChatMessage(
        id: id,
        text:
            'Cara memesan di aplikasi BreakFree sangat mudah:\n\n'
            '1. Pilih menu yang kamu inginkan lalu klik tombol **+ Tambah**.\n'
            '2. Klik ikon Keranjang di kanan bawah atau tombol Lihat.\n'
            '3. Masukkan kode promo **BREAK20** untuk klaim diskon 20%.\n'
            '4. Klik Checkout dan selesaikan pembayaran via **QRIS**, **E-Wallet** (GoPay, OVO, Dana), atau Tunai di kasir.\n'
            '5. Ambil pesananmu di bar counter saat nomor pesanan dipanggil!',
        isUser: false,
        timestamp: now,
        products: _findProducts(['ic-3', 'm-in-1']),
        quickReplies: ['Lacak Pesanan Saya', 'Pakai Promo BREAK20', 'Rekomendasi Kopi'],
      );
    }

    // ---------------------------------------------------------
    // 11. LACAK PESANAN (LIVE TRACKING)
    // ---------------------------------------------------------
    if (_matches(q, ['lacak', 'tracking', 'status pesanan', 'antrean', 'sudah siap', 'kapan jadi'])) {
      final active = OrderService.instance.activeOrder;
      if (active != null) {
        return ChatMessage(
          id: id,
          text:
              'Status pesanan kamu saat ini:\n\n'
              '• **Nomor Pesanan**: ${active.id}\n'
              '• **Nomor Antrean**: ${active.queueNumber} (${active.counterName})\n'
              '• **Status**: **${active.status.title}**\n'
              '• **Perkiraan**: ~${active.estimatedMinutes} menit lagi\n'
              '• **Catatan Barista**: "${active.baristaNote}"\n\n'
              'Kamu bisa buka menu **Lacak Pesanan** di tab Akun untuk melihat live stepper & rincian lengkap!',
          isUser: false,
          timestamp: now,
          quickReplies: ['Menu Lainnya', 'Info Promo BREAK20', 'Jam Buka'],
        );
      } else {
        return ChatMessage(
          id: id,
          text:
              'Saat ini kamu belum memiliki pesanan aktif. Silakan pilih menu kopi atau makanan favoritmu, lalu lakukan checkout untuk mulai melacak pesanan secara live!',
          isUser: false,
          timestamp: now,
          products: _findProducts(['ic-3', 'snack-2']),
          quickReplies: ['Lihat Menu Kopi', 'Camilan Favorit', 'Info Promo'],
        );
      }
    }

    // ---------------------------------------------------------
    // 12. PENCARIAN NAMA PRODUK TERTENTU
    // ---------------------------------------------------------
    final matchingProducts = breakfreeMenuItems.where((p) {
      final name = p.name.toLowerCase();
      final desc = p.description.toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).take(3).toList();

    if (matchingProducts.isNotEmpty && q.length >= 3) {
      final names = matchingProducts.map((p) => '• **${p.name}** (${p.formattedPrice})').join('\n');
      return ChatMessage(
        id: id,
        text:
            'Saya menemukan menu yang cocok dengan pencarianmu:\n\n'
            '$names\n\n'
            'Kamu bisa langsung klik **+ Tambah** pada menu di bawah ini untuk memesannya:',
        isUser: false,
        timestamp: now,
        products: matchingProducts,
        quickReplies: ['Rekomendasi Lainnya', 'Info Promo BREAK20', 'Minuman Segar'],
      );
    }

    // ---------------------------------------------------------
    // 13. FALLBACK UMUM / RAMAH BARISTA
    // ---------------------------------------------------------
    return ChatMessage(
      id: id,
      text:
          'Terima kasih sudah bertanya kak!\n\n'
          'Sebagai Barista AI BreakFree, saya bisa memberikan rekomendasi racikan minuman terbaik, makanan lezat, atau camilan yang pas buat temani harimu.\n\n'
          'Coba ceritakan apa yang lagi kamu inginkan? Misalnya: *"mau kopi manis"*, *"minuman non-kopi yang segar"*, *"makanan kenyang"*, atau *"ada diskon apa hari ini?"*.',
      isUser: false,
      timestamp: now,
      products: _findProducts(['ic-3', 'nk-s-5', 'm-in-1']),
      quickReplies: defaultQuickSuggestions,
    );
  }

  bool _matches(String text, List<String> keywords) {
    for (final kw in keywords) {
      if (text.contains(kw)) return true;
    }
    return false;
  }
}
