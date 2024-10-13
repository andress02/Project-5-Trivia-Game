//
//  TriviaGameView.swift
//  Trivia Game
//
//  Created by Andress Vizcaino Seolin on 10/8/24.
//

import SwiftUI
import Combine

struct TriviaGameView: View {
    @State private var triviaQuestions: [TriviaQuestion] = []
    @State private var isLoading = true
    @State private var selectedAnswers: [UUID: String] = [:]  // Track user-selected answers
    @State private var showScoreAlert = false  // Track when to show the score
    @State private var score = 0  // User score
    @State private var timeRemaining = 600  // Timer set to 10 minutes (600 seconds)
    @State private var timerCancellable: Cancellable?

    var apiUrl: String

    var body: some View {
        VStack {
            // Display the timer at the top
            Text("Time remaining: \(timeRemaining)s")
                .font(.title2)
                .padding()

            if isLoading {
                ProgressView("Loading questions...")
                    .onAppear(perform: fetchTriviaQuestions)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(triviaQuestions) { question in
                            VStack(alignment: .leading) {
                                Text(question.question.decodedHTML)  // Display the trivia question
                                    .font(.headline)
                                    .padding(.bottom, 10)

                                // Show answer options with buttons
                                ForEach(question.allAnswers, id: \.self) { answer in
                                    Button(action: {
                                        selectedAnswers[question.id] = answer  // Save the selected answer
                                    }) {
                                        HStack {
                                            Text(answer.decodedHTML)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Spacer()
                                            if selectedAnswers[question.id] == answer {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 8)
                                                        .stroke(selectedAnswers[question.id] == answer ? Color.green : Color.gray, lineWidth: 2))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                    .padding()
                }

                Button(action: submitAnswers) {
                    Text("Submit")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .alert(isPresented: $showScoreAlert) {
                    Alert(title: Text("Score"), message: Text("You scored \(score) out of \(triviaQuestions.count)"), dismissButton: .default(Text("OK")))
                }
            }
        }
        .navigationTitle("Trivia Game")
        .onAppear {
            startTimer()  // Start the timer when the view appears
        }
        .onDisappear {
            stopTimer()  // Stop the timer if the view is dismissed
        }
    }

    // Start the countdown timer
    func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.submitAnswers()  // Auto-submit if time runs out
                }
            }
    }

    // Stop the timer when the view disappears or when needed
    func stopTimer() {
        timerCancellable?.cancel()
    }

    // Fetch trivia questions from the API
    func fetchTriviaQuestions() {
        guard let url = URL(string: apiUrl) else {
            print("Invalid URL.")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let data = data else {
                print("No data returned.")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                DispatchQueue.main.async {
                    self.triviaQuestions = decodedResponse.results
                    self.isLoading = false
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }

    // Submit the selected answers and calculate the score
    func submitAnswers() {
        stopTimer()  // Stop the timer when the user submits

        // Calculate the score by checking how many correct answers the user selected
        score = triviaQuestions.reduce(0) { result, question in
            let correct = question.correctAnswer
            let selected = selectedAnswers[question.id] ?? ""
            return result + (correct == selected ? 1 : 0)
        }

        // Show the score alert
        showScoreAlert = true
    }
}

// Place the simplified HTML decoding extension here:
extension String {
    var decodedHTML: String {
        let replacements: [String: String] = [
            "&quot;": "\"",
            "&apos;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&nbsp;": " "
        ]

        var result = self
        for (entity, replacement) in replacements {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }
        return result
    }
}
