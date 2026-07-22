class Order {
  final String id;
  final String orderCode;
  final String? customerUsername;
  String nama;
  double berat;
  String layanan;
  double subtotal;
  double discount;
  double total;
  String status;
  String statusBayar;
  String tanggal;

  Order({
    required this.id,
    String? orderCode,
    this.customerUsername,
    required this.nama,
    required this.berat,
    required this.layanan,
    required this.total,
    double? subtotal,
    this.discount = 0,
    this.status = 'Menunggu',
    this.statusBayar = 'Belum dibayar',
    String? tanggal,
  }) : orderCode = orderCode ?? 'LDR-${_shortId(id)}',
       subtotal = subtotal ?? total,
       tanggal = tanggal ?? _today();

  factory Order.fromSupabase(Map<String, dynamic> data) {
    final items = (data['order_items'] as List<dynamic>? ?? []);
    final firstItem = items.isEmpty
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(items.first as Map);
    final orderedAt = DateTime.tryParse('${data['ordered_at'] ?? ''}');

    return Order(
      id: '${data['id']}',
      orderCode: '${data['order_code'] ?? 'LDR-${_shortId('${data['id']}')}'}',
      customerUsername: data['customer_username']?.toString(),
      nama: '${data['customer_name'] ?? '-'}',
      berat: _asDouble(firstItem['weight_kg']),
      layanan: '${firstItem['service_name'] ?? '-'}',
      subtotal: _asDouble(data['subtotal']),
      discount: _asDouble(data['discount']),
      total: _asDouble(data['total']),
      status: '${data['status'] ?? 'Menunggu'}',
      statusBayar: '${data['payment_status'] ?? 'Belum dibayar'}',
      tanggal: orderedAt == null ? _today() : _formatTanggal(orderedAt),
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  double get pricePerKg => berat == 0 ? 0 : subtotal / berat;

  bool get hasDiscount => discount > 0;

  static String _today() {
    final now = DateTime.now();
    return _formatTanggal(now);
  }

  static String _formatTanggal(DateTime date) {
    return '${date.day} ${_bulan(date.month)}';
  }

  static String _shortId(String id) {
    if (id.length <= 6) return id;
    return id.substring(id.length - 6).toUpperCase();
  }

  Map<String, dynamic> toOrderInsert({String? username}) {
    return {
      'customer_name': nama,
      'customer_username': username,
      'status': status,
      'payment_status': statusBayar,
      'discount': discount,
    };
  }

  Map<String, dynamic> toItemInsert(String orderId) {
    return {
      'order_id': orderId,
      'service_name': layanan,
      'weight_kg': berat,
      'price_per_kg': pricePerKg,
    };
  }

  static String _bulan(int m) {
    const b = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return b[m];
  }
}
