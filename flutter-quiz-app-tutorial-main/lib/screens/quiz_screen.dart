import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app_tutorial/models/question.dart';
import 'package:quiz_app_tutorial/screens/result_screen.dart';
import 'package:quiz_app_tutorial/widgets/next_button.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? selectedAnswerIndex;
  int questionIndex = 0;
  int score = 0;
  late Timer _timer;
  double _progressValue = 1.0;
  int _remainingSeconds = 20;
  List<bool> answeredCorrectly = [];
  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions(); // Fetch questions from the network
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse('https://api.jsonbin.io/v3/b/65fd52f1266cfc3fde9c1d74'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic>? data = responseData['record']; // Accessing the 'record' field directly
        if (data != null) {
          setState(() {
            questions = data.map((item) => Question.fromJson(item)).toList();
            answeredCorrectly = List.filled(questions.length, false);
          });
        } else {
          throw Exception('Questions not found in response');
        }
      } else {
        throw Exception('Failed to load questions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _timer.cancel(); // Stop the timer if questions are not loaded
      print('Error fetching questions: $e');
    }
  }

  void _startTimer() {
    const tickInterval = Duration(seconds: 1);
    const totalSeconds = 20;

    _timer = Timer.periodic(tickInterval, (timer) {
      setState(() {
        _remainingSeconds--;
        _progressValue = _remainingSeconds / totalSeconds;

        if (_remainingSeconds <= 0) {
          timer.cancel();
          _handleTimeUp();
        }
      });
    });
  }

 void _handleTimeUp() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Time's Up"),
        actions: [
          ElevatedButton(
            
            onPressed: () {
              _goToNextQuestion();
              Navigator.of(context).pop(); // Close the dialog
               // Proceed to the next question
            },
            child: Text('Next'),
          ),
        ],
      );
    },
  );
}


  void _pickAnswer(int value) {
    setState(() {
      selectedAnswerIndex = value;
    });
  }

  void _goToNextQuestion() {
    final question = questions[questionIndex];
    if (selectedAnswerIndex != null) {
      if (selectedAnswerIndex == question.correctAnswerIndex) {
        setState(() {
          score++;
          answeredCorrectly[questionIndex] = true;
        });
      }
      setState(() {
        if (questionIndex < questions.length - 1) {
          questionIndex++;
          selectedAnswerIndex = null;
          _progressValue = 1.0; // Reset progress for the next question
          _remainingSeconds = 20; // Reset remaining seconds for the next question
        } else {
          _timer.cancel(); // Cancel timer if it's the last question
        }
      });
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kindly Select the Option',
      style: TextStyle(
        color: Colors.white,
       
        fontWeight: FontWeight.w800

      ),)));
    }
  }

void _goToResultScreenAction() {
    final question = questions[questionIndex];
    
      if (selectedAnswerIndex == question.correctAnswerIndex) {
        setState(() {
          score++;
          answeredCorrectly[questionIndex] = true;
        });
      }
      _timer.cancel(); // Cancel the timer before navigating to the result screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: score,
            questions: questions,
          ),
        ),
      );
    
  }




  void _goToResultScreen() {
    final question = questions[questionIndex];
    if (selectedAnswerIndex != null) {
      if (selectedAnswerIndex == question.correctAnswerIndex) {
        setState(() {
          score++;
          answeredCorrectly[questionIndex] = true;
        });
      }
      _timer.cancel(); // Cancel the timer before navigating to the result screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: score,
            questions: questions,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastQuestion = questionIndex == questions.length - 1;
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz App'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final question = questions[questionIndex];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        actions: [
          IconButton(
            onPressed: _goToResultScreenAction,
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            LinearProgressIndicator(
              value: _progressValue,
              backgroundColor: Colors.grey,
              valueColor: _progressValue > 0.6
                  ? AlwaysStoppedAnimation<Color>(Colors.green)
                  : _progressValue > 0.3
                      ? AlwaysStoppedAnimation<Color>(Colors.yellow)
                      : AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer),
                SizedBox(width: 5),
                Text(
                  '$_remainingSeconds',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 21,
              ),
              textAlign: TextAlign.center,
            ),
            Column(
              children: List.generate(
                question.options.length,
                (index) {
                  return GestureDetector(
                    onTap: () => _pickAnswer(index),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: selectedAnswerIndex == index
                            ? Colors.blue.shade800
                            : null,
                      ),
                      child: Text(
                        question.options[index],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: 
                          FontWeight.w400,
                          color: selectedAnswerIndex == null
                              ? Colors.black
                              : selectedAnswerIndex == index
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            isLastQuestion
                ? RectangularButton(
                    onPressed: _goToResultScreen,
                    label: 'Finish',
                  )
                : RectangularButton(
                    onPressed: _goToNextQuestion,
                    label: 'Next',
                  ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: QuizScreen(),
  ));
}
