import 'package:chat_gpt_api/models/models.dart';
import 'package:chat_gpt_api/services/api_service.dart';
import 'package:flutter/material.dart';

class ModelsProvider with ChangeNotifier {
  String currentModel = "gpt-3.5-turbo";
  String get getCurrentModel {
    return currentModel;
  }

  void setCurrentModel(String newModel) {
    currentModel = newModel;
    notifyListeners();
  }

  List<ResponseModel> modelsList = [];
  List<ResponseModel> get getModelsList {
    return modelsList;
  }

  Future<List<ResponseModel>> getAllModels() async {
    modelsList = await ApiService.getModels();

    return modelsList;
  }
}
