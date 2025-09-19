import 'package:intl/intl.dart';


class TimeUtils {

    static String yMMMMd(int ts, String languageCode) {
      DateTime sdate = DateTime.fromMillisecondsSinceEpoch(ts);
      return DateFormat.yMMMMd(languageCode).format(sdate); 
    }

    static int getTimestamp() {
      return DateTime.now().millisecondsSinceEpoch;
    }

}