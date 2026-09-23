import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _patients = [];

  List<Map<String, dynamic>> get sessions => _sessions;
  List<Map<String, dynamic>> get patients => _patients;

  DataProvider() {
    _loadData();
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? sessionsData = prefs.getString('saved_sessions');
    if (sessionsData != null) {
      List<dynamic> decodedSessions = json.decode(sessionsData);
      _sessions = decodedSessions
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    String? patientsData = prefs.getString('saved_patients');
    if (patientsData != null) {
      List<dynamic> decodedPatients = json.decode(patientsData);
      _patients = decodedPatients
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    notifyListeners();
  }

  void addPatient(String name, int age, String diagnosis) async {
    final newPatient = {
      'id':
          'SRG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'name': name,
      'age': age,
      'diagnosis': diagnosis,
      'joinDate': DateTime.now().toIso8601String(),
    };

    _patients.insert(0, newPatient);
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('saved_patients', json.encode(_patients));
  }

  void addSession(
    String patientId,
    String patientName,
    int durationInSeconds,
    double score,
    List<double> fingerValues,
  ) async {
    final newSession = {
      'patientId': patientId,
      'patientName': patientName,
      'date': DateTime.now().toIso8601String(),
      'duration': durationInSeconds,
      'score': score,
      'fingers': fingerValues,
    };

    _sessions.insert(0, newSession);
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('saved_sessions', json.encode(_sessions));
  }

  // الدالة الجديدة لحذف المريض وجلساته
  void deletePatient(String patientId) async {
    _patients.removeWhere((p) => p['id'] == patientId);
    _sessions.removeWhere((s) => s['patientId'] == patientId);

    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('saved_patients', json.encode(_patients));
    prefs.setString('saved_sessions', json.encode(_sessions));
  }

  String getTotalTherapyHours() {
    int totalSeconds = _sessions.fold(
      0,
      (sum, item) => sum + (item['duration'] as int),
    );
    double hours = totalSeconds / 3600;
    return hours.toStringAsFixed(1);
  }

  double getTodayProgress() {
    if (_sessions.isEmpty) return 0.0;
    int targetSessions = 4;
    DateTime today = DateTime.now();

    int todaySessionsCount = _sessions.where((session) {
      DateTime date = DateTime.parse(session['date']);
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;

    double progress = todaySessionsCount / targetSessions;
    return progress > 1.0 ? 1.0 : progress;
  }
}
