import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reply_template.dart';
import '../config/firebase_config.dart';

class TemplateProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ReplyTemplate> _templates = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReplyTemplate> get templates => _templates;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Map<String, List<ReplyTemplate>> get templatesByCategory {
    final Map<String, List<ReplyTemplate>> grouped = {};
    for (var template in _templates) {
      if (!grouped.containsKey(template.category)) {
        grouped[template.category] = [];
      }
      grouped[template.category]!.add(template);
    }
    return grouped;
  }

  Future<void> fetchTemplates() async {
    _setLoading(true);
    _clearError();

    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConfig.templatesCollection)
          .orderBy('category')
          .get();

      _templates = querySnapshot.docs
          .map((doc) => ReplyTemplate.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch templates: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<bool> createTemplate(String category, String templateText) async {
    _setLoading(true);
    _clearError();

    try {
      final docRef = await _firestore
          .collection(FirebaseConfig.templatesCollection)
          .add({
            'category': category,
            'template_text': templateText,
          });

      final newTemplate = ReplyTemplate(
        id: docRef.id,
        category: category,
        templateText: templateText,
      );
      _templates.add(newTemplate);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to create template: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateTemplate(String templateId, String category, String templateText) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestore
          .collection(FirebaseConfig.templatesCollection)
          .doc(templateId)
          .update({
            'category': category,
            'template_text': templateText,
          });

      final templateIndex = _templates.indexWhere((t) => t.id == templateId);
      if (templateIndex != -1) {
        _templates[templateIndex] = ReplyTemplate(
          id: templateId,
          category: category,
          templateText: templateText,
        );
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update template: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteTemplate(String templateId) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestore
          .collection(FirebaseConfig.templatesCollection)
          .doc(templateId)
          .delete();

      _templates.removeWhere((template) => template.id == templateId);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete template: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
