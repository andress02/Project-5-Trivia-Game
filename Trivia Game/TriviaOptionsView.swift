//
//  TriviaOptionsView.swift
//  Trivia Game
//
//  Created by Andress Vizcaino Seolin on 10/8/24.
//

import SwiftUI

struct TriviaOptionsView: View {
    @State private var numberOfQuestions = 10
    @State private var selectedCategory = "General Knowledge"
    @State private var selectedDifficulty = "Easy"
    @State private var selectedType = "Multiple Choice"

    var body: some View {
        Form {
            // Number of questions
            Section(header: Text("Number of Questions")) {
                Stepper(value: $numberOfQuestions, in: 1...50) {
                    Text("\(numberOfQuestions)")
                }
            }

            // Category picker
            Section(header: Text("Category")) {
                Picker("Category", selection: $selectedCategory) {
                    Text("General Knowledge").tag("General Knowledge")
                    Text("Science").tag("Science")
                    Text("History").tag("History")
                    // Add other categories as needed
                }
            }

            // Difficulty picker
            Section(header: Text("Difficulty")) {
                Picker("Difficulty", selection: $selectedDifficulty) {
                    Text("Easy").tag("Easy")
                    Text("Medium").tag("Medium")
                    Text("Hard").tag("Hard")
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            // Question type picker
            Section(header: Text("Type")) {
                Picker("Type", selection: $selectedType) {
                    Text("Multiple Choice").tag("Multiple Choice")
                    Text("True or False").tag("True or False")
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            // Navigation link to TriviaGameView with a fixed API URL
            NavigationLink(destination: TriviaGameView(apiUrl: "https://opentdb.com/api.php?amount=10")) {
                Text("Start Trivia")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Trivia Options")
    }
}
