import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_c2copine/src/home/call_ai_view.dart';
import 'package:flutter_c2copine/src/home/home_grammar_view.dart';
import 'package:flutter_c2copine/src/models/audio_list_model.dart';
import 'package:flutter_c2copine/src/network/requester.dart';
import 'package:flutter_c2copine/src/settings/settings_controller.dart';
import 'package:flutter_c2copine/src/settings/settings_view.dart';
import 'package:flutter_c2copine/src/utils/images.dart'; 
import 'package:flutter_c2copine/src/utils/view_dialog.dart';
import 'package:flutter_c2copine/src/utils/time_utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_session/audio_session.dart';
import 'package:fluttertoast/fluttertoast.dart'; 
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_c2copine/src/localization/app_localizations.dart'; 
import 'package:logger/logger.dart';


class HomeAudioView extends StatefulWidget {
  const HomeAudioView({super.key, required this.controller});

  final SettingsController controller;
  static const routeName = '/home_audio_view'; 
  
  @override
  _HomeAudioViewState createState() => _HomeAudioViewState();
}

class _HomeAudioViewState extends State<HomeAudioView> {

  late String msgId = "";

  late int maximumSeconds = 20; 
  bool _isRecording = false;
  bool _isHiddenEllePenseHints = true; 
  late Timer? _timer;
  late final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder(logLevel: Level.off);
  late final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer(logLevel: Level.off);
  bool _isPermissionGranted = false;

  final ScrollController _listController = ScrollController();
  final List<AudioItemModel> _audioFiles = []; 
  String _appPath = "";
  String _currentRecordingPath = '';  

  double _playbackSpeed = 1.0;
  late bool _hideAIResponseText = false;

  late List<Map<String, String>> suggestionTopics = [];
  late List<Map<String, String>> suggestedTopics = [];

  @override
  void initState() {
    super.initState();
    msgId = TimeUtils.getTimestamp().toString();

    suggestionTopics = [
      {"title": "Se présenter", "desc": "Parler de soi, de son parcours, de ses loisirs et de ses aspirations."},
      {"title": "Voyages et cultures", "desc": "Décrire un voyage passé ou rêvé, parler des différences culturelles."},
      {"title": "Études et carrières", "desc": "Expliquer ton parcours académique et tes objectifs professionnels."},
      {"title": "La vie en France", "desc": "Décrire ton expérience en France ou imaginer une vie dans un pays francophone."},
      {"title": "Technologie et intelligence artificielle", "desc": "Discuter de l'impact de l'IA et des nouvelles technologies."},
      {"title": "Environnement et écologie", "desc": "Parler du réchauffement climatique et des solutions écologiques."},
      {"title": "Loisirs et passions", "desc": "Décrire tes passe-temps préférés et pourquoi ils sont importants."},
      {"title": "Actualités et société", "desc": "Exprimer ton opinion sur un sujet d’actualité."},
      {"title": "Santé et bien-être", "desc": "Discuter de l'importance d’un mode de vie sain."},
      {"title": "Sujets philosophiques et débats", "desc": "Argumenter sur des questions éthiques et philosophiques."},
    ];
    suggestedTopics = getRandomTopics(suggestionTopics, 3);

    EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid
    ..maskType = EasyLoadingMaskType.clear 
    ..maskColor = Colors.grey.withOpacity(0.3); 

    _initializeRecorder();
  }
 
  void _initializeRecorder() async { 
    Directory appDirectory = await getApplicationDocumentsDirectory(); 
    _appPath = appDirectory.path;
  }

  Future<bool> _isGrantedMicroPermission() async {
    if (_isPermissionGranted) return true;
    final status = await Permission.microphone.request();
    if (status.isGranted) { 
      _isPermissionGranted = true;  
      return true;
    } else { 
      ViewDialog.showPermissionDialog(context);
      return false;
    }
  }

