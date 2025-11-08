//
//  TodayView.swift
//  LifeOS-120
//
//  Today's dashboard for tracking daily health metrics
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = TodayViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with Date
                    VStack(spacing: 8) {
                        Text(Date(), style: .date)
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Text("Today's Progress")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                    }
                    .padding(.top)

                    // Water Intake Card
                    MetricCard(
                        title: "Hydration",
                        icon: "drop.fill",
                        color: .blue
                    ) {
                        VStack(spacing: 16) {
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("\(viewModel.waterMl)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                Text("ml")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }

                            HStack(spacing: 12) {
                                QuickAddButton(label: "+250ml") {
                                    viewModel.addWater(250)
                                }
                                QuickAddButton(label: "+500ml") {
                                    viewModel.addWater(500)
                                }
                                QuickAddButton(label: "+1L") {
                                    viewModel.addWater(1000)
                                }
                            }
                        }
                    }

                    // Exercise Card
                    MetricCard(
                        title: "Exercise",
                        icon: "figure.run",
                        color: .green
                    ) {
                        VStack(spacing: 16) {
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("\(viewModel.exerciseMinutes)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                Text("min")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }

                            HStack(spacing: 12) {
                                QuickAddButton(label: "+15min") {
                                    viewModel.addExercise(15)
                                }
                                QuickAddButton(label: "+30min") {
                                    viewModel.addExercise(30)
                                }
                                QuickAddButton(label: "+60min") {
                                    viewModel.addExercise(60)
                                }
                            }
                        }
                    }

                    // Mood Card
                    MetricCard(
                        title: "Mood",
                        icon: "heart.fill",
                        color: .pink
                    ) {
                        VStack(spacing: 16) {
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("\(viewModel.moodScore)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                Text("/ 10")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }

                            VStack(spacing: 8) {
                                Slider(value: Binding(
                                    get: { Double(viewModel.moodScore) },
                                    set: { viewModel.updateMood(Int($0)) }
                                ), in: 1...10, step: 1)
                                .tint(.pink)

                                HStack {
                                    Text("Low")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("High")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    // Gratitude Card
                    MetricCard(
                        title: "Gratitude",
                        icon: "sparkles",
                        color: .orange
                    ) {
                        VStack(spacing: 12) {
                            TextField(
                                "What are you grateful for today?",
                                text: $viewModel.gratitudeEntry,
                                axis: .vertical
                            )
                            .textFieldStyle(.plain)
                            .lineLimit(3...6)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)

                            Button("Save Gratitude") {
                                Task {
                                    await viewModel.saveEntry()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                            .disabled(viewModel.gratitudeEntry.isEmpty)
                        }
                    }

                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") {
                        Task {
                            await authViewModel.signOut()
                        }
                    }
                    .foregroundStyle(.red)
                }
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    viewModel.setup(userId: userId)
                }
            }
            .refreshable {
                await viewModel.fetchTodayEntry()
            }
        }
    }
}

// MARK: - Metric Card Component

struct MetricCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
            }

            // Content
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Quick Add Button

struct QuickAddButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(8)
        }
    }
}

#Preview {
    TodayView()
        .environmentObject(AuthViewModel())
}
