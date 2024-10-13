//
//  TriviaQuestion.swift
//  Trivia Game
//
//  Created by Andress Vizcaino Seolin on 10/8/24.
//

import Foundation

// Model for each trivia question
struct TriviaQuestion: Codable, Identifiable {
    var id = UUID()
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    // Combine correct and incorrect answers for easier handling
    var allAnswers: [String] {
        return (incorrectAnswers + [correctAnswer]).shuffled()
    }

    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

// Model for response from the Open Trivia API
struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}
