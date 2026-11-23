import SwiftUI

public struct QuizView: View {
    @State private var currentQuestionIdx: Int = 0
    @State private var selectedOptionIdx: Int? = nil
    @State private var isSubmitted: Bool = false
    @State private var score: Int = 0
    @State private var showResults: Bool = false
    
    // Tracks history of answers: true = correct, false = wrong, nil = uncompleted
    @State private var answerHistory: [Bool?] = Array(repeating: nil, count: QuizDatabase.questions.count)
    
    public init() {}
    
    private var currentQuestion: QuizQuestion {
        QuizDatabase.questions[currentQuestionIdx]
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            // LEFT PANEL: Core Question Canvas
            VStack(alignment: .leading, spacing: 20) {
                // Header progress
                VStack(alignment: .leading, spacing: 6) {
                    Text("Memory & Pointer Quiz")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.green)
                    Text("Test Your Understanding")
                        .font(AppTheme.titleFont(size: 24))
                }
                
                Divider()
                
                if !showResults {
                    // Question Card
                    VStack(alignment: .leading, spacing: 16) {
                        // Question Counter & Progress Bar
                        HStack {
                            Text("QUESTION \(currentQuestionIdx + 1) OF \(QuizDatabase.questions.count)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        Text(currentQuestion.questionText)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                        
                        // Options List (Interactive buttons)
                        VStack(spacing: 10) {
                            ForEach(0..<currentQuestion.options.count, id: \.self) { idx in
                                Button(action: { selectOption(idx) }) {
                                    HStack {
                                        Text(optionPrefix(for: idx))
                                            .font(AppTheme.monoFont(size: 11))
                                            .bold()
                                            .foregroundColor(.secondary)
                                            .padding(.trailing, 6)
                                        
                                        Text(currentQuestion.options[idx])
                                            .font(.system(size: 13))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        // Dynamic correctness indicator symbols
                                        if isSubmitted {
                                            if idx == currentQuestion.correctOptionIndex {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            } else if idx == selectedOptionIdx {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        } else if selectedOptionIdx == idx {
                                            Image(systemName: "circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.system(size: 8))
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(.thinMaterial)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(optionBorderColor(for: idx), lineWidth: optionBorderWidth(for: idx))
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(isSubmitted)
                            }
                        }
                        
                        // Action buttons
                        HStack {
                            if !isSubmitted {
                                Button(action: submitAnswer) {
                                    Text("Submit Answer")
                                        .frame(width: 120, height: 24)
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(selectedOptionIdx == nil)
                                .tint(.blue)
                            } else {
                                Button(action: nextQuestion) {
                                    Text(currentQuestionIdx == QuizDatabase.questions.count - 1 ? "View Results" : "Next Question")
                                        .frame(width: 120, height: 24)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                            }
                        }
                        
                        // Explanations View (collapsible upon submission)
                        if isSubmitted {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("EXPLANATION")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.secondary)
                                Text(currentQuestion.explanation)
                                    .font(AppTheme.bodyFont(size: 12))
                                    .foregroundColor(.secondary)
                                    .lineSpacing(3)
                            }
                            .padding()
                            .background(Color.primary.opacity(0.03))
                            .cornerRadius(6)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                } else {
                    // Quiz results summary dashboard
                    VStack(alignment: .center, spacing: 20) {
                        Spacer()
                        
                        Image(systemName: score >= 4 ? "trophy.fill" : "chart.bar.doc.horizontal")
                            .font(.system(size: 50))
                            .foregroundColor(score >= 4 ? .yellow : .blue)
                        
                        Text("Quiz Completed!")
                            .font(AppTheme.titleFont(size: 24))
                        
                        // Score calculation ring
                        VStack(spacing: 4) {
                            Text("YOUR SCORE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.secondary)
                            Text("\(score) / \(QuizDatabase.questions.count)")
                                .font(AppTheme.titleFont(size: 32))
                                .foregroundColor(score >= 3 ? .green : .orange)
                            Text(scoreMessage())
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(width: 180)
                        .background(.thinMaterial)
                        .cornerRadius(12)
                        
                        Button(action: restartQuiz) {
                            Text("Restart Assessment")
                                .frame(width: 150, height: 24)
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            
            Divider()
            
            // RIGHT PANEL: Status checklist dashboard
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "checklist")
                        .foregroundColor(.secondary)
                    Text("Session Dashboard")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.primary.opacity(0.04))
                
                Divider()
                
                // Question Checklist
                VStack(alignment: .leading, spacing: 14) {
                    Text("QUESTIONS STATUS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(.top, 16)
                    
                    VStack(spacing: 8) {
                        ForEach(0..<QuizDatabase.questions.count, id: \.self) { idx in
                            HStack {
                                Text("Question \(idx + 1)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(idx == currentQuestionIdx && !showResults ? .primary : .secondary)
                                Spacer()
                                
                                if let historyState = answerHistory[idx] {
                                    Image(systemName: historyState ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(historyState ? .green : .red)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.secondary.opacity(0.5))
                                }
                            }
                            .padding(8)
                            .background(idx == currentQuestionIdx && !showResults ? Color.blue.opacity(0.08) : Color.clear)
                            .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .frame(width: 200)
            .background(Color.primary.opacity(0.01))
        }
    }
    
    // State management helpers
    private func selectOption(_ idx: Int) {
        selectedOptionIdx = idx
    }
    
    private func submitAnswer() {
        guard let selIdx = selectedOptionIdx else { return }
        
        withAnimation(.spring(response: 0.35)) {
            isSubmitted = true
            let isCorrect = selIdx == currentQuestion.correctOptionIndex
            answerHistory[currentQuestionIdx] = isCorrect
            
            if isCorrect {
                score += 1
            }
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIdx < QuizDatabase.questions.count - 1 {
            withAnimation(.spring(response: 0.35)) {
                currentQuestionIdx += 1
                selectedOptionIdx = nil
                isSubmitted = false
            }
        } else {
            withAnimation(.spring(response: 0.4)) {
                showResults = true
            }
        }
    }
    
    private func restartQuiz() {
        withAnimation(.spring(response: 0.4)) {
            currentQuestionIdx = 0
            selectedOptionIdx = nil
            isSubmitted = false
            score = 0
            showResults = false
            answerHistory = Array(repeating: nil, count: QuizDatabase.questions.count)
        }
    }
    
    // Style and naming helpers
    private func optionPrefix(for index: Int) -> String {
        ["A.", "B.", "C.", "D."][index]
    }
    
    private func optionBorderColor(for index: Int) -> Color {
        if isSubmitted {
            if index == currentQuestion.correctOptionIndex { return .green }
            if index == selectedOptionIdx { return .red }
            return Color.primary.opacity(0.08)
        }
        if selectedOptionIdx == index { return .blue }
        return Color.primary.opacity(0.08)
    }
    
    private func optionBorderWidth(for index: Int) -> CGFloat {
        if isSubmitted {
            if index == currentQuestion.correctOptionIndex || index == selectedOptionIdx { return 2 }
        }
        if selectedOptionIdx == index { return 2 }
        return 1
    }
    
    private func scoreMessage() -> String {
        let pct = Double(score) / Double(QuizDatabase.questions.count)
        if pct >= 0.8 { return "Outstanding! You're a pointer wizard." }
        if pct >= 0.6 { return "Good job! You've got the basics down." }
        return "Keep practicing! Memory management takes time."
    }
}

#if !os(Windows)
#Preview {
    QuizView()
}
#endif
