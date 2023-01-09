import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' show parse;


// Function to fetch the quiz questions from the API
Future<List<Question>> fetchQuestions() async {
  // Make the HTTP GET request to the API
  final response = await http.get(Uri.parse('https://opentdb.com/api.php?amount=50&category=9&type=boolean'));

  // Parse the JSON response
  final Map<String, dynamic> responseJson = json.decode(response.body);

  // Check the response code
  switch (responseJson['response_code']) {
    case 0:
    // Convert the response to a list of questions
      List<Question> questions = parseQuestions(response.body);
      return questions;
    case 1:
      throw Exception('No results');
    case 2:
      throw Exception('Invalid parameter');
    case 3:
      throw Exception('Token not found');
    case 4:
      throw Exception('Token empty');
    default:
      throw Exception('Unknown error');
  }
}

// Function to parse the JSON response and convert it to a list of questions
List<Question> parseQuestions(String responseBody) {
  // Parse the JSON response
  final parsed = json.decode(responseBody);

  // Get the list of results
  final questionsJson = parsed['results'] as List;

  // Convert the list of results to a list of questions
  return questionsJson.map<Question>((json) {
    // Decode the HTML encoding of the question and correct answer
    String question = parse(json['question'] as String).body!.text;
    bool correctAnswer = json['correct_answer'] == 'True';

    return Question(
      text: question,
      correctAnswer: correctAnswer,
    );
  }).toList();
}


// Class to represent a quiz question
class Question {
  final String text;
  final bool correctAnswer;

  Question({required this.text, required this.correctAnswer});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['question'],
      correctAnswer: json['correct_answer'] == 'True',
    );
  }
}
