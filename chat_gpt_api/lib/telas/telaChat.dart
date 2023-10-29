// ignore_for_file: file_names

import 'package:chat_gpt_api/constantes/constants.dart';
import 'package:chat_gpt_api/models/chat_model.dart';
import 'package:chat_gpt_api/providers/chats_provider.dart';
import 'package:chat_gpt_api/services/api_service.dart';
import 'package:chat_gpt_api/services/services.dart';
import 'package:chat_gpt_api/widgets/chat_widget.dart';
import 'package:chat_gpt_api/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../providers/models_provider.dart';

class TelaChat extends StatefulWidget {
  const TelaChat({super.key});

  @override
  State<TelaChat> createState() => _TelaChat();
}

class _TelaChat extends State<TelaChat> {
  bool _tipyng = false;
  late TextEditingController textEditingController;
  late ScrollController _listscrollController;
  late FocusNode focusNode;

  @override
  void initState() {
    _listscrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _listscrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  //List<ChatModel> chatList = [];

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("assets/images/openai_logo.jpg"),
        ),
        title: const Text("Heitor-GPT"),
        actions: [
          IconButton(
            onPressed: () async {
              await Services.showModalSheet(context: context);
            },
            icon: const Icon(Icons.more_vert_rounded),
            color: Colors.white,
          )
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Flexible(
            child: ListView.builder(
              controller: _listscrollController,
              itemCount: chatProvider.getChatList.length,
              itemBuilder: (context, index) {
                return ChatWidget(
                  msg: chatProvider.getChatList[index].msg,
                  chatIndex: chatProvider.getChatList[index].chatIndex,
                );
              },
            ),
          ),
          if (_tipyng) ...[
            const SpinKitFoldingCube(
              color: Colors.white,
              size: 18,
            ),
          ],
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            height: 20,
          ),
          Material(
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: focusNode,
                      style: const TextStyle(color: Colors.white),
                      controller: textEditingController,
                      onSubmitted: (value) async {
                        await sendMessageFCT(
                            modelsProvider: modelsProvider,
                            chatProvider: chatProvider);
                      },
                      decoration: const InputDecoration.collapsed(
                          hintText: "Envie uma mensagem",
                          hintStyle: TextStyle(color: Colors.white)),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await sendMessageFCT(
                          modelsProvider: modelsProvider,
                          chatProvider: chatProvider);
                    },
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                  )
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }

  void scrollToEnd() {
    _listscrollController.animateTo(
        _listscrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_tipyng) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: TextWidget(
            label: "Não é possível mandar mais de uma mensagem ao mesmo tempo"),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: TextWidget(label: "Escreva uma mensagem"),
        backgroundColor: Colors.red,
      ));
      return;
    }
    try {
      String msg = textEditingController.text;
      debugPrint("Request enviada!");
      setState(() {
        _tipyng = true;
        //chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
        chatProvider.addUserMessage(msg: msg);
        textEditingController.clear();
        focusNode.unfocus();
      });
      await chatProvider.sendAndGet(
          msg: msg, chosenModelId: modelsProvider.getCurrentModel);
      // chatList.addAll(await ApiService.sendMessage(
      //     message: textEditingController.text,
      //     modelID: modelsProvider.getCurrentModel));
      setState(() {});
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollToEnd();
        _tipyng = false;
      });
    }
  }
}
