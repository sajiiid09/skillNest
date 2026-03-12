import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import 'auth_service.dart';

class ApiService {
  // ==================== HEADERS ====================
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<dynamic>> getProjects({
    String? search,
    String? tags,
    double? minRate,
    double? maxRate,
  }) async {
    try {
      print('========== FETCH PROJECTS ==========');
      final headers = await _getHeaders();
      var url = ApiConstants.projects;
      final params = <String, String>{};

      if (search != null) params['search'] = search;
      if (tags != null) params['tags'] = tags;
      if (minRate != null) params['min_rate'] = minRate.toString();
      if (maxRate != null) params['max_rate'] = maxRate.toString();

      if (params.isNotEmpty) {
        url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      print('Endpoint: $url');
      final response = await http.get(Uri.parse(url), headers: headers);

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Projects Retrieved: ${(result as List).length}');
        print('Response: ${JsonEncoder.withIndent('  ').convert(result)}');
        print('===================================\n');
        return result;
      }
      print('Error: ${response.body}');
      print('===================================\n');
      return [];
    } catch (e) {
      print('Exception: $e');
      print('===================================\n');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createProject(
      Map<String, dynamic> data) async {
    try {
      print('========== CREATE PROJECT ==========');
      final headers = await _getHeaders();
      print('Request Body: ${JsonEncoder.withIndent('  ').convert(data)}');

      final response = await http.post(
        Uri.parse('${ApiConstants.projects}/'),
        headers: headers,
        body: jsonEncode(data),
      );

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 201) {
        final result = jsonDecode(response.body);
        print(
            'Project Created: ${JsonEncoder.withIndent('  ').convert(result)}');
        print('====================================\n');
        return result;
      }

      print('Create project error: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('====================================\n');
      return null;
    } catch (e) {
      print('Create project exception: $e');
      print('====================================\n');
      return null;
    }
  }

  // ==================== PROPOSALS ====================
  static Future<List<dynamic>> getMyProposals() async {
    try {
      print('========== FETCH MY PROPOSALS ==========');
      final headers = await _getHeaders();
      final url = ApiConstants.myProposals;

      print('Endpoint: $url');
      final response = await http.get(Uri.parse(url), headers: headers);

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Proposals Retrieved: ${(result as List).length}');
        print('Response: ${JsonEncoder.withIndent('  ').convert(result)}');
        print('========================================\n');
        return result;
      }
      print('Error: ${response.body}');
      print('========================================\n');
      return [];
    } catch (e) {
      print('Exception: $e');
      print('========================================\n');
      return [];
    }
  }

  static Future<List<dynamic>> getProjectProposals(int projectId) async {
    try {
      print('========== FETCH PROJECT PROPOSALS ==========');
      final headers = await _getHeaders();
      final url = '${ApiConstants.proposals}/project/$projectId';

      print('Endpoint: $url');
      print('Project ID: $projectId');
      final response = await http.get(Uri.parse(url), headers: headers);

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Proposals Retrieved: ${(result as List).length}');
        print('Response: ${JsonEncoder.withIndent('  ').convert(result)}');
        print('===========================================\n');
        return result;
      }
      print('Error: ${response.body}');
      print('===========================================\n');
      return [];
    } catch (e) {
      print('Exception: $e');
      print('===========================================\n');
      return [];
    }
  }

  static Future<bool> submitProposal(Map<String, dynamic> data) async {
    try {
      print('========== SUBMIT PROPOSAL ==========');
      final headers = await _getHeaders();
      print('Request Body: ${JsonEncoder.withIndent('  ').convert(data)}');

      final response = await http.post(
        Uri.parse('${ApiConstants.proposals}/'),
        headers: headers,
        body: jsonEncode(data),
      );

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 201) {
        print('Proposal Submitted Successfully');
        print('Response: ${response.body}');
        print('====================================\n');
        return true;
      }

      print('Submit proposal error: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('====================================\n');
      return false;
    } catch (e) {
      print('Submit proposal exception: $e');
      print('====================================\n');
      return false;
    }
  }

