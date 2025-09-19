import 'package:flutter_c2copine/src/models/status_code.dart';


class C2HttpResponse {

  int code = 0;
  String message = "";
  Map<String, dynamic> data = {};

  C2HttpResponse(this.code, this.message, this.data);

  bool get isSuccess => code == C2CodeSuccess;

}

