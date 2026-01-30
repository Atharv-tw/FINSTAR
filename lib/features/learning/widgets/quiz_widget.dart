import 'package:flutter/material.dart';
import 'package:finstar_app/models/learning_module.dart';
import 'package:finstar_app/features/learning/learning_theme.dart';

class QuizWidget extends StatefulWidget {
  final List<QuizQuestion> questions;
  final Function(int) onQuizCompleted;

  const QuizWidget({
    Key? key,
    required this.questions,
    required this.onQuizCompleted,
  }) : super(key: key);

  @override
  _QuizWidgetState createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  int currentQuestionIndex = 0;
  int? selectedAnswer;
  bool answerChecked = false;
  int correctAnswers = 0;

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiz Time! 🧠',
          style: LearningTheme.headline2.copyWith(color: LearningTheme.vanDyke),
        ),
        const SizedBox(height: 16),
        Text(
          question.question,
          style: LearningTheme.bodyText1.copyWith(color: LearningTheme.vanDyke, fontSize: 18),
        ),
        const SizedBox(height: 24),
        ...List.generate(question.options.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RadioListTile<int>(
              title: Text(question.options[index]),
              value: index,
              groupValue: selectedAnswer,
              onChanged: (value) {
                setState(() {
                  selectedAnswer = value;
                });
              },
            ),
          );
        }),
        const SizedBox(height: 24),
        if (answerChecked)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selectedAnswer == question.correctAnswer
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              selectedAnswer == question.correctAnswer
                  ? 'Correct! ${question.explanation}'
                  : 'Incorrect. ${question.explanation}',
              style: LearningTheme.bodyText1,
            ),
          ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: selectedAnswer != null ? () {
            if (answerChecked) {
              if (currentQuestionIndex < widget.questions.length - 1) {
                setState(() {
                  currentQuestionIndex++;
                  selectedAnswer = null;
                  answerChecked = false;
                });
              } else {
                widget.onQuizCompleted(correctAnswers);
              }
            } else {
              setState(() {
                answerChecked = true;
                if (selectedAnswer == question.correctAnswer) {
                  correctAnswers++;
                }
              });
            }
          } : null,
          child: Text(
            answerChecked
                ? (currentQuestionIndex < widget.questions.length - 1
                    ? 'Next Question'
                    : 'Finish Quiz')
                : 'Check Answer',
          ),
        ),
      ],
    );
  }
}
