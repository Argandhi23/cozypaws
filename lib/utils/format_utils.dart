import 'package:intl/intl.dart';

class FormatUtils {
  static String rupiah(dynamic price) {
    double value = 0;
    if (price is String) {
      value = double.tryParse(price) ?? 0;
    } else if (price is num) {
      value = price.toDouble();
    }
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }
}