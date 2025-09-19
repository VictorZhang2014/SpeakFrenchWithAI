import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_c2copine/src/home/home_grammar_view.dart';
import 'package:flutter_c2copine/src/models/message_model.dart';
import 'package:flutter_c2copine/src/settings/settings_controller.dart';
import 'package:flutter_c2copine/src/statemng/account.dart';
import 'package:flutter_c2copine/src/utils/images.dart';
import 'package:flutter_c2copine/src/localization/app_localizations.dart'; 
import 'package:video_player/video_player.dart'; 


class UserGuideView extends StatefulWidget {
  const UserGuideView({super.key, required this.controller});

  final SettingsController controller;
  static const routeName = '/userguide_view'; 

  @override
  State<StatefulWidget> createState() => _UserGuideViewState();

}

class _UserGuideViewState extends State<UserGuideView> with TickerProviderStateMixin {

  late int animatingStep = 1;
  late VideoPlayerController _videoController;
  final ScrollController _listController = ScrollController(); 
  final List<MessageItemModel> _messages = []; 
 
  late AnimationController _scaleAnimationCtrl;
  late Animation<double> _scaleAnimation; 

  // 0. Cacher tous les boutons
  // 1. Montrer les boutons Oui / Non
  // 2. Cacher les boutons Oui / Non 
  // 3. Montrer les boutons B1 / B2 / C1
  // 4. Cacher les boutons B1 / B2 / C1
  late int bottomBtnsStep = 0; 

  @override
  void initState() {
    super.initState();

    // Animations
    // 1.Apprenez le français
    // 2.Appelez à ParlerAI
    // 3.Parlez avec elle tous les jours

    // Questions
    // 1.Voulez-vous étudier le français avec votre copine Parlerai? Oui / Non
    // 2.Quel niveau de français souhaitez-vous atteindre? B1 / B2 / C1

    setup();
  }

  @override
  void dispose() {
    _scaleAnimationCtrl.dispose(); 
    _videoController.dispose();
    super.dispose();
    debugPrint("UserGuideView dispose");
  }

