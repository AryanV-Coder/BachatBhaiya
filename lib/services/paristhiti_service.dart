import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class ParisthitiQuestion {
  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final String speakerImagePath;

  ParisthitiQuestion({
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    required this.speakerImagePath,
  });
}

class ParisthitiService {
  final Random _random = Random();

  // List of possible characters from assets
  final List<String> _characters = [
    'assets/images/m1.png',
    'assets/images/m2.png',
    'assets/images/m3.png',
    'assets/images/m4.png',
    'assets/images/f1.png',
    'assets/images/f2.png',
    'assets/images/f3.png',
    'assets/images/g1.png',
    'assets/images/g2.png',
    'assets/images/g3.png',
    'assets/images/b1.png',
    'assets/images/b2.png',
    'assets/images/b3.png',
  ];

  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'question':
          'I received a call from someone claiming to be from the bank asking for my OTP to block a fraudulent transaction. What should I do?',
      'options': [
        'Give them the OTP immediately',
        'Disconnect the call and never share the OTP',
        'Share only the last 2 digits of the OTP',
        'Ask them to verify my account balance first',
      ],
      'correct_index': 1,
    },
    {
      'question':
          'According to RBI guidelines, what is the maximum liability of a customer if they report an unauthorized electronic banking transaction within 3 working days?',
      'options': [
        'Full amount of the transaction',
        'Zero liability',
        '50% of the transaction amount',
        'Maximum ₹10,000 liability',
      ],
      'correct_index': 1,
    },
    {
      'question':
          'Someone sent me a link on WhatsApp claiming I won a lottery and need to click it to claim ₹10,000. Is this safe?',
      'options': [
        'Yes, if the link looks like a bank website',
        'Yes, lotteries often notify winners on WhatsApp',
        'No, it is a phishing link to steal information',
        'Yes, but I should use a different phone',
      ],
      'correct_index': 2,
    },
    {
      'question':
          'Why is maintaining an Emergency Fund important for a farmer?',
      'options': [
        'To buy a new smartphone every year',
        'To cover unexpected expenses like crop failure or medical bills',
        'To instantly double the money in the stock market',
        'Because the bank requires it',
      ],
      'correct_index': 1,
    },
    {
      'question':
          'If a money lender offers a loan without any paperwork but at an interest rate of 5% per month, should I take it?',
      'options': [
        'Yes, because it requires no paperwork',
        'Yes, it is a very cheap loan',
        'No, 5% per month equates to 60% per year, which is a debt trap',
        'Yes, if I can pay it back next week',
      ],
      'correct_index': 2,
    },
    {
      'question':
          'Can a bank representative ask for your ATM PIN or CVV number?',
      'options': [
        'Yes, for security verification',
        'No, banks never ask for PIN or CVV',
        'Yes, if you are applying for a new loan',
        'Yes, if your ATM card is blocked',
      ],
      'correct_index': 1,
    },
  ];

  final List<Map<String, dynamic>> _situations = [
    {
      'situation':
          "While visiting the local market, Ramesh, a fellow farmer, offers to sell you cheap 'premium' seeds he got from a traveling salesman. He says there's no need for a receipt since it's a friend's deal. You notice the packaging looks slightly faded.",
      'questions': [
        {
          'question': 'What is your first reaction to Ramesh\'s offer?',
          'options': [
            'Buy them immediately; Ramesh is a friend',
            'Ask Ramesh where the salesman is from and if he has a bill',
            'Try to negotiate the price even lower',
            'Inform the authorities about suspicious activity',
          ],
          'correct_index': 1,
        },
        {
          'question':
              'Why is it risky to buy seeds without a proper bill/receipt?',
          'options': [
            'No way to claim compensation if they don\'t germinate',
            'The bill is only for taxes',
            'Bills are hard to store',
            'It\'s not risky if you trust the person',
          ],
          'correct_index': 0,
        },
        {
          'question':
              'If the seeds turn out to be fakes, where can you report this scam?',
          'options': [
            'Local police station',
            'District Consumer Forum',
            'Agricultural Department Officer',
            'All of the above',
          ],
          'correct_index': 3,
        },
        {
          'question':
              'What should you check on a seed packet for quality assurance?',
          'options': [
            'Only the flashy pictures',
            'Expiry date and Batch number',
            'ISI/Agmark/Department certification',
            'Both B and C',
          ],
          'correct_index': 3,
        },
        {
          'question':
              'Ramesh says he can get you a loan from the same salesman at 10% monthly interest. What is the annual interest rate?',
          'options': ['10%', '100%', '120%', '20%'],
          'correct_index': 2,
        },
      ],
    },
    // Add more situations as needed
  ];

  Future<ParisthitiQuestion> fetchQuizQuestion() async {
    // try to fetch from remote quiz service first
    try {
      final uri = Uri.parse('https://bachatbhaiya.onrender.com/quiz');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'role': 'student'}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> respJson = jsonDecode(response.body);
        if (respJson['status'] == 'success' &&
            respJson['data'] != null &&
            respJson['data']['questions'] is List) {
          final List<dynamic> questions = respJson['data']['questions'];
          if (questions.isNotEmpty) {
            final qData = questions[_random.nextInt(questions.length)]
                as Map<String, dynamic>;

            // convert choices map into ordered list A,B,C,D
            final Map<String, dynamic> choicesMap =
                Map<String, dynamic>.from(qData['choices'] ?? {});
            final List<String> opts = [];
            for (var letter in ['A', 'B', 'C', 'D']) {
              if (choicesMap.containsKey(letter)) {
                opts.add(choicesMap[letter].toString());
              }
            }
            int correctIdx =
                ['A', 'B', 'C', 'D'].indexOf(qData['correct_answer']);
            if (correctIdx < 0 || correctIdx >= opts.length) {
              correctIdx = 0;
            }

            final charPath =
                _characters[_random.nextInt(_characters.length)];

            return ParisthitiQuestion(
              text: qData['question_text'] as String,
              options: opts,
              correctOptionIndex: correctIdx,
              speakerImagePath: charPath,
            );
          }
        }
      }
    } catch (e) {
      // ignore network errors and fall back to local questions
      // print for debugging
      // ignore: avoid_print
      print('Quiz fetch failed: $e');
    }

    // Fallback to local in case of any problem
    await Future.delayed(const Duration(milliseconds: 1500));
    final qData = _quizQuestions[_random.nextInt(_quizQuestions.length)];
    final charPath = _characters[_random.nextInt(_characters.length)];
    return ParisthitiQuestion(
      text: qData['question'] as String,
      options: List<String>.from(qData['options']),
      correctOptionIndex: qData['correct_index'] as int,
      speakerImagePath: charPath,
    );
  }

  Future<String> fetchSituation() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return _situations[0]['situation']; // Defaulting to first for now
  }

  Future<List<ParisthitiQuestion>> fetchFollowUpQuestions(
    String situation,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    // Find matching situation or default
    final sitData = _situations.firstWhere(
      (s) => s['situation'] == situation,
      orElse: () => _situations[0],
    );

    final questions = (sitData['questions'] as List).map((q) {
      final charPath = _characters[_random.nextInt(_characters.length)];
      return ParisthitiQuestion(
        text: q['question'] as String,
        options: List<String>.from(q['options']),
        correctOptionIndex: q['correct_index'] as int,
        speakerImagePath: charPath,
      );
    }).toList();

    return questions;
  }

  Future<Map<String, String>> fetchSummary(int correctAnswers) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    String summary;
    String rbiGuideline;

    if (correctAnswers == 5) {
      summary =
          "Excellent! You have a perfect understanding of financial safety. You're well-equipped to protect your hard-earned money from scams.";
    } else if (correctAnswers >= 3) {
      summary =
          "Good job! You have a solid grasp of financial literacy, but there's still room to learn more about protecting yourself from digital frauds.";
    } else {
      summary =
          "It's important to be more cautious. Scammers are becoming very clever, and knowing the right guidelines is your best defense.";
    }

    rbiGuideline =
        "RBI Guideline: Never share your OTP, PIN, or CVV with anyone, including bank officials. If you face any unauthorized transaction, report it to your bank within 3 working days for zero liability. Helpline: 14448 (RBI Digital Payments).";

    return {'summary': summary, 'rbiGuideline': rbiGuideline};
  }
}
