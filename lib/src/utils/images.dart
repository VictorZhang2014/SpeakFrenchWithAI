import 'package:flutter/widgets.dart'; 

class Images {
  static String providerDir = "assets/images/";

  static Widget local(String name, double width, {double? height, BoxFit fit = BoxFit.contain}) {
    return Image.asset("${providerDir + name}.png",
        width: width, height: height, fit: fit);
  }

}