  static Future<bool> acceptProposal(int proposalId) async {
    try {
      print('========== ACCEPT PROPOSAL ==========');
      final headers = await _getHeaders();
      final url = '${ApiConstants.proposals}/$proposalId/accept';

      print('Endpoint: $url');
      print('Proposal ID: $proposalId');
      final response = await http.post(Uri.parse(url), headers: headers);

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Proposal Accepted Successfully');
        print('Response: ${response.body}');
        print('====================================\n');
        return true;
      }
      print('Error: ${response.body}');
      print('====================================\n');
      return false;
    } catch (e) {
      print('Exception: $e');
      print('====================================\n');
      return false;
    }
  }

  // ==================== ACCEPT + CREATE TASK ====================
  static Future<bool> acceptProposalAndCreateTask(int proposalId) async {
    try {
      print('========== ACCEPT PROPOSAL & CREATE TASK ==========');
      final headers = await _getHeaders();
      final url =
          '${ApiConstants.baseUrl}/tasks/proposal/$proposalId/accept-and-create-task';

      print('Endpoint: $url');
      print('Proposal ID: $proposalId');
      print('Headers: ${JsonEncoder.withIndent('  ').convert(headers)}');

      final response = await http.post(Uri.parse(url), headers: headers);

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Proposal Accepted & Task Created Successfully');
        print('Response: ${JsonEncoder.withIndent('  ').convert(result)}');
        print('==================================================\n');
        return true;
      }

      print('Accept & create task failed: ${response.body}');
      print('==================================================\n');
      return false;
    } catch (e) {
      print('Exception: $e');
      print('==================================================\n');
      return false;
    }
  }

  // ==================== TASKS ====================
  static Future<Map<String, dynamic>> getTaskDetails(int taskId) async {
    try {
      print('========== FETCH TASK DETAILS ==========');
      final headers = await _getHeaders();
      final url = '${ApiConstants.baseUrl}/tasks/$taskId';

      print('Endpoint: $url');
      print('Task ID: $taskId');
      final response = await http.get(Uri.parse(url), headers: headers);

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Task Retrieved Successfully');
        print('Response: ${JsonEncoder.withIndent('  ').convert(result)}');
        print('=======================================\n');
        return result;
      }
      print('Error: ${response.body}');
      print('=======================================\n');
      return {};
    } catch (e) {
      print('Exception: $e');
      print('=======================================\n');
      return {};
    }
  }

  static Future<List<dynamic>> getMyTasks({String? developerId}) async {
    try {
      print('========== FETCH MY TASKS ==========');
      final headers = await _getHeaders();
      var url = ApiConstants.myTasks;

      // Try with query parameter if needed
      if (developerId != null) {
        url += '?developer_id=$developerId';
      }

      print('Endpoint: $url');
      print('Headers: ${headers['Authorization']}');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('Status Code: ${response.statusCode}');
      print('Status Message: ${response.reasonPhrase}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = response.body;
        print('Raw Response: $responseBody');

        dynamic result;
        try {
          result = jsonDecode(responseBody);
        } catch (e) {
          print('JSON Decode Error: $e');
          return [];
        }

        // Handle multiple response formats
        List<dynamic> tasks = [];

        if (result is List) {
          tasks = result;
        } else if (result is Map) {
          if (result.containsKey('data')) {
            tasks = result['data'] is List ? result['data'] : [];
          } else if (result.containsKey('tasks')) {
            tasks = result['tasks'] is List ? result['tasks'] : [];
          } else if (result.containsKey('results')) {
            tasks = result['results'] is List ? result['results'] : [];
          } else {
            // If response is a single task wrapped in object
            tasks = [result];
          }
        }

        print('Tasks Retrieved: ${tasks.length}');
        if (tasks.isNotEmpty) {
          print('Task List:');
          for (var i = 0; i < tasks.length; i++) {
            final task = tasks[i];
            print(
                '  [$i] ID: ${task['id']}, Title: ${task['title']}, Status: ${task['status']}');
          }
        }
        print('Full Response: ${JsonEncoder.withIndent('  ').convert(tasks)}');
        print('==================================\n');
        return tasks;
      }

      print('Error Status: ${response.statusCode}');
      print('Error Body: ${response.body}');

      // If 422, the endpoint might not exist or requires different path
      if (response.statusCode == 422) {
        print('⚠️   422 Error - Endpoint might require different structure');
        print(
            'Try checking if your backend has this endpoint: GET /api/v1/tasks/my-tasks');
      }

      print('==================================\n');
      return [];
    } catch (e) {
      print('Exception: $e');
      print('Stack Trace: ${StackTrace.current}');
      print('==================================\n');
      return [];
    }
  }

  static Future<List<dynamic>> getProjectTasks(int projectId) async {
    try {
      print('========== FETCH PROJECT TASKS ==========');
      final headers = await _getHeaders();
      final url = '${ApiConstants.projects}/$projectId/tasks';

      print('Endpoint: $url');
      print('Project ID: $projectId');
      final response = await http.get(Uri.parse(url), headers: headers);

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Project Tasks Retrieved: ${(result as List).length}');
        print('Response: ${JsonEncoder.withIndent('  ').convert(result)}');
        print('=========================================\n');
        return result;
      }
      print('Error: ${response.body}');
      print('=========================================\n');
      return [];
    } catch (e) {
      print('Exception: $e');
      print('=========================================\n');
      return [];
    }
  }

  static Future<bool> updateTaskStatus(int taskId, String status) async {
    try {
      print('========== UPDATE TASK STATUS ==========');
      final headers = await _getHeaders();
      final url = '${ApiConstants.tasks}/$taskId';

      print('Endpoint: $url');
      print('Task ID: $taskId');
      print('New Status: $status');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Task Status Updated Successfully');
        print('Response: ${response.body}');
        print('=======================================\n');
        return true;
      }
      print('Error: ${response.body}');
      print('=======================================\n');
      return false;
    } catch (e) {
      print('Exception: $e');
      print('=======================================\n');
      return false;
    }
  }

  static Future<bool> submitTask(
      int taskId, double timeSpent, File file) async {
    try {
      print('========== SUBMIT TASK ==========');
      final token = await AuthService.getToken();
      final url = '${ApiConstants.baseUrl}/tasks/$taskId/submit';

      print('Endpoint: $url');
      print('Task ID: $taskId');
      print('Time Spent: $timeSpent hours');
      print('File: ${file.path.split('/').last}');
      print('File Size: ${file.lengthSync()} bytes');

      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['time_spent'] = timeSpent.toString();
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      print('Sending request...');
      final response = await request.send();

      print('Status Code: ${response.statusCode}');
      final responseBody = await response.stream.bytesToString();
      print('Response: $responseBody');

      if (response.statusCode == 200) {
        print('Task Submitted Successfully');
        print('================================\n');
        return true;
      }
      print('Error: $responseBody');
      print('================================\n');
      return false;
    } catch (e) {
      print('Exception: $e');
      print('================================\n');
      return false;
    }
  }

  // ==================== PAYMENTS ====================
  static Future<bool> makePayment(int taskId) async {
    try {
      print('========== MAKE PAYMENT ==========');
      final headers = await _getHeaders();
      final url = '${ApiConstants.payments}/';

      print('Endpoint: $url');
      print('Task ID: $taskId');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'task_id': taskId}),
      );

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Payment Processed Successfully');
        print('Response: ${response.body}');
        print('=================================\n');
        return true;
      }
      print('Error: ${response.body}');
      print('=================================\n');
      return false;
    } catch (e) {
      print('Exception: $e');
      print('=================================\n');
      return false;
    }
  }

  // ==================== DOWNLOAD FILE ====================
  static Future<List<int>?> downloadTaskFile(int taskId) async {
    try {
      print('========== DOWNLOAD TASK FILE ==========');
      final headers = await _getHeaders();
      final url = '${ApiConstants.baseUrl}/tasks/$taskId/download';

      print('Endpoint: $url');
      print('Task ID: $taskId');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('File Downloaded Successfully');
        print('File Size: ${response.bodyBytes.length} bytes');
        print('=======================================\n');
        return response.bodyBytes;
      }
      print('Error: ${response.body}');
      print('=======================================\n');
      return null;
    } catch (e) {
      print('Exception: $e');
      print('=======================================\n');
      return null;
    }
  }

  // ==================== ADMIN ====================
  static Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      print('========== FETCH DASHBOARD STATS ==========');
      final headers = await _getHeaders();
      final url = ApiConstants.adminDashboard;

      print('Endpoint: $url');
      final response = await http.get(Uri.parse(url), headers: headers);

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Dashboard Stats Retrieved');
        print('Response: ${JsonEncoder.withIndent('  ').convert(result)}');
        print('==========================================\n');
        return result;
      }
      print('Error: ${response.body}');
      print('==========================================\n');
      return null;
    } catch (e) {
      print('Exception: $e');
      print('==========================================\n');
      return null;
    }
  }
}
