// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_gpt_api/constantes/api_consts.dart';
import 'package:chat_gpt_api/models/chat_model.dart';
import 'package:chat_gpt_api/models/models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<ResponseModel>> getModels() async {
    try {
      var response = await http.get(Uri.parse("$BASE_URL/models"),
          headers: {'Authorization': 'Bearer $API_KEY'});

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']['message']);
      }
      //print("JsonResponse: $jsonResponse");

      List temp = [];
      for (var i in jsonResponse["data"]) {
        temp.add(i);
        //print("Temp: ${i["id"]}");
      }
      return ResponseModel.modelsFromSnapshot(temp);
    } catch (error) {
      print("Error: ${error}");
      rethrow;
    }
  }

  //Função que envia mensagens
  static Future<List<ChatModel>> sendMessage(
      {required String message, required String modelID}) async {
    try {
      var response = await http.post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: {
            'Authorization': 'Bearer $API_KEY',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "model": modelID,
            "messages": [
              {"role": "user", "content": message}
            ]
          }));

      Map jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']['message']);
      }

      List<ChatModel> chatList = [];
      if (jsonResponse["choices"] != null) {
        chatList = List.generate(
          jsonResponse['choices'].length,
          (index) => ChatModel(
            msg:
                jsonResponse['choices'][index]['message']['content'].toString(),
            chatIndex: 1,
          ),
        );
      }
      return chatList;
    } catch (error) {
      print("Error: ${error}");
      rethrow;
    }
  }
}
