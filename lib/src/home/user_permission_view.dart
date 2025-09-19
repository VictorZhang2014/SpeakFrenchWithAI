import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_c2copine/src/home/user_guide_view.dart';
import 'package:flutter_c2copine/src/settings/settings_controller.dart';
import 'package:flutter_c2copine/src/statemng/account.dart';
import 'package:flutter_c2copine/src/utils/Images.dart';
import 'package:permission_handler/permission_handler.dart';



class UserPermissionView extends StatefulWidget {
  const UserPermissionView({super.key, required this.controller});

  final SettingsController controller;
  static const routeName = '/userpermission_view'; 

  @override
  State<StatefulWidget> createState() => _UserPermissionViewState();

}

class _UserPermissionViewState extends State<UserPermissionView> with TickerProviderStateMixin {

  late AnimationController _scaleAnimationCtrl;
  late Animation<double> _scaleAnimation; 
  // late Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    _scaleAnimationCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _scaleAnimation = Tween(begin: 2.0, end: 0.2).animate(CurvedAnimation(parent: _scaleAnimationCtrl, curve: Curves.easeInCirc));
    _scaleAnimationCtrl.repeat(reverse: true);

    setup();
  }

  @override
  void dispose() { 
    _scaleAnimationCtrl.dispose();
    // _timer?.cancel(); 
    super.dispose();
  }

  setup() async {
    bool isGrantedNotification = await Permission.notification.status.isGranted;
    if (!isGrantedNotification) {
      await Permission.notification.request();
    }
    bool isGrantedMicrophone = await Permission.microphone.status.isGranted;
    if (!isGrantedMicrophone) {
      await Permission.microphone.request();
    }

    // _timer = Timer.periodic(const Duration(seconds: 1), (t) async { 
    //   if (mounted) {
    //     if (await queryPermission()) { 
    //       _timer?.cancel(); 
          await Account().updateHiddenUserPermission(true);
          Future.delayed(const Duration(seconds: 4), () {
            Navigator.pushReplacementNamed(context, UserGuideView.routeName);
          });
    //     }
    //   }
    // });
  }

  // Future<bool> queryPermission() async {
  //   // Check if the user has chosen the behavior of these permissions.
  //   print("Permission.notification.status = ${await Permission.notification.status}");
  //   print("Permission.microphone.status = ${await Permission.microphone.status}");
  //   if (
  //       (await Permission.notification.status == PermissionStatus.permanentlyDenied ||
  //       await Permission.notification.status == PermissionStatus.granted) &&
  //       (await Permission.microphone.status == PermissionStatus.permanentlyDenied ||
  //       await Permission.microphone.status == PermissionStatus.granted)
  //       ) {
  //     return true;
  //   }
  //   return false;
  // }

  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    return Scaffold( 
      body: Stack(
        children: [
          Container(
            width: s.width,
            height: s.height,
            color: Colors.white,
            child: AnimatedBuilder(
              animation: _scaleAnimationCtrl,
              builder: (context, child) {
                return Container(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: s.width * 0.3,
                      height: s.height * 0.3,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ), 
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Images.local("logo", 100),
            ),
          ),
        ] 
      ),
    );
  }

}

