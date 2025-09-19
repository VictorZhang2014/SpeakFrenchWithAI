import 'dart:async';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_c2copine/src/home/call_ai_view.dart';
import 'package:flutter_c2copine/src/home/home_audio_view.dart';
import 'package:flutter_c2copine/src/iap/iap_purchaseview.dart';
import 'package:flutter_c2copine/src/localization/app_localizations.dart'; 
import 'package:flutter_c2copine/src/models/message_model.dart';
import 'package:flutter_c2copine/src/network/requester.dart'; 
import 'package:flutter_c2copine/src/settings/settings_controller.dart';
import 'package:flutter_c2copine/src/settings/settings_view.dart';
import 'package:flutter_c2copine/src/statemng/account.dart';
import 'package:flutter_c2copine/src/utils/time_utils.dart';
import 'package:flutter_c2copine/src/utils/images.dart';
import 'package:flutter_c2copine/src/utils/view_dialog.dart'; 
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart'; 


class HomeGrammarView extends StatefulWidget {
  const HomeGrammarView({super.key, required this.controller});

  final SettingsController controller;
  static const routeName = '/home_grammar_view'; 

  @override
  State<StatefulWidget> createState() => _HomeGrammarViewState();
}

class _HomeGrammarViewState extends State<HomeGrammarView> { 

  late int maximumSeconds = 20;  
  late int maxLengthOfText = 512;
  late String msgId = "";

  final ScrollController _listController = ScrollController(); 

  final List<MessageItemModel> _messages = []; 

