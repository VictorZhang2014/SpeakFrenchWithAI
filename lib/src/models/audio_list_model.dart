
class AudioItemModel {

  bool isUser = true;
  String audioFilepath = "";
  String text = "";

  // UI State
  bool isPlaying = false;
  
  bool isMarkedCopy = false; 
  bool isMarkedThumbup = false; 

  AudioItemModel(this.isUser, this.audioFilepath, this.text);

}

class AudioItemModelTool {

  static List<Map<String, String>> getMessages(List<AudioItemModel> audioList) {
    List<Map<String, String>> messages = [];
    for (AudioItemModel item in audioList) {
      if (item.text.isEmpty) {
        continue;
      }
      messages.add({
        "role": item.isUser ? "user" : "assistant",
        "content": item.text
      });
    }
    return messages;
  }

}

