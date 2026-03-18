import SwiftUI

struct ItineraryView: View {
    let itinerary: Itinerary
    let onReset: () -> Void

    @State private var selectedDay = 0

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Header ────────────────────────────────────────────────
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(itinerary.location)
                            .font(.system(size: 30, weight: .bold, design: .serif))
                            .foregroundColor(.black)
                        HStack(spacing: 5) {
                            Image(systemName: "calendar")
                                .font(.system(size: 11))
                                .foregroundColor(.black.opacity(0.35))
                            Text("\(itinerary.days.count)-Day Itinerary")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.black.opacity(0.4))
                        }
                    }
                    Spacer()
                    Button(action: onReset) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.07))
                                .frame(width: 38, height: 38)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 16)

                // ── Day Pill Strip ─────────────────────────────────────────
                // Key fix: give the ScrollView a fixed height and use
                // GeometryReader-free layout so it doesn't collapse
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(itinerary.days) { day in
                            let isSelected = selectedDay == day.dayNumber - 1
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    selectedDay = day.dayNumber - 1
                                }
                            } label: {
                                VStack(spacing: 2) {
                                    Text("DAY")
                                        .font(.system(size: 8, weight: .bold))
                                        .kerning(1.2)
                                        .foregroundColor(isSelected ? .white.opacity(0.65) : .black.opacity(0.3))
                                    Text("\(day.dayNumber)")
                                        .font(.system(size: 24, weight: .bold, design: .serif))
                                        .foregroundColor(isSelected ? .white : .black)
                                }
                                .frame(width: 56, height: 62)
                                .background(isSelected ? Color.black : Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(
                                    color: isSelected ? .black.opacity(0.2) : .black.opacity(0.05),
                                    radius: isSelected ? 6 : 2,
                                    x: 0, y: isSelected ? 3 : 1
                                )
                            }
                            .buttonStyle(.plain)
                            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: selectedDay)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 6)
                }
                // Fixed height stops the ScrollView collapsing and
                // prevents the vertical parent from stealing the gesture
                .frame(height: 78)

                // Thin separator
                Rectangle()
                    .fill(Color.black.opacity(0.06))
                    .frame(height: 1)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 4)

                // ── Activities (vertical scroll) ───────────────────────────
                ScrollView(.vertical, showsIndicators: false) {
                    if selectedDay < itinerary.days.count {
                        let day = itinerary.days[selectedDay]
                        VStack(alignment: .leading, spacing: 0) {

                            VStack(alignment: .leading, spacing: 4) {
                                Text(day.title)
                                    .font(.system(size: 22, weight: .bold, design: .serif))
                                    .foregroundColor(.black)
                                Text("Day \(day.dayNumber) · \(day.activities.count) stops")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.black.opacity(0.3))
                                    .kerning(0.3)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .padding(.bottom, 20)

                            ForEach(Array(day.activities.enumerated()), id: \.element.id) { index, activity in
                                ActivityCard(
                                    activity: activity,
                                    index: index,
                                    isLast: index == day.activities.count - 1
                                )
                                .padding(.horizontal, 24)
                            }
                        }
                        .padding(.bottom, 48)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Activity Card

struct ActivityCard: View {
    let activity: Activity
    let index: Int
    let isLast: Bool

    private var accentColor: Color {
        let palette: [Color] = [
            Color(red: 0.95, green: 0.90, blue: 0.80),
            Color(red: 0.88, green: 0.93, blue: 0.88),
            Color(red: 0.88, green: 0.90, blue: 0.96),
            Color(red: 0.95, green: 0.88, blue: 0.92),
        ]
        return palette[index % palette.count]
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {

            // Timeline column
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 42, height: 42)
                    Text(activity.emoji)
                        .font(.system(size: 19))
                }
                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.black.opacity(0.1), Color.black.opacity(0.04)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 5)
                }
            }
            .frame(width: 42)

            // Text content
            VStack(alignment: .leading, spacing: 5) {
                if !activity.time.isEmpty {
                    Text(activity.time)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black.opacity(0.3))
                        .textCase(.uppercase)
                        .kerning(1.1)
                }
                Text(activity.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
                Text(activity.description)
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
            .padding(.top, 10)
            .padding(.bottom, isLast ? 0 : 28)

            Spacer(minLength: 0)
        }
    }
}