  late bool firstMsgShowsTranslation = false; // 首条消息是否显示是翻译 
  late bool firstMsgInFrench = true; // 首条消息是否是法语
  late String firstGreetingMessage = "";
  late bool isHiddenTranslatorBtn = true;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    msgId = TimeUtils.getTimestamp().toString();
    setup();
  }

  @override
  void dispose() {  
    super.dispose();
  }

  Future<void> setup() async {  
    EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid
    ..maskType = EasyLoadingMaskType.clear 
    ..maskColor = Colors.grey.withOpacity(0.3);  

    WidgetsBinding.instance.addPostFrameCallback((_) {
      animateFirstMessage(); 

      if (Platform.isIOS) {
        _focusNode.addListener(() { 
          // if (_focusNode.hasFocus) {
          //   if (Account().isNotPlusMember()) {
          //     _focusNode.unfocus();
          //     Navigator.of(context).pushNamed(IAPPurchaseView.routeName); 
          //     return;
          //   }
          // }
        });
      }
    });
  }

  void animateFirstMessage() {
    firstGreetingMessage = "Bonjour! Je suis Parlerai, votre copine de niveau C2 en français. Comment puis-je vous aider avec vos questions de grammaire et de structure de phrases aujourd'hui? Tu peux aussi me poser des questions sur la culture française, la cuisine, les traditions et la langue, ou tout autre sujet dont tu as envie de discuter.";
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        _messages.add(MessageItemModel(false, firstGreetingMessage));
      });
      // _focusNode.requestFocus(); 
    }); 
  } 

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appParlerAI),
        backgroundColor: Colors.transparent,   
        systemOverlayStyle: SystemUiOverlayStyle( 
          statusBarColor: Platform.isAndroid ? Colors.transparent : Colors.black,   
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(SettingsView.routeName);
          },
          icon: const Icon(Icons.sort),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // if (Platform.isIOS) {
              //   if (Account().isNotPlusMember()) {
              //     Navigator.of(context).pushNamed(IAPPurchaseView.routeName); 
              //     return;
              //   }
              // }
              final status = await Permission.microphone.request();
              if (!status.isGranted) {   
                ViewDialog.showPermissionDialog(context);
                return;
              }
              Navigator.of(context).pushNamed(CallAIView.routeName);
            },
            icon: const Icon(Icons.duo_rounded, color: Colors.red, size: 28),
          ),
          GestureDetector(
            onTap: () {
              // if (Platform.isIOS) {
              //   if (Account().isNotPlusMember()) {
              //     Navigator.of(context).pushNamed(IAPPurchaseView.routeName); 
              //     return;
              //   }
              // }
              Navigator.of(context).pushNamed(HomeAudioView.routeName);
            },
            child: Container(  
              margin: const EdgeInsets.only(right: 10),
              child: Images.local("icon_grammar", 30), 
            ),
          ),
          const SizedBox(width: 8)
        ],
      ),
      backgroundColor: Colors.white,  
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Container(
              child: Images.local("bg_textchatview", screenSize.width, fit: BoxFit.cover),  
            ),
            Column( 
              children: [ 
                _messages.isEmpty ? Container( 
                  margin: EdgeInsets.only(top: (screenSize.height - 100 - 50) / 2),
                  child: Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Images.local("logo-gray", 100),  
                      const SizedBox(height: 15),
                      Text(
                        AppLocalizations.of(context)!.hiHowAreYouGoingToday,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ) : Container(),
                Expanded(
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
                          // Icon(Icons.person, color: Colors.grey[400]),
                        title: Text(
                          item.isUser ? AppLocalizations.of(context)!.me : AppLocalizations.of(context)!.copine, 
                          style: TextStyle(
                            color: item.isUser ? widget.controller.mColor.secondary : widget.controller.mColor.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ), 
                        subtitle: createSubtitleMessage(index, item, index != 0),
                      );
                    },
                  ),
                ),  
                Container(
                  padding: const EdgeInsets.all(16.0), 
                  decoration: BoxDecoration( 
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset: const Offset(0, 3), // Offset in x and y directions
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        focusNode: _focusNode,
                        controller: _controller,
                        minLines: 1,
                        maxLines: 3, 
                        decoration: InputDecoration(
                          enabledBorder: InputBorder.none, 
                          focusedBorder: InputBorder.none, 
                          hintText: '${AppLocalizations.of(context)!.pleaseTellMeAboutYourQuestions}......', 
                          // counterText: '', // Optional: hides the counter below the TextField
                        ),
                        onChanged: (text) {
                          if (text.length > maxLengthOfText) { 
                            _controller.text = text.substring(0, maxLengthOfText);
                            _controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: _controller.text.length),
                            );  
                          }
                        },
                      ),
                      const SizedBox(height: 8.0), 
                      Row( 
                        children: [
                          const Spacer(),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: widget.controller.mColor.secondary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: GestureDetector(
                              child: Transform.translate(
                                offset: const Offset(2, 0), // Due to the icon is being off-center to itself, so I adjusted the x-axis to the right.
                                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                              ),
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                // if (Platform.isIOS) {
                                //   if (Account().isNotPlusMember()) {
                                //     Navigator.of(context).pushNamed(IAPPurchaseView.routeName); 
                                //     return;
                                //   }
                                // }
                                if (_controller.text.isEmpty) return;
                                askGrammarOrStructure(_controller.text, _messages);
                                setState(() {
                                  _messages.add(MessageItemModel(true, _controller.text)); 
                                }); 
                                _controller.text = ""; 
                                _listController.animateTo(
                                  _listController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );  
                                _focusNode.unfocus();
                              },
                            ), 
                          ),
                        ]
                      ),
                    ],
                  ) 
                ),
              ],
            ),
          ]
        ),
      ),
    );
  }

  Widget createSubtitleMessage(int index, MessageItemModel item, bool isHiddenBtns) {
    double fSize = 15;
    if (index > 1) {
      if (item.isUser) {
        return Text(item.text, style: TextStyle(color: Colors.black, fontSize: fSize));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          item.isUser || item.isAnimated ? Text(item.text, style: TextStyle(color: Colors.black, fontSize: fSize)) : 
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                item.text,
                curve: Curves.easeInOutCirc,
                textStyle: TextStyle(color: Colors.black, fontSize: fSize),
              ),
            ], 
            totalRepeatCount: 1,
            onFinished: () => item.isAnimated = true,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...createMsgFeedbackButtons(index, item),
            ],
          ),
        ],
      );   
    }

    if (index == 0 && firstMsgShowsTranslation) { 
      if (firstMsgInFrench) {
        item.text = firstGreetingMessage;
      } else {
        item.text = AppLocalizations.of(context)!.textChatInstructionGuide1;
      } 
    }
    bool isSysMsg = !_messages[_messages.length - 1].isUser && _messages.length - 1 == index;
    List<Widget> widgets = [];
    if (isSysMsg) {
      if (index == 0 && firstMsgShowsTranslation) {
        widgets.add(Text(item.text, style: TextStyle(color: Colors.black, fontSize: fSize))); 
      } else {
        widgets.add(AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                item.text,
                curve: Curves.easeInOutCirc,
                textStyle: TextStyle(color: Colors.black, fontSize: fSize),
              ),
            ], 
            totalRepeatCount: 1,
            onFinished:() {
              if (index == 0) {
                setState(() {
                  isHiddenTranslatorBtn = false; 
                });
              }
            },
          ),
        );
      }
    } else {
      widgets.add(Text(item.text, style: TextStyle(color: Colors.black, fontSize: fSize)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widgets,
        isHiddenBtns ? Container() :
        const SizedBox(height: 8),
        isHiddenTranslatorBtn ? Container() : index == 0 ? Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  firstMsgShowsTranslation = true;
                  firstMsgInFrench = !firstMsgInFrench;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(top: 0, right: 0), 
                padding: const EdgeInsets.only(bottom: 10, right: 20),
                child: const Icon(Icons.translate_rounded, size: 16, color: Colors.grey),
              ),
            ), 
            ...createMsgFeedbackButtons(index, item),
          ],
        ) : Container(),
        // Row(
        //   children: [
        //     isHiddenTranslatorBtn ? Container() : index == 0 ? GestureDetector(
        //       onTap: () {
        //         setState(() {
        //           firstMsgShowsTranslation = true;
        //           firstMsgInFrench = !firstMsgInFrench;
        //         });
        //       },
        //       child: Container(
        //         margin: const EdgeInsets.only(top: 0, right: 0), 
        //         padding: const EdgeInsets.only(bottom: 10, right: 30),
        //         child: const Icon(Icons.translate_rounded, size: 16, color: Colors.grey),
        //       ),
        //     ) : Container(), 
        //   ],
        // ),
      ],
    );  
  }

  List<Widget> createMsgFeedbackButtons(int index, MessageItemModel item) {
    String previousMsg = _messages.length == 1 || index == 0 ? "" : _messages[index-1].text;
    String currentMsg = _messages[index].text;
    return [
      GestureDetector(
        onTap: () { 
          Clipboard.setData(ClipboardData(text: item.text)); 
          fShowToast(AppLocalizations.of(context)!.copied);
          setState(() {
            item.isMarkedCopy = true;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(top: 0, right: 0), 
          padding: const EdgeInsets.only(bottom: 10, right: 20),
          child: Icon(item.isMarkedCopy ? Icons.copy_rounded : Icons.copy_all_sharp, size: 17, color: Colors.grey),
        ),
      ),
      GestureDetector(
        onTap: () {  
          fShowToast(AppLocalizations.of(context)!.thankYouForYourSupporting);
          feedbackRequest("like", previousMsg, currentMsg);
          setState(() {
            item.isMarkedThumbup = true;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(top: 0, right: 0), 
          padding: const EdgeInsets.only(bottom: 10, right: 20),
          child: Icon(item.isMarkedThumbup ? Icons.thumb_up_rounded : Icons.thumb_up_outlined, size: 17, color: Colors.grey),
        ),
      ),
      GestureDetector(
        onTap: () {  
          ViewDialog.dialogDislikeOrReport(
            context, 
            () { 
              fShowToast(AppLocalizations.of(context)!.weWillContinueWorkingToImproveTheContent);
              feedbackRequest("dislike", previousMsg, currentMsg);
            }, 
            () {
              fShowToast(AppLocalizations.of(context)!.weApologizeForTheInappropriateContent); 
              if (index != 0) { _messages.removeAt(index); }
              feedbackRequest("report", previousMsg, currentMsg);
            }, 
            null);
        },
        child: Container(
          margin: const EdgeInsets.only(top: 0, right: 0), 
          padding: const EdgeInsets.only(bottom: 10, right: 20),
          child: const Icon(Icons.thumb_down_outlined, size: 17, color: Colors.grey),
        ),
      ), 
    ];
  }

  askGrammarOrStructure(String userText, List<MessageItemModel> msgs) async {  
    final result = await Requester().askGrammarOrStructure(msgId, userText, MessageItemModelTool.getMessages(msgs));
    if (result.isSuccess && result.data.isNotEmpty) {
      setState(() {
        _messages.add(MessageItemModel(false, result.data["copine_text"]));  
        _listController.animateTo(
          _listController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );  
      });
    } else {
      EasyLoading.showToast(result.message.isEmpty ? "Try again later or contact the administrator." : result.message);
    }
  }  

  void fShowToast(String msg) {
    Fluttertoast.showToast(msg: msg, gravity: ToastGravity.TOP);
  }

  void feedbackRequest(String type, String userText, String aiContent) async {
    await Requester().feedbackForAIContent(msgId, type, "text", userText, aiContent);
  }

}

