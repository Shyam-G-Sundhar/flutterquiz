class Question {
  final String question;
  final int correctAnswerIndex;
  final List<String> options;

  Question({
    required this.question,
    required this.correctAnswerIndex,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      correctAnswerIndex: json['correctAnswerIndex'],
      options: List<String>.from(json['options']),
    );
  }
}
