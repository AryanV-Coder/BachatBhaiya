import 'dart:convert';
import 'package:http/http.dart' as http;

class GameNode {
  final String nodeId;
  final String scenario;
  final List<GameChoice> choices;

  GameNode({
    required this.nodeId,
    required this.scenario,
    required this.choices,
  });

  factory GameNode.fromJson(Map<String, dynamic> json) {
    return GameNode(
      nodeId: json['node_id'],
      scenario: json['scenario'],
      choices: (json['choices'] as List)
          .map((choice) => GameChoice.fromJson(choice))
          .toList(),
    );
  }
}

class GameChoice {
  final String choiceText;
  final int coinImpact;
  final String nextNodeId;

  GameChoice({
    required this.choiceText,
    required this.coinImpact,
    required this.nextNodeId,
  });

  factory GameChoice.fromJson(Map<String, dynamic> json) {
    return GameChoice(
      choiceText: json['choice_text'],
      coinImpact: json['coin_impact'],
      nextNodeId: json['next_node_id'],
    );
  }
}

class GameplayResponse {
  final String status;
  final List<GameNode> nodes;
  final List<String> optimalPath;
  final String message;

  GameplayResponse({
    required this.status,
    required this.nodes,
    required this.optimalPath,
    required this.message,
  });

  factory GameplayResponse.fromJson(Map<String, dynamic> json) {
    return GameplayResponse(
      status: json['status'],
      nodes: (json['data']['nodes'] as List)
          .map((node) => GameNode.fromJson(node))
          .toList(),
      optimalPath: List<String>.from(json['data']['optimal_path']),
      message: json['message'],
    );
  }
}

class BachatBhaiyaResponse {
  final String status;
  final String advice;
  final String message;

  BachatBhaiyaResponse({
    required this.status,
    required this.advice,
    required this.message,
  });

  factory BachatBhaiyaResponse.fromJson(Map<String, dynamic> json) {
    return BachatBhaiyaResponse(
      status: json['status'],
      advice: json['data'],
      message: json['message'],
    );
  }
}

class GameplayService {
  static const String baseUrl = 'https://bachatbhaiya.onrender.com';

  Future<GameplayResponse> fetchGameplay({
    required String role,
    required int level,
    required int totalCoins,
  }) async {
    final url = Uri.parse('$baseUrl/gameplay');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'role': role,
        'level': level.toString(),
        'total_coins': totalCoins.toString(),
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return GameplayResponse.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load gameplay: ${response.statusCode}');
    }
  }

  Future<BachatBhaiyaResponse> fetchBachatBhaiyaAdvice({
    required String role,
    required int previousLevel,
    required int currentCoins,
    required Map<String, dynamic> previousLevelGraph,
  }) async {
    final url = Uri.parse('$baseUrl/bachat-bhaiya');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'role': role,
        'previousLevel': previousLevel.toString(),
        'currentCoins': currentCoins.toString(),
        'previousLevelGraph': previousLevelGraph,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return BachatBhaiyaResponse.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load Bachat Bhaiya advice: ${response.statusCode}');
    }
  }
}