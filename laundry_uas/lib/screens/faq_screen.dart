import 'package:flutter/material.dart';

// ============================================================
// DESIGN TOKENS — konsisten dengan Home & Profile
// ============================================================
class _FT {
  static const purple = Color(0xFF6C63FF);
  static const purpleContainer = Color(0xFFEEEDFE);
  static const bg = Color(0xFFF5F6FA);
  static const ink = Color(0xFF1A1A2E);

  static const rLg = 20.0;
  static const rMd = 16.0;
  static const rSm = 12.0;
  static const rPill = 999.0;

  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;

  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

class _FaqItem {
  final String question;
  final List<String> steps;
  const _FaqItem({required this.question, required this.steps});
}

// Dummy data — tidak ada backend, murni statis.
const List<_FaqItem> _faqData = [
  _FaqItem(
    question: 'Bagaimana cara membuat pesanan?',
    steps: [
      'Buka tab Home.',
      'Ketuk tombol "Buat Pesanan Baru".',
      'Pilih jenis layanan (Cuci, Setrika, Ekspres, atau Cuci+Setrika).',
      'Isi berat cucian dan data yang diperlukan.',
      'Ketuk "Simpan" untuk mengonfirmasi pesanan.',
    ],
  ),
  _FaqItem(
    question: 'Bagaimana cara membuat akun?',
    steps: [
      'Buka halaman Login.',
      'Ketuk "Daftar" di bagian bawah halaman.',
      'Isi email, username, dan kata sandi.',
      'Ketuk "Buat Akun" untuk menyelesaikan pendaftaran.',
    ],
  ),
  _FaqItem(
    question: 'Bagaimana cara login?',
    steps: [
      'Buka halaman Login.',
      'Masukkan email, username dan kata sandi yang terdaftar.',
      'Ketuk tombol "Masuk".',
    ],
  ),
  _FaqItem(
    question: 'Bagaimana cara melacak pesanan saya?',
    steps: [
      'Buka tab Tracking pada menu bawah.',
      'Pilih pesanan yang ingin dilacak.',
      'Status pesanan akan ditampilkan secara real-time.',
    ],
  ),
  _FaqItem(
    question: 'Apa itu layanan Ekspres?',
    steps: [
      'Layanan Ekspres menyelesaikan cucian dalam waktu 4 jam.',
      'Cocok untuk kebutuhan mendesak.',
      'Biaya layanan sedikit lebih tinggi dibanding layanan reguler.',
    ],
  ),
  _FaqItem(
    question: 'Bagaimana biaya laundry dihitung?',
    steps: [
      'Biaya dihitung berdasarkan berat cucian (per kg).',
      'Setiap layanan memiliki tarif per kg yang berbeda.',
      'Total biaya = berat (kg) x tarif layanan yang dipilih.',
    ],
  ),
  _FaqItem(
    question: 'Bisakah saya membatalkan pesanan?',
    steps: [
      'Buka detail pesanan pada Riwayat.',
      'Pembatalan hanya bisa dilakukan sebelum status "Diproses".',
      'Ketuk "Batalkan Pesanan" jika opsi tersedia.',
    ],
  ),
  _FaqItem(
    question: 'Bagaimana cara menghubungi admin laundry?',
    steps: [
      'Buka tab Profil.',
      'Ketuk menu "Hubungi Kami".',
      'Hubungi melalui WhatsApp yang tertera.',
    ],
  ),
];

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FaqItem> get _filtered {
    if (_query.trim().isEmpty) return _faqData;
    final q = _query.toLowerCase();
    return _faqData
        .where((item) => item.question.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      backgroundColor: _FT.bg,
      appBar: AppBar(
        backgroundColor: _FT.purple,
        elevation: 0,
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(_FT.rMd)),
        ),
        title: const Text(
          'FAQ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: _FT.purple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: _SearchBar(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? _EmptyState(query: _query)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: _FT.s12),
                    itemBuilder: (context, index) {
                      return _FaqCard(item: results[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_FT.rPill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: _FT.ink),
        decoration: InputDecoration(
          hintText: 'Cari bantuan...',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 22),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  final _FaqItem item;
  const _FaqCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_FT.rMd),
        boxShadow: _FT.shadowSoft,
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Menghilangkan garis divider bawaan ExpansionTile agar lebih clean
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          expandedAlignment: Alignment.topLeft,
          iconColor: _FT.purple,
          collapsedIconColor: Colors.grey.shade400,
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          leading: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _FT.purpleContainer,
              borderRadius: BorderRadius.circular(_FT.rSm),
            ),
            child: const Icon(Icons.help_outline, size: 18, color: _FT.purple),
          ),
          title: Text(
            item.question,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: _FT.ink,
            ),
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(item.steps.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i == item.steps.length - 1 ? 0 : 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: const BoxDecoration(
                          color: _FT.purpleContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: _FT.purple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.steps[i],
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: _FT.purpleContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: _FT.purple,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Tidak ada hasil untuk "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _FT.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Coba kata kunci lain atau hubungi kami langsung.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
