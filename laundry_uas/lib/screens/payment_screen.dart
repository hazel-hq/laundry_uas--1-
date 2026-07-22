import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/order.dart';
import '../models/order_data.dart';

class PaymentScreen extends StatefulWidget {
  final Order order;
  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const _purple = Color(0xFF6C63FF);
  String _metode = 'QRIS';
  bool _sudahBayar = false;
  bool _saving = false;

  Future<void> _konfirmasiBayar() async {
    setState(() => _saving = true);

    try {
      await orderRepository.confirmPayment(
        order: widget.order,
        method: _metode,
      );
      await refreshOrders();

      final i = orderList.indexWhere((o) => o.id == widget.order.id);
      if (i != -1) orderList[i].statusBayar = 'Lunas';
      widget.order.statusBayar = 'Lunas';

      if (!mounted) return;
      setState(() {
        _sudahBayar = true;
        _saving = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF2E7D32),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pembayaran dikonfirmasi!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a2e),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Terima kasih! Pesanan kamu sedang diproses.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kembali ke pesanan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal konfirmasi pembayaran: $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Pembayaran',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: Colors.grey.shade200, height: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan tagihan
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan tagihan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _BillRow(label: 'Nama', value: widget.order.nama),
                  _BillRow(label: 'Layanan', value: widget.order.layanan),
                  _BillRow(label: 'Berat', value: '${widget.order.berat} kg'),
                  _BillRow(
                    label: 'Harga satuan',
                    value:
                        'Rp ${widget.order.pricePerKg.toStringAsFixed(0)}/kg',
                  ),
                  _BillRow(
                    label: 'Subtotal',
                    value: 'Rp ${widget.order.subtotal.toStringAsFixed(0)}',
                  ),
                  if (widget.order.hasDiscount)
                    _BillRow(
                      label: 'Diskon bulanan',
                      value: '-Rp ${widget.order.discount.toStringAsFixed(0)}',
                      valueColor: const Color(0xFF2E7D32),
                    ),
                  const Divider(height: 20, thickness: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total tagihan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1a1a2e),
                        ),
                      ),
                      Text(
                        'Rp ${widget.order.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pilih metode
            const Text(
              'Metode pembayaran',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),

            _MetodeCard(
              selected: _metode == 'QRIS',
              onTap: () => setState(() => _metode = 'QRIS'),
              icon: Icons.qr_code_2,
              label: 'QRIS',
              desc: 'Scan QR code — semua e-wallet & mobile banking',
            ),
            const SizedBox(height: 8),
            _MetodeCard(
              selected: _metode == 'COD',
              onTap: () => setState(() => _metode = 'COD'),
              icon: Icons.payments_outlined,
              label: 'COD / Tunai',
              desc: 'Bayar tunai saat pengambilan / antar laundry',
            ),

            const SizedBox(height: 16),

            // Konten metode
            if (_metode == 'QRIS') _QrisSection(total: widget.order.total),
            if (_metode == 'COD') const _CodSection(),

            const SizedBox(height: 20),

            // Tombol konfirmasi / sudah bayar
            if (!_sudahBayar)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _konfirmasiBayar,
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: Text(
                    _saving
                        ? 'Menyimpan...'
                        : _metode == 'QRIS'
                        ? 'Saya sudah transfer'
                        : 'Konfirmasi COD',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF2E7D32),
                    width: 0.5,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Pembayaran sudah dikonfirmasi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── QRIS Section ─────────────────────────────────────────
class _QrisSection extends StatelessWidget {
  final double total;
  const _QrisSection({required this.total});

  static const _noRek = '1234-5678-9012';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Column(
        children: [
          const Text(
            'Scan QR berikut',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 14),

          // QR placeholder
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2, size: 100, color: Colors.grey.shade300),
                const SizedBox(height: 4),
                Text(
                  'QR laundry kamu',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Nominal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nominal transfer',
                  style: TextStyle(fontSize: 12, color: Color(0xFF534AB7)),
                ),
                Text(
                  'Rp ${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3C3489),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // No rekening + salin
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No. rekening / QRIS ID',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      _noRek,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a2e),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: _noRek));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Nomor disalin!'),
                        backgroundColor: const Color(0xFF6C63FF),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEDFE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.copy, size: 13, color: Color(0xFF6C63FF)),
                        SizedBox(width: 4),
                        Text(
                          'Salin',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.access_time, size: 13, color: Colors.grey.shade400),
              const SizedBox(width: 5),
              Text(
                'Transfer sesuai nominal persis',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── COD Section ───────────────────────────────────────────
class _CodSection extends StatelessWidget {
  const _CodSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.payments_outlined,
              size: 34,
              color: Color(0xFFE65100),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Bayar di tempat (COD)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1a1a2e),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Siapkan uang tunai sesuai tagihan saat kurir '
            'mengantarkan atau saat kamu mengambil laundry.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ...[
            ('1', 'Tunggu notifikasi pesanan selesai'),
            ('2', 'Siapkan uang pas sesuai tagihan'),
            ('3', 'Bayar ke kurir / kasir saat pengambilan'),
          ].map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF3E0),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        e.$1,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    e.$2,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Komponen ──────────────────────────────────────────────
class _MetodeCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final String label, desc;
  const _MetodeCard({
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEEDFE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF6C63FF) : Colors.grey.shade200,
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFF6C63FF) : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? const Color(0xFF6C63FF)
                          : const Color(0xFF1a1a2e),
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? const Color(0xFF6C63FF) : Colors.grey.shade300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;

  const _BillRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor ?? const Color(0xFF1a1a2e),
            ),
          ),
        ],
      ),
    );
  }
}
