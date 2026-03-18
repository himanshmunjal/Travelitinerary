import SwiftUI

// MARK: - Popular Destination Model
struct PopularDestination: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let defaultRadius: Int
}

struct ContentView: View {
    @StateObject private var viewModel = ItineraryViewModel()

    @State private var locationText = ""
    @State private var radiusKm = 50
    @State private var numberOfDays = 3
    @State private var showItinerary = false

    let radiusOptions = [10, 25, 50, 100, 200]

    let popularDestinations: [PopularDestination] = [
        .init(name: "Paris",     emoji: "🗼", defaultRadius: 50),
        .init(name: "Tokyo",     emoji: "⛩️", defaultRadius: 25),
        .init(name: "Bali",      emoji: "🌴", defaultRadius: 50),
        .init(name: "New York",  emoji: "🗽", defaultRadius: 25),
        .init(name: "Rome",      emoji: "🏛️", defaultRadius: 50),
        .init(name: "Rajasthan", emoji: "🏜️", defaultRadius: 100),
        .init(name: "Barcelona", emoji: "🎨", defaultRadius: 25),
        .init(name: "Kyoto",     emoji: "🍵", defaultRadius: 50),
    ]

    var canGenerate: Bool {
        !locationText.trimmingCharacters(in: .whitespaces).isEmpty && !viewModel.isGenerating
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.97, green: 0.97, blue: 0.95)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        // ── Header ──────────────────────────────────────
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Plan Your")
                                .font(.system(size: 34, weight: .light, design: .serif))
                                .foregroundColor(.black.opacity(0.38))
                            Text("Journey")
                                .font(.system(size: 52, weight: .bold, design: .serif))
                                .foregroundColor(.black)
                        }
                        .padding(.top, 20)

                        // ── Location Input ───────────────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel(icon: "mappin.circle.fill", title: "Where to?")

                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.black.opacity(0.3))
                                    .font(.system(size: 15, weight: .medium))

                                TextField("City, region or country...", text: $locationText)
                                    .font(.system(size: 16))
                                    .autocorrectionDisabled()
                                    .submitLabel(.done)

                                if !locationText.isEmpty {
                                    Button { locationText = "" } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.black.opacity(0.2))
                                            .font(.system(size: 17))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 15)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)

                            // ── Popular Destinations ─────────────────────
                            VStack(alignment: .leading, spacing: 8) {
                                Text("POPULAR")
                                    .font(.system(size: 10, weight: .semibold))
                                    .kerning(1.4)
                                    .foregroundColor(.black.opacity(0.3))
                                    .padding(.leading, 2)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(popularDestinations) { dest in
                                            Button {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                    locationText = dest.name
                                                    radiusKm = dest.defaultRadius
                                                }
                                            } label: {
                                                HStack(spacing: 6) {
                                                    Text(dest.emoji)
                                                        .font(.system(size: 14))
                                                    Text(dest.name)
                                                        .font(.system(size: 13, weight: .medium))
                                                        .foregroundColor(locationText == dest.name
                                                            ? .white
                                                            : Color(red: 0.2, green: 0.2, blue: 0.2))
                                                }
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(
                                                    locationText == dest.name
                                                        ? Color.black
                                                        : Color.white
                                                )
                                                .clipShape(Capsule())
                                                .shadow(
                                                    color: locationText == dest.name
                                                        ? .black.opacity(0.18)
                                                        : .black.opacity(0.05),
                                                    radius: locationText == dest.name ? 6 : 3,
                                                    x: 0, y: 2
                                                )
                                            }
                                            .buttonStyle(.plain)
                                            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: locationText)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 2)
                                }
                            }
                        }

                        // ── Exploration Radius ───────────────────────────
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                SectionLabel(icon: "circle.dashed", title: "Radius")
                                Spacer()
                                Text("\(radiusKm) km from center")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.black.opacity(0.35))
                            }

                            HStack(spacing: 6) {
                                ForEach(radiusOptions, id: \.self) { option in
                                    Button { withAnimation(.spring(response: 0.2)) { radiusKm = option } } label: {
                                        Text("\(option)")
                                            .font(.system(size: 14, weight: radiusKm == option ? .bold : .regular))
                                            .foregroundColor(radiusKm == option ? .white : .black.opacity(0.6))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 11)
                                            .background(radiusKm == option ? Color.black : Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .shadow(
                                                color: radiusKm == option ? .black.opacity(0.2) : .black.opacity(0.04),
                                                radius: radiusKm == option ? 6 : 2, x: 0, y: 2
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .animation(.spring(response: 0.25), value: radiusKm)
                                }
                            }

                            // Visual radius hint
                            HStack(spacing: 0) {
                                ForEach(radiusOptions, id: \.self) { option in
                                    Rectangle()
                                        .fill(option <= radiusKm ? Color.black : Color.black.opacity(0.1))
                                        .frame(height: 2)
                                        .animation(.easeInOut(duration: 0.2), value: radiusKm)
                                    if option != radiusOptions.last {
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.horizontal, 2)
                        }

                        // ── Number of Days ───────────────────────────────
                        VStack(alignment: .leading, spacing: 12) {
                            SectionLabel(icon: "calendar", title: "Duration")

                            HStack(alignment: .center, spacing: 0) {
                                // Minus
                                Button {
                                    if numberOfDays > 1 {
                                        withAnimation(.spring(response: 0.2)) { numberOfDays -= 1 }
                                    }
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.system(size: 15, weight: .semibold))
                                        .frame(width: 48, height: 48)
                                        .foregroundColor(numberOfDays == 1 ? .black.opacity(0.2) : .black)
                                }
                                .disabled(numberOfDays == 1)

                                Spacer()

                                // Day count display
                                VStack(spacing: 0) {
                                    Text("\(numberOfDays)")
                                        .font(.system(size: 44, weight: .bold, design: .serif))
                                        .foregroundColor(.black)
                                        .contentTransition(.numericText())
                                        .animation(.spring(response: 0.3), value: numberOfDays)
                                    Text(numberOfDays == 1 ? "DAY" : "DAYS")
                                        .font(.system(size: 10, weight: .semibold))
                                        .kerning(1.4)
                                        .foregroundColor(.black.opacity(0.3))
                                }

                                Spacer()

                                // Plus
                                Button {
                                    if numberOfDays < 14 {
                                        withAnimation(.spring(response: 0.2)) { numberOfDays += 1 }
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 15, weight: .semibold))
                                        .frame(width: 48, height: 48)
                                        .background(numberOfDays < 14 ? Color.black : Color.black.opacity(0.12))
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                }
                                .disabled(numberOfDays == 14)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                        }

                        // ── Error Banner ─────────────────────────────────
                        if let error = viewModel.errorMessage {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 14))
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(red: 0.5, green: 0.25, blue: 0))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(14)
                            .background(Color.orange.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.2), lineWidth: 1))
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // ── Generate Button ──────────────────────────────
                        Button {
                            Task {
                                await viewModel.generateItinerary(
                                    location: locationText.trimmingCharacters(in: .whitespaces),
                                    radiusKm: radiusKm,
                                    days: numberOfDays
                                )
                                if viewModel.itinerary != nil { showItinerary = true }
                            }
                        } label: {
                            HStack(spacing: 10) {
                                if viewModel.isGenerating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.85)
                                    Text("Crafting your itinerary…")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                } else {
                                    Text("Generate Itinerary")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                canGenerate
                                    ? Color.black
                                    : Color.black.opacity(0.2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: canGenerate ? .black.opacity(0.25) : .clear,
                                    radius: 12, x: 0, y: 4)
                            .animation(.easeInOut(duration: 0.2), value: canGenerate)
                        }
                        .disabled(!canGenerate)
                        .padding(.bottom, 36)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationDestination(isPresented: $showItinerary) {
                if let itinerary = viewModel.itinerary {
                    ItineraryView(itinerary: itinerary) {
                        viewModel.reset()
                        showItinerary = false
                    }
                }
            }
        }
    }
}

// MARK: - Reusable Section Label
struct SectionLabel: View {
    let icon: String
    let title: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.black.opacity(0.45))
            .textCase(.uppercase)
            .kerning(1.0)
    }
}

#Preview{
    ContentView()
}
