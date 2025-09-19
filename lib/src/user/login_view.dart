import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_c2copine/src/settings/settings_controller.dart';
import 'package:flutter_c2copine/src/utils/images.dart';
import 'package:flutter_c2copine/src/utils/view_dialog.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart'; 
import 'package:flutter_c2copine/src/localization/app_localizations.dart'; 
import 'package:video_player/video_player.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.controller});

  static const routeName = '/login_view';

  final SettingsController controller;

  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late VideoPlayerController _videoController;

  @override
  void initState() { 
    super.initState(); 
     _videoController = VideoPlayerController.asset('assets/video/video_login_bg.mp4')
      ..initialize().then((_) {
        setState(() {
          _videoController.setLooping(true);
          _videoController.play();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    double margin = 20;
    double btnWidth = s.width - margin * 2;
    double btnHeight = 50;  
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 120),
            child: _videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              : Container(),
          ), 
          Container(
            color: Colors.black.withAlpha(130),
            width: s.width,
            height: s.height,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: s.width,
              height: 310,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40), 
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: [ 
                  Container(
                    width: btnWidth,
                    height: btnHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: [
                        Container(  
                          child: Images.local("icon_apple", 26),  
                        ),
                        const SizedBox(width: 12,),
                        const Text(
                          "Continue with Apple", 
                          style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ), 
                  ),
                  
                  Container(
                    width: btnWidth,
                    height: btnHeight, 
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: [
                        Container(  
                          child: Images.local("icon_google", 26),  
                        ),
                        const SizedBox(width: 12,),
                        const Text(
                          "Continue with Google", 
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ), 
                  ), 

                  Container(
                    width: btnWidth,
                    height: btnHeight, 
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: [
                        Container(  
                          child: Images.local("icon_facebook", 26),  
                        ),
                        const SizedBox(width: 12,),
                        const Text(
                          "Continue with Facebook", 
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ), 
                  ),
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }

}
