import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/order_data.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _nama = TextEditingController();
  final _berat = TextEditingController();
  String _layanan = 'Cuci';
  static const _purple = Color(0xFF6C63FF);

  final _layananList = [
    {
      'nama': 'Cuci',
      'harga': 5000,
      'icon': Icons.water_drop_outlined,
      'desc': 'Cuci bersih standar',
    },
    {
      'nama': 'Setrika',
      'harga': 4000,
      'icon': Icons.iron_outlined,
      'desc': 'Setrika rapi',
    },
    {
      'nama': 'Express',
      'harga': 8000,
      'icon': Icons.bolt_outlined,
      'desc': 'Selesai dalam 6 jam',
    },
  ];

  double get _hargaSatuan {
    final item = _layananList.firstWhere((l) => l['nama'] == _layanan);
    return (item['harga'] as int).toDouble();
  }

  double get _total {
    final berat = double.tryParse(_berat.text) ?? 0;
    return berat * _hargaSatuan;
  }

  bool _saving = false;

  Future<void> _simpan() async {
    if (_nama.text.isEmpty || _berat.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan berat wajib diisi')),
      );
      return;
    }
    final berat = double.tryParse(_berat.text) ?? 0;
    if (berat <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Berat harus lebih dari 0')));
      return;
    }

    setState(() => _saving = true);

    try {
      await orderRepository.createOrder(
        Order(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nama: _nama.text,
          berat: berat,
          layanan: _layanan,
          total: _total,
        ),
      );
      await refreshOrders();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil dibuat!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan pesanan: $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final berat = double.tryParse(_berat.text) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Buat pesanan',
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
            // Form card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data pelanggan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildField(_nama, 'Nama lengkap', Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildField(
                    _berat,
                    'Berat (kg)',
                    Icons.scale_outlined,
                    isNumber: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Pilih layanan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih layanan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._layananList.map((l) {
                    final selected = _layanan == l['nama'];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _layanan = l['nama'] as String),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFEEEDFE)
                              : const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? _purple : Colors.grey.shade200,
                            width: selected ? 1 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              l['icon'] as IconData,
                              color: selected ? _purple : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l['nama'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: selected
                                          ? _purple
                                          : const Color(0xFF1a1a2e),
                                    ),
                                  ),
                                  Text(
                                    l['desc'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Rp ${l['harga']}/kg',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: selected ? _purple : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Preview harga
            if (berat > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDFE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6C63FF),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$berat kg × Rp ${_hargaSatuan.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF534AB7),
                      ),
                    ),
                    Text(
                      'Rp ${_total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3C3489),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _saving ? 'Menyimpan...' : 'Buat pesanan',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
