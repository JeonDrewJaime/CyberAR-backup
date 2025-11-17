import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/model/module_model.dart';
import 'package:flutter_unity_widget_example/services/module_repository.dart';

class ModuleViewModel extends ChangeNotifier {
  final ModuleRepository _moduleRepository;
  ModuleViewModel(this._moduleRepository);

  // private
  String? _errorMessage;

  //! MODULE DATA
  List<ModuleModel> _modules = []; //! ALL MODULES
  ModuleModel? _currentModule; //! CURRENT MODULE

  StreamSubscription<List<ModuleModel>>?
      _modulesSubscription; //! ALL MODULES SUBSCRIPTION
  StreamSubscription<ModuleModel?>?
      _moduleSubscription; //! CURRENT MODULE SUBSCRIPTION

  // public getters
  //! GET ERROR MESSAGE
  String? get errorMessage => _errorMessage;

  //! GET ALL MODULES
  List<ModuleModel> get modules => _modules;

  //! GET CURRENT MODULE
  ModuleModel? get currentModule => _currentModule;

  //! CLEAR MESSAGE
  void clearMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  //! LISTEN TO ALL MODULES
  void listenToModules() {
    _modulesSubscription?.cancel();
    _modulesSubscription = _moduleRepository.listenToModules().listen(
      (modules) {
        _modules = modules;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  //! LISTEN TO SPECIFIC MODULE
  void listenToModule(String moduleId) {
    _moduleSubscription?.cancel();
    _moduleSubscription = _moduleRepository.listenToModule(moduleId).listen(
      (module) {
        _currentModule = module;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  //! UPDATE LESSON STATUS
  Future<void> updateLessonStatus({
    required String moduleId,
    required int lessonId,
    required String userId,
    required String status,
  }) async {
    try {
      await _moduleRepository.updateLessonStatus(
        moduleId: moduleId,
        lessonId: lessonId,
        userId: userId,
        status: status,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _modulesSubscription?.cancel();
    _moduleSubscription?.cancel();
    super.dispose();
  }
}
