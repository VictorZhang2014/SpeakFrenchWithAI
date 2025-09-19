import 'package:flutter/material.dart';
import 'package:flutter_c2copine/src/settings/settings_controller.dart';
import 'package:flutter_c2copine/src/statemng/account.dart';
import 'package:flutter_c2copine/src/utils/Images.dart';
import 'package:flutter_c2copine/src/utils/mcolor.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart'; 
import 'package:flutter_c2copine/src/localization/app_localizations.dart'; 


class AIEngineChooseView extends StatefulWidget {
  const AIEngineChooseView({super.key, required this.controller});

  static const routeName = '/aiengine_choose_view';

  final SettingsController controller;

  @override
  State<StatefulWidget> createState() { 
    return _AIEngineChooseViewState();
  }
}

class _AIEngineChooseViewState extends State<AIEngineChooseView> { 

  String selectedAI = "";

  @override
  void initState() { 
    super.initState();
    selectedAI = Account().aiEngine;
  }

  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    double margin = 20;
    Color bgColor = Colors.grey[100]!;
    double cardWidth = (s.width - margin * 3) / 2;
    double cardHeight = cardWidth * 1.3;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appParlerAI), 
        backgroundColor: Colors.white,
      ),
      backgroundColor: bgColor,
      body: Container(
        margin: EdgeInsets.all(margin),
        child: Column(
          children: [ 
            Container( 
              margin: EdgeInsets.only(top: margin), 
              child: Text(AppLocalizations.of(context)!.chooseTheOneYouPrefer, style: const TextStyle(fontSize: 18),), 
            ), 
            SizedBox(height: margin),
            Row(
              children: [
                createEngineCard("openai-logo", "OpenAI", cardWidth, cardHeight, 0, margin),
                createEngineCard("deepseek-logo", "DeepSeek", cardWidth, cardHeight, margin, margin),
              ],
            ),
            Row(
              children: [
                createEngineCard("mistralai-logo", "LeChat", cardWidth, cardHeight, 0, margin),
                createEngineCard("grokai-logo", "Grok", cardWidth, cardHeight, margin, margin),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {  
                // En raison du manque d'intégration de Grok, nous avons décidé de ne pas le mettre dans la liste des moteurs AI
                if (selectedAI == "grok") {
                  selectedAI = "openai"; // C'est la valeur par défaut, et nous ne voulons pas que l'utilisateur choisisse Grok
                }
                widget.controller.changeAIEngine(selectedAI);
                EasyLoading.showSuccess(AppLocalizations.of(context)!.operationCompleted, duration: const Duration(seconds: 1));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.controller.mColor.primary,  
                foregroundColor: Colors.white,  
                elevation: 0,
                fixedSize: Size(s.width - margin * 2, 45),
                overlayColor: Colors.transparent,
              ),
              child: Text(AppLocalizations.of(context)!.changeNow, style: const TextStyle(fontSize: 16),), 
            )
          ],
        ),
      ),
    );
  }

  Widget createEngineCard(String imgName, String engineName, double width, double height, double leftMargin, double topMargin) {
    bool isSelected = selectedAI == engineName.toLowerCase();
    var c = Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(left: leftMargin, top: topMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        border: Border.all(
          color: isSelected ? widget.controller.mColor.primary : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center, 
        children: [ 
          Container( 
            child: Images.local(imgName, 80),
          ),
          Container(
            width: width, 
            margin: EdgeInsets.only(top: topMargin),
            child: Text(engineName, style: const TextStyle(fontSize: 15,), textAlign: TextAlign.center,),
          ),
        ],
      ),
    );  
    return GestureDetector(
      child: c,
      onTap: () {
        setState(() {
          selectedAI = engineName.toLowerCase();
        });
      },
    );
  }

}
