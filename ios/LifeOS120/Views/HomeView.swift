//
//  HomeView.swift
//  LifeOS-120
//
//  Home dashboard showing daily scores and trends
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = HomeViewModel()
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with greeting
                    headerSection

                    // Today's Score Card (Large)
                    todayScoreCard

                    // Quick Stats Row
                    quickStatsRow

                    // Trends Section
                    trendsSection

                    // Motivational Message
                    motivationalCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                            .font(.title3)
                    }
                }
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    viewModel.setup(userId: userId)
                }
            }
            .refreshable {
                await viewModel.fetchDashboardData()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.title3)
                    .foregroundStyle(.secondary)

                if let name = authViewModel.currentProfile?.fullName {
                    Text(name)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                } else {
                    Text("Welcome Back")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                }
            }
            Spacer()
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Today's Score Card

    private var todayScoreCard: some View {
        VStack(spacing: 16) {
            if let todayScore = viewModel.todayScore {
                VStack(spacing: 12) {
                    Text("Today's Score")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    // Large score circle
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                            .frame(width: 200, height: 200)

                        Circle()
                            .trim(from: 0, to: viewModel.completionPercentage)
                            .stroke(
                                scoreColor(for: todayScore.totalScore),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(), value: viewModel.completionPercentage)

                        VStack(spacing: 4) {
                            Text("\(todayScore.totalScore)")
                                .font(.system(size: 64, weight: .bold, design: .rounded))

                            Text(todayScore.rating)
                                .font(.title3)
                                .foregroundStyle(.secondary)

                            Text(todayScore.ratingEmoji)
                                .font(.system(size: 32))
                        }
                    }

                    // Change from yesterday
                    if let changeDesc = viewModel.scoreChangeDescription {
                        HStack(spacing: 4) {
                            Image(systemName: viewModel.scoreChange ?? 0 > 0 ? "arrow.up.circle.fill" : viewModel.scoreChange ?? 0 < 0 ? "arrow.down.circle.fill" : "minus.circle.fill")
                                .foregroundStyle(viewModel.scoreChange ?? 0 > 0 ? .green : viewModel.scoreChange ?? 0 < 0 ? .red : .gray)

                            Text(changeDesc)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                // No data today
                VStack(spacing: 16) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 64))
                        .foregroundStyle(.gray.opacity(0.5))

                    Text("No Data Yet")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Start tracking your health today!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button {
                        selectedTab = 1 // Switch to Track tab
                    } label: {
                        Text("Log Today's Data")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 32)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }

    // MARK: - Quick Stats Row

    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            // Yesterday's score
            if let yesterdayScore = viewModel.yesterdayScore {
                StatCard(
                    title: "Yesterday",
                    value: "\(yesterdayScore.totalScore)",
                    subtitle: yesterdayScore.rating,
                    icon: "calendar",
                    color: .orange
                )
            }

            // Current streak
            StatCard(
                title: "Streak",
                value: "\(viewModel.currentStreak)",
                subtitle: viewModel.currentStreak == 1 ? "day" : "days",
                icon: "flame.fill",
                color: .red
            )
        }
    }

    // MARK: - Trends Section

    private var trendsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Trends")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal, 4)

            VStack(spacing: 12) {
                // Weekly trend
                if let weeklyTrend = viewModel.weeklyTrend {
                    TrendCard(
                        title: "7-Day Average",
                        average: weeklyTrend.averageScore,
                        change: weeklyTrend.changeDescription,
                        isImproving: weeklyTrend.isImproving
                    )
                }

                // Monthly trend
                if let monthlyTrend = viewModel.monthlyTrend {
                    TrendCard(
                        title: "30-Day Average",
                        average: monthlyTrend.averageScore,
                        change: monthlyTrend.changeDescription,
                        isImproving: monthlyTrend.isImproving
                    )
                }
            }
        }
    }

    // MARK: - Motivational Card

    private var motivationalCard: some View {
        HStack {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(.yellow)

            Text(viewModel.motivationalMessage)
                .font(.headline)

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
    }

    // MARK: - Helpers

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    private func scoreColor(for score: Int) -> Color {
        switch score {
        case 90...100: return .green
        case 75...89: return .blue
        case 60...74: return .orange
        default: return .red
        }
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))

            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Trend Card Component

struct TrendCard: View {
    let title: String
    let average: Double
    let change: String
    let isImproving: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(String(format: "%.0f", average))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("avg")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(change)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isImproving ? .green : .secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
        .environmentObject(AuthViewModel())
}
