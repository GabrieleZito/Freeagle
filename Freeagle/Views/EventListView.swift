import SwiftUI

struct EventListView: View {
    @State private var events: [Event] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedFilter = FilterType.all
    @State private var categoriesFilterActive = false
    @State private var showingCategoryFilter = false
    @State private var showingCalendarPicker = false
    @State private var selectedCategories: Set<EventCategory> = []
    @State private var selectedDate = Date()
    @State private var calendarFilterActive = false
    @State private var selectedTime = Date()
    @State private var showingEventDetail = false
    @State private var selectedEvent: Event?
    @State private var showEventDetail = false

    private let api = APIService()

    enum FilterType: String, CaseIterable {
        case all = "Tutti"
        case category = "Categoria"
        case nearby = "Vicini"
        case favorites = "Preferiti"
        case calendar = "Calendario"

        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .category: return "tag.fill"
            case .nearby: return "location.fill"
            case .favorites: return "heart.fill"
            case .calendar: return "calendar"
            }
        }
    }

    enum EventCategory: String, CaseIterable {
        case music = "Musica"
        case food = "Cibo e Bevande"
        case art = "Arte e Cultura"
        case sport = "Sport"
        case nightlife = "Vita Notturna"
        case business = "Business"
        case outdoor = "All'aperto"

        var icon: String {
            switch self {
            case .music: return "music.note"
            case .food: return "fork.knife"
            case .art: return "paintbrush.fill"
            case .sport: return "figure.run"
            case .nightlife: return "moon.stars.fill"
            case .business: return "briefcase.fill"
            case .outdoor: return "leaf.fill"
            }
        }

        var color: Color {
            switch self {
            case .music: return .purple
            case .food: return .orange
            case .art: return .pink
            case .sport: return .green
            case .nightlife: return .indigo
            case .business: return .blue
            case .outdoor: return .mint
            }
        }
    }

    var body: some View {
        NavigationView {
            mainBody
                .onAppear {
                    fetchEvents()
                    
                }
                .refreshable { fetchEvents() }
        }
    }

    private var mainBody: some View {
        VStack(spacing: 0) {
            // Header: Titolo + Filtri
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Events in Palermo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .animation(.easeInOut(duration: 0.3), value: selectedFilter)

                    Spacer()

                    Button(action: { showEventDetail = true }) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .scaleEffect(1.5)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            FilterButton(
                                filter: filter,
                                isSelected: getFilterSelectionState(filter)
                            ) {
                                handleFilterSelection(filter)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)

            // Contenuto: eventi, skeleton o errore
            ScrollView {
                if isLoading {
                    LazyVStack(spacing: 16) {
                        ForEach(0..<5, id: \.self) { _ in
                            SkeletonCardView()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                } else if let errorMessage = errorMessage {
                    VStack {
                        Text("Errore: \(errorMessage)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()

                        Button("Riprova") {
                            fetchEvents()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(events, id: \.id) { event in
                            Button(action: {
                                selectedEvent = event
                                // showingEventDetail = true
                            }) {
                                EventCard(event: event)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingCategoryFilter) {
            CategoryFilterView(selectedCategories: $selectedCategories) { hasSelection in
                categoriesFilterActive = hasSelection
            }
        }
        .sheet(isPresented: $showingCalendarPicker) {
            CalendarPickerView(selectedDate: $selectedDate) {
                selectedFilter = .calendar
                calendarFilterActive = true
            }
        }
    }

    private func fetchEvents() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                //let fetchedEvents = try await api.fetchEvents()
                let x = try await api.fetchEvents2()
                //print(x)
                await MainActor.run {
                    self.events = x.results
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    //self.isLoading = false
                }
            }
        }
    }

    private func getFilterSelectionState(_ filter: FilterType) -> Bool {
        switch filter {
        case .category:
            return categoriesFilterActive && !selectedCategories.isEmpty
        case .calendar:
            return calendarFilterActive
        default:
            return selectedFilter == filter && !categoriesFilterActive && !calendarFilterActive
        }
    }

    private func handleFilterSelection(_ filter: FilterType) {
        switch filter {
        case .category:
            showingCategoryFilter = true
        case .calendar:
            showingCalendarPicker = true
        default:
            selectedFilter = filter
            categoriesFilterActive = false
            calendarFilterActive = false
            selectedCategories.removeAll()
            selectedDate = Date()
        }
    }
}

#Preview {
    EventListView()
}
