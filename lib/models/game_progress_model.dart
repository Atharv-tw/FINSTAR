/// Model for tracking game progress
class GameProgressModel {
  final String gameId;
  final String gameName;
  final int highScore;
  final int timesPlayed;
  final DateTime lastPlayed;
  final bool isCompleted;
  final Map<String, dynamic>? gameData;

  GameProgressModel({
    required this.gameId,
    required this.gameName,
    required this.highScore,
    required this.timesPlayed,
    required this.lastPlayed,
    this.isCompleted = false,
    this.gameData,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'gameName': gameName,
      'highScore': highScore,
      'timesPlayed': timesPlayed,
      'lastPlayed': lastPlayed.toIso8601String(),
      'isCompleted': isCompleted,
      'gameData': gameData,
    };
  }

  factory GameProgressModel.fromJson(Map<String, dynamic> json) {
    return GameProgressModel(
      gameId: json['gameId'] as String,
      gameName: json['gameName'] as String,
      highScore: json['highScore'] as int,
      timesPlayed: json['timesPlayed'] as int,
      lastPlayed: DateTime.parse(json['lastPlayed'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      gameData: json['gameData'] as Map<String, dynamic>?,
    );
  }
}
