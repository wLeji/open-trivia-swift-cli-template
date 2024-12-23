import Foundation

var nb_questions = 0
var category = 0
var difficulty = 0
var Type = 0
var apiURL = ""
var data: Data?
var questions: [String: Any] = [:]

struct TriviaQuestion: Decodable {
    let category: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

struct TriviaResponse: Decodable {
    let results: [TriviaQuestion]
}

func fetchTriviaQuestions(completion: @escaping ([TriviaQuestion]?) -> Void) {
    print("Generated URL: \(apiURL)")
    let urlString = apiURL
    guard let url = URL(string: urlString) else {
        print("Invalid URL.")
        completion(nil)
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Failed to fetch trivia questions: \(error)")
            completion(nil)
            return
        }

        guard let data = data else {
            print("No data received.")
            completion(nil)
            return
        }

        do {
            let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
            completion(decodedResponse.results)
        } catch {
            print("Failed to decode response: \(error)")
            completion(nil)
        }
    }.resume()
}

func presentQuestion(_ question: TriviaQuestion, questionIndex: Int, score: inout Int) {
    print("\nQuestion \(questionIndex + 1):")
    print("Category: \(question.category)")
    print("Difficulty: \(question.difficulty.capitalized)")
    print(question.question)

    let shuffledAnswers = ([question.correct_answer] + question.incorrect_answers).shuffled()
    for (index, answer) in shuffledAnswers.enumerated() {
        print("\(index + 1). \(answer)")
    }

    var userAnswer: Int? = nil
    while userAnswer == nil {
        print("Enter the number of your answer:", terminator: " ")
        if let input = readLine(), let answerIndex = Int(input), answerIndex > 0, answerIndex <= shuffledAnswers.count {
            userAnswer = answerIndex
        } else {
            print("Invalid input. Please try again.")
        }
    }

    if shuffledAnswers[userAnswer! - 1] == question.correct_answer {
        print("Correct! 🎉")
        score += 1
    } else {
        print("Wrong! The correct answer was: \(question.correct_answer)")
    }
}

func generateURL() {
    apiURL = "https://opentdb.com/api.php?amount=\(nb_questions)"
    if category != 0 {
        apiURL += "&category=\(category)"
    }
    if difficulty != 0 {
        apiURL += "&difficulty=\(difficulty == 1 ? "easy" : difficulty == 2 ? "medium" : "hard")"
    }
    if Type != 0 {
        apiURL += "&type=\(Type == 1 ? "multiple" : "boolean")"
    }
}

func Quiz_setting() {
    nb_questions = 0
    
    print("Quiz Setting")
    print("Select the number of questions:")
    print("1 - 10")
    if let input = readLine(), let numberOfQuestions = Int(input), numberOfQuestions >= 1 && numberOfQuestions <= 10 {
        print("You selected \(numberOfQuestions) questions.")
        nb_questions = numberOfQuestions
    } else {
        print("Invalid input. Please enter a number between 1 and 10.")
    }

    let categories: [String: Int] = [
        "Any categories": 0,
        "General Knowledge": 1,
        "Entertainment: Books": 2,
        "Entertainment: Film": 3,
        "Entertainment: Music": 4,
        "Entertainment: Musicals & Theatres": 5,
        "Entertainment: Television": 6,
        "Entertainment: Video Games": 7,
        "Entertainment: Board Games": 8,
        "Science & Nature": 9,
        "Science: Computers": 10,
        "Science: Mathematics": 11,
        "Mythology": 12,
        "Sports": 13,
        "Geography": 14,
        "History": 15,
        "Politics": 16,
        "Art": 17,
        "Celebrities": 18,
        "Animals": 19,
        "Vehicles": 20,
        "Entertainment: Comics": 21,
        "Science: Gadgets": 22,
        "Entertainment: Japanese Anime & Manga": 23,
        "Entertainment: Cartoon & Animations": 24
    ]

    for (categorie, value) in categories.sorted(by: { $0.value < $1.value }) {
        print("\(value) - \(categorie)")
    }

    print("Select a category:")
    if let input = readLine(), let selectedCategory = Int(input), selectedCategory >= 0 && selectedCategory <= 24 {
        let categoryName = categories.first { $0.value == selectedCategory }?.key ?? "Unknown"
        print("You selected the category: \(categoryName) (\(selectedCategory))")
        category = selectedCategory + 8
    } else {
        print("Invalid input. Please enter a number between 0 and 24.")
    }

    let difficulties: [String: Int] = [
        "Any difficulties": 0,
        "Easy": 1,
        "Medium": 2,
        "Hard": 3
    ]

    for (difficulty, value) in difficulties.sorted(by: { $0.value < $1.value }) {
        print("\(value) - \(difficulty)")
    }

    print("Select a difficulty:")
    if let input = readLine(), let selectedDifficulty = Int(input), selectedDifficulty >= 0 && selectedDifficulty <= 3 {
        let difficultyName = difficulties.first { $0.value == selectedDifficulty }?.key ?? "Unknown"
        print("You selected the difficulty: \(difficultyName) (\(selectedDifficulty))")
        difficulty = selectedDifficulty
    } else {
        print("Invalid input. Please enter a number between 0 and 3.")
    }
    
    let responseType: [String: Int] = [
        "Any Type": 0,
        "Multiple Choice": 1,
        "True/False": 2
    ]

    for (response, value) in responseType.sorted(by: { $0.value < $1.value }) {
        print("\(value) - \(response)")
    }

    print("Select a response type:")
    if let input = readLine(), let selectedResponseType = Int(input), selectedResponseType >= 0 && selectedResponseType <= 2 {
        let responseName = responseType.first { $0.value == selectedResponseType }?.key ?? "Unknown"
        print("You selected the response type: \(responseName) (\(selectedResponseType))")
        Type = selectedResponseType
    } else {
        print("Invalid input. Please enter a number between 0 and 2.")
    }

    print("Quiz Setting Done")
}

func main() {
    Quiz_setting()
    generateURL()
    print("Welcome to Open Trivia CLI!")

    fetchTriviaQuestions { questions in
        guard let questions = questions else {
            print("Failed to load trivia questions.")
            exit(1)
        }

        var score = 0

        for (index, question) in questions.enumerated() {
            presentQuestion(question, questionIndex: index, score: &score)
        }
        print("\nQuiz completed!")
        print("\nYour final score is \(score) out of \(questions.count).")
        exit(EXIT_SUCCESS)
    }

    dispatchMain()
}

main()