  void setup() {  
    animate1() ;

    _videoController = VideoPlayerController.asset(
      'assets/video/video_applaunch.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
    ..initialize().then((_) {
    }); 

    _messages.add(MessageItemModel(false, "Bonjour! Je m'appelle Parlerai et je suis votre copine, voulez-vous étudier le français avec moi?"));
  }

  void animate1() {
    _scaleAnimationCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6));
    _scaleAnimation = Tween(begin: 0.01, end: 3.0).animate(CurvedAnimation(parent: _scaleAnimationCtrl, curve: Curves.easeInCirc));
    animate2();
  }

  void animate2() {  
    _scaleAnimationCtrl.forward()
    .whenCompleteOrCancel(() { 
      setState(() {
        animatingStep = 2; 
      });     
      Future.delayed(const Duration(seconds: 5), () {
        _scaleAnimationCtrl.reverse()
        .whenCompleteOrCancel(() {
          setState(() {
            animatingStep = 3; 
          });   
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              animatingStep = 4;  
              _videoController.play(); 
            });   
          });
        }); 
      }); 
    }); 
  }

  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    return animatingStep == 5 ? guideConversationView(s) : Scaffold(
      body: Stack(
        children: [
          animatingStep == 4 
          ? Container(
            width: s.width,
            height: s.height,
            color: Colors.white) 
          : Container(
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
                      decoration: BoxDecoration(
                        color: animatingStep == 3 ? Colors.transparent : Colors.black,
                        // color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ), 
          ),
          animateView(),

          animatingStep == 4 ? bonjourView(s) : Container(), 
        ],
      ),
    );
  }

  Widget animateView() {
    return Center(
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            AppLocalizations.of(context)!.learnFrench, 
            textStyle: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w600),  
            textAlign: TextAlign.center,
            speed: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCirc,
            cursor: '●'
          ),
          TypewriterAnimatedText(
            AppLocalizations.of(context)!.callToParlerAI, 
            textStyle: TextStyle(color: widget.controller.mColor.primary1, fontSize: 45, fontWeight: FontWeight.w600),  
            textAlign: TextAlign.center,
            speed: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCirc,
            cursor: '●'
          ),
        ], 
        totalRepeatCount: 1,  
      ), 
    );
  }

  Widget bonjourView(Size screenSize) {   
    return Stack(
      children: [
        Container( 
          color: Colors.black, 
          child: Column(
            children: [   
              Container( 
                alignment: Alignment.center,
                height: screenSize.height,
                child: _videoController.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: VideoPlayer(_videoController),
                    )
                : Container(),
              ),   
            ],
          )
        ),
        Container(
          color: Colors.black.withAlpha(80),
          width: screenSize.width,
          height: screenSize.height,
        ),
        Container(
          margin: const EdgeInsets.only(top: 200),
          alignment: Alignment.center,
          child: AnimatedTextKit(
            animatedTexts: [ 
              TypewriterAnimatedText(
                AppLocalizations.of(context)!.helloYouWantToLearnFrenchWithOceane,
                textStyle: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w600),  
                textAlign: TextAlign.center,
                speed: const Duration(milliseconds: 75),
                curve: Curves.easeIn,
              ),
            ], 
            totalRepeatCount: 1,  
            onFinished: () {
              Future.delayed(const Duration(seconds: 1), () {
                setState(() {
                  animatingStep = 5; 
                }); 
                Future.delayed(const Duration(seconds: 3), () {
                  setState(() {
                    bottomBtnsStep = 1;
                  });
                });
              });
            },
          ), 
        ),
      ]
    );
  }

  Widget guideConversationView(Size screenSize) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appParlerAI),
        backgroundColor: Colors.transparent,   
      ),
      body: Stack(
        children: [
          Container(
            child: Images.local("bg_textchatview", screenSize.width, fit: BoxFit.cover),  
          ),
          Container( 
            child: ListView.builder(
              controller: _listController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                MessageItemModel item = _messages[index];
                return ListTile(
                  leading: item.isUser ?  
                    const CircleAvatar(
                      radius: 20,   
                      backgroundColor: Colors.black,  
                      child: Text(
                        "M",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ) 
                    )
                    :    
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Images.local("oceane-profile-small", 40),
                    ),   
                  title: Text(
                    item.isUser ? AppLocalizations.of(context)!.me : AppLocalizations.of(context)!.copine, 
                    style: TextStyle(
                      color: item.isUser ? widget.controller.mColor.secondary : widget.controller.mColor.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: !_messages[_messages.length - 1].isUser && _messages.length - 1 == index ? 
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        item.text,
                        curve: Curves.easeInOutCirc,
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                    ], 
                    totalRepeatCount: 1
                  ) : Text(item.text, style: const TextStyle(fontSize: 15)),
                );
              },
            ),
          ),

          bottomBtnsStep == 1 ? createViewForOuiEtNon() : bottomBtnsStep == 3 ? createViewForNiveax(screenSize) : Container(),
        ],
      ),
    );
  }

  Widget createViewForOuiEtNon() {
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding:const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              border: Border.all(color: widget.controller.mColor.secondary),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _messages.add(MessageItemModel(true, "Non"));
                  bottomBtnsStep = 2; 
                });
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    _messages.add(MessageItemModel(false, "Non? Vous êtes si espiègle! 😄 Mais je veux encore parler avec vous tous les jours. Donc quel niveau de français souhaitez-vous atteindre?"));
                  });
                });
                Future.delayed(const Duration(seconds: 7), () {
                  setState(() {
                    bottomBtnsStep = 3; 
                  });
                });
              }, 
              icon: Icon(Icons.sentiment_neutral_rounded, color: widget.controller.mColor.secondary, size: 25,),
              label: Text("Non", style: TextStyle(color: widget.controller.mColor.secondary, fontSize: 30),),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 25),
            padding:const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              border: Border.all(color: widget.controller.mColor.primary1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                setState(() {
                  _messages.add(MessageItemModel(true, "Oui"));
                  bottomBtnsStep = 2; 
                });
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    _messages.add(MessageItemModel(false, "Très bien! 👍🏻 J'aimerais parler avec vous également tous les jours. Donc quel niveau de français souhaitez-vous atteindre?"));
                  });
                });
                Future.delayed(const Duration(seconds: 7), () {
                  setState(() {
                    bottomBtnsStep = 3; 
                  });
                });
              }, 
              icon: Icon(Icons.task_alt_rounded, color: widget.controller.mColor.primary1, size: 25,),
              label: Text("Oui", style: TextStyle(color: widget.controller.mColor.primary1, fontSize: 30),),
            ),
          ),
        ],
      ),
    );
  }

  Widget createViewForNiveax(Size screenSize) {
    double btnWidth = 100;
    double gap = (screenSize.width - 3 * btnWidth) / 4;
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: btnWidth, 
            padding: const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              border: Border.all(color: widget.controller.mColor.secondary),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton.icon(
              onPressed: () { 
                HapticFeedback.lightImpact();
                setState(() {
                  _messages.add(MessageItemModel(true, "B1"));
                  bottomBtnsStep = 4; 
                });
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    _messages.add(MessageItemModel(false, "Génial! C'est parti...")); 
                  });
                  openMainView();
                });
              },  
              label: Text("B1", style: TextStyle(color: widget.controller.mColor.secondary, fontSize: 30),),
            ),
          ),
          Container(
            width: btnWidth,
            margin: EdgeInsets.only(left: gap),
            padding:const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              border: Border.all(color: widget.controller.mColor.primary1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                setState(() {
                  _messages.add(MessageItemModel(true, "B2"));
                  bottomBtnsStep = 4; 
                });
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    _messages.add(MessageItemModel(false, "Quelle excellente idée! Allons-y...")); 
                  });
                  openMainView();
                });
              },  
              label: Text("B2", style: TextStyle(color: widget.controller.mColor.primary1, fontSize: 30),),
            ),
          ),
          Container(
            width: btnWidth,
            margin: EdgeInsets.only(left: gap),
            padding:const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              border: Border.all(color: widget.controller.mColor.secondary),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact();
                setState(() {
                  _messages.add(MessageItemModel(true, "C1"));
                  bottomBtnsStep = 4; 
                });
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    _messages.add(MessageItemModel(false, "Bravo! Vas-y...")); 
                  });
                  openMainView();
                });
              },  
              label: Text("C1", style: TextStyle(color: widget.controller.mColor.secondary, fontSize: 30),),
            ),
          ),
        ],
      ),
    );
  }

  openMainView() {
    Account().updateHiddenUserGuide(true); 
    Future.delayed(const Duration(seconds: 2), () { 
      Navigator.pushReplacementNamed(context, HomeGrammarView.routeName);
    }); 
  }

}

