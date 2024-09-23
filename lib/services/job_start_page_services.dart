import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskscout/classes/job.dart';
import 'package:taskscout/config.dart';
import 'package:taskscout/data_model.dart';

class JobStartPageServices {
  static final JobStartPageServices _instance =
      JobStartPageServices._internal();

  JobStartPageServices._internal();

  factory JobStartPageServices() {
    return _instance;
  }

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<bool> submitJob(Job job) async {
    String? username = await secureStorage.read(key: 'username');
    String? password = await secureStorage.read(key: 'password');
    String id = DataModel().user.id;
    try {
      final response = await http
          .post(
            Uri.parse(
                'http://${Config.backendIp}:${Config.backendPort}/api/jobs'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'id': id,
              'job': Job.toJson(job)
            }),
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          job.userStatus = "done";

          var dataModel = DataModel();
          await dataModel.saveDoneJob(job);
          await dataModel.removeJob(job.id);
          return true;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}
