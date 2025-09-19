import 'dart:ui';


abstract class BaseColor { 
  
  final Color primary; // 蓝色
  final Color primary1; // 蓝色
  final Color secondary; // 黑色
  final Color tertiary; // 白色
  final Color quaternary; // 红色
  final Color quinary; // 绿色 

  final Color divider; // 分割线
  final Color background; // 背景色
  final Color backgroundGrey; // 背景色

  BaseColor({
    required this.primary,
    required this.primary1,
    required this.secondary,
    required this.tertiary,
    required this.quaternary,
    required this.quinary,
    required this.divider,
    required this.background,
    required this.backgroundGrey,
  });

}

class DayColor extends BaseColor {

  DayColor() : super(
    primary: const Color.fromARGB(255, 33, 150, 243),
    primary1: const Color(0xFF3F46F5),
    secondary: const Color(0xFF212121),
    tertiary: const Color(0xFFFFFFFF),
    quaternary: const Color(0xFFFF4081),
    quinary: const Color(0xFF4CAF50),
    divider: const Color(0xFFBDBDBD),
    background: const Color(0xFFF2F2F7), // const Color(0xFFE0E0E0),
    backgroundGrey: const Color.fromARGB(255, 235, 233, 233),
  );

}

class NightColor extends BaseColor {

  NightColor() : super(
    primary: const Color.fromARGB(255, 33, 150, 243),
    primary1: const Color(0xFF3F46F5),
    secondary: const Color(0xFF212121),
    tertiary: const Color(0xFFFFFFFF),
    quaternary: const Color(0xFFFF4081),
    quinary: const Color(0xFF4CAF50), 
    divider: const Color(0xFFBDBDBD),
    background: const Color(0xFFF2F2F7), // const Color(0xFFE0E0E0),
    backgroundGrey: const Color.fromARGB(255, 235, 233, 233),
  );

}


