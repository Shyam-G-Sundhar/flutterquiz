import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quiz_app_tutorial/models/question.dart';
import '/models/questions.dart';
import '/screens/quiz_screen.dart';
import '/widgets/next_button.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    Key? key,
    required this.score,
    required this.questions,
  }) : super(key: key);

  final int score;
  final List<Question> questions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Your Score: $score / ${questions.length}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                    
                      height: 250,
                      width: 250,
                      child: CircularProgressIndicator(
                        strokeWidth: 15,
                        value: score / questions.length,
                        color: Colors.blue.shade800,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          score.toString(),
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${(score / questions.length * 100).round()}%',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ViewAnswersScreen(questions: questions),
                ));
              },
              child: Text('View Answers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800
              ),),
            ),
            SizedBox(height: 15,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => QuizScreen(),
                ));
              },
              child: Text('Go Back',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800
              ),),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewAnswersScreen extends StatelessWidget {
  final List<Question> questions;

  const ViewAnswersScreen({Key? key, required this.questions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Answers'),
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${index + 1}: ${question.question}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    question.options.length,
                    (optionIndex) {
                      final option = question.options[optionIndex];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Radio(
                              value: optionIndex,
                              groupValue: question.correctAnswerIndex,
                              onChanged: (value) {},
                            ),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: optionIndex == question.correctAnswerIndex
                                      ? Colors.green
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
