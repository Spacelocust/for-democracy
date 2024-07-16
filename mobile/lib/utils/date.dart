import 'package:intl/intl.dart';

String formatDateForAPI(DateTime date) {
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
}
