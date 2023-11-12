import 'package:intl/intl.dart';

class AppConstants {
  static dynamic DateFormatter(String date) {
    return DateFormat("dd MMM yyyy '${"at"}' hh:mm a")
        .format(DateTime.tryParse(date)!.toLocal());
  }
}
