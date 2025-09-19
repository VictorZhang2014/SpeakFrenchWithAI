

class MessageItemModel {

  bool isUser = true;
  String text = "";

  bool isMarkedCopy = false; 
  bool isMarkedThumbup = false; 

  bool isAnimated = false; // 作为agent消息，是否已经动画播放过

  MessageItemModel(this.isUser, this.text);

}

class MessageItemModelTool {

  static List<Map<String, String>> getMessages(List<MessageItemModel> msgList) {
    List<Map<String, String>> messages = [];
    for (MessageItemModel item in msgList) {
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