  Future<void> openTheRecorder() async { 
    await _audioRecorder.openRecorder();
    if (!await _audioRecorder.isEncoderSupported(Codec.pcm16WAV)) {
      debugPrint("Codec is not supported pcm16WAV");
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  void _toggleRecording() async { 
    if (!await _isGrantedMicroPermission()) {
      return;
    }   
    if (!_isRecording) {   
      startRecording();
    } else {  
      stopRecording();
    }
  }

  void startRecording() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (t.tick >= maximumSeconds) {
        stopRecording();
      }
    });
    try { 
        final audioDir = Directory('$_appPath/audio');
        await audioDir.create();
        _currentRecordingPath = '$_appPath/audio/user_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
        setState(() {
          _isRecording = true; 
        }); 
        await openTheRecorder(); 
        await _audioRecorder.startRecorder(
          toFile: _currentRecordingPath, 
          codec: Codec.pcm16WAV,
        ); 
    } catch (e) {
      debugPrint("Error starting recording: $e");
    }
  }

  void stopRecording() async {
    // String waitingTips = '${AppLocalizations.of(context)!.pleaseWaitParlerAIIsRespondingU}...'; 
    _timer?.cancel();
    _timer = null;
    _audioFiles.add(AudioItemModel(true, _currentRecordingPath, ""));  
    setState(() {
      _isRecording = false;
      _isHiddenEllePenseHints = false; 
    }); 
    await _audioRecorder.stopRecorder();
    await _audioRecorder.closeRecorder();
    // await EasyLoading.show(status: waitingTips);
    final result = await Requester().sendAudio(msgId, _currentRecordingPath, AudioItemModelTool.getMessages(_audioFiles));
    // await EasyLoading.dismiss();
    if (!result.isSuccess) {
      setState(() {
        _isHiddenEllePenseHints = true; 
      }); 
      await EasyLoading.showError(result.message);
    } else {
      String audioName = result.data["audio_name"] as String? ?? "";
      if (audioName.isNotEmpty) { 
        String genAudioName = '$_appPath/audio$audioName';
        final result2 = await Requester().downloadAudio(audioName, genAudioName);
        setState(() {
          _isHiddenEllePenseHints = true; 
        }); 
        if (result2.isSuccess) {
          String userText = result.data["user_text"] as String;
          String copineText = result.data["copine_text"] as String;
          _audioFiles[_audioFiles.length - 1].text = userText;
          _audioFiles.add(AudioItemModel(false, genAudioName, copineText));   
          adjustPlaybackSpeed(userText); 
          _togglePlaying(genAudioName);
          _listController.animateTo(
            _listController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        } else {
          await EasyLoading.showError(result2.message);
        }
      } else {
        setState(() {
          _isHiddenEllePenseHints = true; 
        }); 
        await EasyLoading.showError(result.message.isNotEmpty ? result.message : "Server error");
      }
    }
  }

  void _togglePlaying(String path) async {
    updatePlayBtn(bool f) {
      for (var item in _audioFiles) {
        if (item.audioFilepath == path) {
          setState(() {
            item.isPlaying = f;
          });
          break;
        }
      }
    }
    try { 
      if (_audioPlayer.isPlaying) {
        await _audioPlayer.stopPlayer(); 
        updatePlayBtn(false);
      } else {
        await _audioPlayer.openPlayer();
        _audioPlayer.setVolume(1.0);
        _audioPlayer.setSpeed(_playbackSpeed);
        await _audioPlayer.startPlayer(
          fromURI: path,
          codec: Codec.pcm16WAV,
          whenFinished: () {
            updatePlayBtn(false);
          },
        );
        updatePlayBtn(true);
      }
    } catch (e) { 
      // await EasyLoading.showError("$e");
    }
  }

  void adjustPlaybackSpeed(String t) {
    if ((t.contains("parler") || t.contains("dire")) && t.contains("lentement")) {
      _playbackSpeed = 0.85;
      if (t.contains("plus")) {
        _playbackSpeed = 0.7;
      }
    }
    if ((t.contains("speak") || t.contains("say")) && (t.contains("slowly") || t.contains("slower"))) {
      _playbackSpeed = 0.85;
      if (t.contains("more")) {
        _playbackSpeed = 0.7;
      }
    }
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
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.of(context).pushNamed(SettingsView.routeName);
        //   },
        //   icon: const Icon(Icons.sort),
        // ),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       Navigator.of(context).pushNamed(CallAIView.routeName);
        //     },
        //     icon: const Icon(Icons.duo_rounded, color: Colors.red, size: 28),
        //   ),
        //   GestureDetector(
        //     onTap: () => Navigator.of(context).pushNamed(HomeGrammarView.routeName),
        //     child: Container(  
        //       margin: const EdgeInsets.only(right: 10),
        //       child: Images.local("icon_grammar", 30), 
        //     ),
        //   ),
        //   const SizedBox(width: 8)
        // ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            child: Images.local("bg_audioview", screenSize.width, fit: BoxFit.cover),  
          ),
          Column( 
            children: [
              _audioFiles.isEmpty 
              ? 
              Column(
                children: [
                  Container( 
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: (screenSize.height - 100 - 50) / 2),
                    child: Images.local("logo-gray", 100),  
                  ),
                  // Container(
                  //   height: 260,
                  //   width: screenSize.width,  
                  //   margin: const EdgeInsets.only(top: 30),
                  //   child: ListView.builder(
                  //     // controller: _listController,
                  //     // scrollDirection: Axis.horizontal,
                  //     itemCount: suggestedTopics.length,
                  //     itemBuilder: (context, index) { 
                  //       return createRecommandedTopic(index, screenSize);
                  //     }
                  //   ),
                  // ),
                ],
              )
              : Container(),
              Expanded(
                child: ListView.builder(
                  controller: _listController,
                  itemCount: _audioFiles.length,
                  itemBuilder: (context, index) {
                    AudioItemModel audioItem = _audioFiles[index];
                    return ListTile(
                      // leading: audioItem.isUser ? 
                      //   const CircleAvatar(
                      //     radius: 20,  
                      //     backgroundColor: Colors.black,  
                      //     child: Text(
                      //       "M",
                      //       style: TextStyle(
                      //         fontSize: 20,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.white,
                      //       ),
                      //     ) 
                      //   )
                      //   :    
                      //   ClipRRect(
                      //     borderRadius: BorderRadius.circular(20),
                      //     child: Images.local("oceane-profile-small", 40),
                      //   ),
                      title: Wrap(
                        children: [
                          audioItem.isUser ?
                          Text(
                            '${AppLocalizations.of(context)!.me} ', 
                            style: TextStyle(
                              color: widget.controller.mColor.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ) : Text(
                            '${AppLocalizations.of(context)!.copine} ', 
                            style: TextStyle(
                              color: widget.controller.mColor.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${AppLocalizations.of(context)!.audioMessage} ${index + 1}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => _togglePlaying(audioItem.audioFilepath),
                      ), 
                      // subtitle: _hideAIResponseText ? null : 
                      //   audioItem.isUser ? null : audioItem.text.isEmpty ? null : Text(audioItem.text),
                      subtitle: createSubtitleMessage(index, audioItem),
                    );
                  },
                ),
              ), 
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ 
                  Container(
                    padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                    margin: const EdgeInsets.only(bottom: 10), 
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isHiddenEllePenseHints) {
                          _toggleRecording();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRecording ? Colors.red : Colors.black.withAlpha(20),  
                        foregroundColor: _isRecording ? Colors.white : Colors.black,  
                        elevation: 0,
                        fixedSize: Size(screenSize.width - (audioFilesGreaterThan2() ? 30 : 80), 45),
                        overlayColor: Colors.transparent,
                      ),
                      child:  
                        _isHiddenEllePenseHints && _isRecording 
                        ? Row(
                            mainAxisSize: MainAxisSize.min,  
                            children: [
                              const Icon(
                                Icons.stop_circle_outlined,  
                                color: Colors.white,  
                                size: 20,
                              ),
                              const SizedBox(width: 8), 
                              Text(AppLocalizations.of(context)!.pauseRecording),
                            ],
                          ) 
                        : _isHiddenEllePenseHints && !_isRecording 
                        ? Text(AppLocalizations.of(context)!.startRecording) 
                        : Text('${AppLocalizations.of(context)!.pleaseWaitParlerAIIsRespondingU}...', 
                            style: const TextStyle(color: Colors.blue),
                          ),
                    ),
                  ),
                  audioFilesGreaterThan2() ? Container() : GestureDetector(
                    onTap: () {
                      setState(() {
                        _hideAIResponseText = !_hideAIResponseText;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(16),   
                      child: Images.local("icon_script_a", 30), 
                    ),
                  ),
                ],
              ),
            ],
          ), 
        ],
      ),
    );
  }

  bool audioFilesGreaterThan2() {
    return _audioFiles.length < 2;
  }

  Widget? createSubtitleMessage(int index, AudioItemModel item) { 
    if (item.isUser) {
      return null;
    } 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hideAIResponseText ? Container() : Text(item.text, style: const TextStyle(color: Colors.black)), 
        const SizedBox(height: 8),
        Row(
          children: [
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
                child: Icon(item.isMarkedCopy ? Icons.copy_rounded : Icons.copy_all_sharp, size: 16, color: Colors.grey),
              ),
            ),
            GestureDetector(
              onTap: () {  
                fShowToast(AppLocalizations.of(context)!.thankYouForYourSupporting);
                feedbackRequest("like", _audioFiles[index-1].audioFilepath, _audioFiles[index].audioFilepath);
                setState(() {
                  item.isMarkedThumbup = true;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(top: 0, right: 0), 
                padding: const EdgeInsets.only(bottom: 10, right: 20),
                child: Icon(item.isMarkedThumbup ? Icons.thumb_up_rounded : Icons.thumb_up_outlined, size: 16, color: Colors.grey),
              ),
            ),
            GestureDetector(
              onTap: () {  
                ViewDialog.dialogDislikeOrReport(
                  context, 
                  () { 
                    fShowToast(AppLocalizations.of(context)!.weWillContinueWorkingToImproveTheContent);
                    feedbackRequest("dislike", _audioFiles[index-1].audioFilepath, _audioFiles[index].audioFilepath);
                  }, 
                  () {
                    fShowToast(AppLocalizations.of(context)!.weApologizeForTheInappropriateContent); 
                    setState(() {
                      _audioFiles.removeAt(index); 
                    });
                    feedbackRequest("report", _audioFiles[index-1].audioFilepath, _audioFiles[index].audioFilepath);
                  }, 
                  null);
              },
              child: Container(
                margin: const EdgeInsets.only(top: 0, right: 0), 
                padding: const EdgeInsets.only(bottom: 10, right: 20),
                child: const Icon(Icons.thumb_down_outlined, size: 16, color: Colors.grey),
              ),
            ), 
          ],
        ),
      ],
    );  
  }

  Widget createRecommandedTopic(int index, Size size) {
    Map<String, String> item = suggestedTopics[index];
    double margin = 30;
    double w = size.width - margin * 2;
    double h = 68;
    return Container(
      width: w - 20,
      height: h,
      margin: EdgeInsets.only(left: margin, top: 10, right: margin),
      padding: const EdgeInsets.only(left: 10, top: 3, right: 10, bottom: 3),
      decoration: BoxDecoration(
        color: widget.controller.mColor.backgroundGrey,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        children: [
          Text(
            item["title"] ?? "", 
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 16,),
          ),
          Text(
            item["desc"] ?? "", 
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 12),
            ), 
        ],
      ),
    );
  }

  List<Map<String, String>> getRandomTopics(List<Map<String, String>> topics, int count) {
    topics.shuffle(Random());
    return topics.take(count).toList();
  }

  void fShowToast(String msg) {
    Fluttertoast.showToast(msg: msg, gravity: ToastGravity.TOP);
  }

  void feedbackRequest(String type, String userText, String aiContent) async {
    await Requester().feedbackForAIContent(msgId, type, "audio", userText, aiContent);
  }
  
}


