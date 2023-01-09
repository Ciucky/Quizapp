import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:quizzapp/api.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatefulWidget {
  @override
  _QuizAppState createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  // List to hold the quiz questions
  late List<Question> _questions;

  // Index of the current question
  int _currentQuestionIndex = 0;

  // Number of correct answers
  int _numCorrect = 0;

  // Flag to show whether the quiz has been completed
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();

    // Fetch the quiz questions from the API
    fetchQuestions().then((questions) {
      setState(() {
        _questions = questions;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Quiz App'),
        ),
        body: _questions == null
            ? Center(
          child: CircularProgressIndicator(),
        )
            : _isCompleted
            ? _buildQuizCompleted()
            : _buildQuiz(),
      ),
    );
  }

  Widget _buildQuiz() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display the current question
            Text(
              _questions[_currentQuestionIndex].text,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Display the true/false buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  child: Text(
                    'True',
                    style: TextStyle(fontSize: 30),
                  ),
                  onPressed: () {
                    _checkAnswer(true);
                  },
                ),
                SizedBox(width: 25),
                TextButton(
                  child: Text(
                    'False',
                    style: TextStyle(fontSize: 30),
                  ),
                  onPressed: () {
                    _checkAnswer(false);
                  },
                ),
              ],
            ),
            SizedBox(height: 25),
            // Display the number of correct answers
            Text('$_numCorrect out of 50', style: TextStyle(fontSize: 20)),
            SizedBox(height: 25),
            // Add a text to show how many questions are left
            Text(
              '${_questions.length - _currentQuestionIndex - 1} questions left',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 25),
            // Add a refresh button
            TextButton(
              child: Text('Refresh', style: TextStyle(fontSize: 20)),
              onPressed: () {
                // Reset the quiz
                setState(() {
                  _currentQuestionIndex = 0;
                  _numCorrect = 0;
                  _isCompleted = false;
                });
                // Fetch new questions from the API
                fetchQuestions();
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildQuizCompleted() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'You got $_numCorrect out of ${_questions.length} correct',
            style: TextStyle(fontSize: 24),
          ),
          // Add a button to start a new quiz
          TextButton(
            child: Text('Start a new quiz'),
            onPressed: () {
              // Reset the quiz
              setState(() {
                _currentQuestionIndex = 0;
                _numCorrect = 0;
                _isCompleted = false;
              });
              // Fetch new questions from the API
              fetchQuestions();
            },
          ),
        ],
      ),
    );
  }

  // Function to check the answer and show a dialog
  void _checkAnswer(bool userAnswer) {
    // Check if the answer is correct
    bool isCorrect = _questions[_currentQuestionIndex].correctAnswer ==
        userAnswer;

    // Show a notification
    Flushbar(
      title: isCorrect ? 'Correct' : 'Incorrect',
      message: 'You answered ${isCorrect ? 'correctly' : 'incorrectly'}.',
      duration: Duration(seconds: 3),
    )
      ..show(context);

    // Update the state
    setState(() {
      _currentQuestionIndex++;
      if (isCorrect) {
        _numCorrect++;
      }
      if (_currentQuestionIndex >= _questions.length) {
        _isCompleted = true;
      }
    });
  }
}

