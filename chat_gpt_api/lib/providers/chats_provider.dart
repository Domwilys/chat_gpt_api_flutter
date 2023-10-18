import 'package:chat_gpt_api/models/chat_model.dart';
import 'package:chat_gpt_api/services/api_service.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  List<ChatModel> get getChatList {
    return chatList;
  }

  void addUserMessage({required String msg}) {
    chatList.add(ChatModel(msg: msg, chatIndex: 0));
  }

  Future<void> sendAndGet(
      {required String msg, required String chosenModelId}) async {
    chatList.addAll(
        await ApiService.sendMessage(message: msg, modelID: chosenModelId));
    notifyListeners();
  }
}
