import 'package:intl/intl.dart'; // Pastikan import ini ada

class FormatUtils {
  // Format mata uang Rupiah
  static String rupiah(dynamic price) {
    double value = 0;
    // Coba konversi dari String atau num (int/double)
    if (price is String) {
      value = double.tryParse(price) ?? 0;
    } else if (price is num) {
      value = price.toDouble();
    }
    // Format ke Rupiah tanpa desimal
    return NumberFormat.currency(
      locale: 'id_ID', // Locale Indonesia
      symbol: 'Rp ', // Simbol Rupiah
      decimalDigits: 0, // 0 angka di belakang koma
    ).format(value);
  }

  /// Format tanggal menjadi "dd-MM-yyyy" (contoh: 30-10-2025)
  static String tanggal(DateTime date) {
    // Gunakan DateFormat dari library intl
    final formatTanggal = DateFormat('dd-MM-yyyy');
    return formatTanggal.format(date);
  }
}