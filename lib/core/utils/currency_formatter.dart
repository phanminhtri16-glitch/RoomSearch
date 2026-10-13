import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _viFormatter = NumberFormat.decimalPattern('vi_VN');

  /// Formats number with dot thousand separators e.g. 5000000 -> "5.000.000"
  static String format(num? amount) {
    if (amount == null) return '0';
    return _viFormatter.format(amount);
  }
}

extension CurrencyNumX on num {
  String toVndStr() => CurrencyFormatter.format(this);
}
