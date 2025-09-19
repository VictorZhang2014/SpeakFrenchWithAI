

class NullCheck {

  static int forInt(dynamic d) {   
    if (d == null) return 0;
    if (d is int) return d;
    return int.parse(d.toString()); 
  }

  static double forDouble(dynamic d) {   
    if (d == null) return 0;
    if (d is double) return d;
    return double.parse(d.toString()); 
  }

  static String forString(dynamic d) {
    if (d == null) return "";
    if (d is String) return d;
    return d.toString();
  }

  static bool forBool(dynamic d) {
    if (d == null) return false;
    if (d is String) return bool.parse(d);
    return bool.parse(d.toString()); 
  }

}