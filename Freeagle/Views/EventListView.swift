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
    @State private var favoriteEventIds: Set<String> = []

    private let api = APIService()

    enum FilterType: String, CaseIterable {
        case all = "All"
        case category = "Categories"
        case nearby = "Nearby"
        case favorites = "Favorites"
        case calendar = "Calendar"

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
        case concert = "Concerts"
        case festival = "Festivals"
        case sport = "Sports"
        case community = "Communities"
        case expo = "Expos"
        case conference = "Conferences"
        case permformingArt = "Performing Arts"

        var icon: String {
            switch self {
            case .concert: return "music.note"
            case .festival: return "party.popper.fill"
            case .sport: return "soccerball"
            case .community: return "figure.2"
            case .expo: return "globe.europe.africa.fill"
            case .conference: return "briefcase.fill"
            case .permformingArt: return "theatermask.and.paintbrush.fill"
            }
        }

        var color: Color {
            switch self {
            case .concert: return .purple
            case .festival: return .orange
            case .sport: return .pink
            case .community: return .green
            case .expo: return .indigo
            case .conference: return .blue
            case .permformingArt: return .mint
            }
        }
    }

    private var filteredEvents: [Event] {
        // Filtra per preferiti
        if selectedFilter == .favorites {
            return events.filter { event in
                favoriteEventIds.contains(event.id)
            }
        }
        
        // Filtra per categorie
        guard categoriesFilterActive && !selectedCategories.isEmpty else {
            return events
        }
        
        return events.filter { event in
            // Corrispondenza esatta con rawValue
            if let eventCategory = EventCategory(rawValue: event.category) {
                return selectedCategories.contains(eventCategory)
            }
            
            // Corrispondenza case-insensitive
            let eventCategoryLower = event.category.lowercased()
            for selectedCategory in selectedCategories {
                if selectedCategory.rawValue.lowercased() == eventCategoryLower {
                    return true
                }
                
                // Keyword matching per categorie con nomi diversi
                switch selectedCategory {
                case .concert:
                    if eventCategoryLower.contains("music") || eventCategoryLower.contains("concert") {
                        return true
                    }
                case .festival:
                    if eventCategoryLower.contains("festival") || eventCategoryLower.contains("party") {
                        return true
                    }
                case .sport:
                    if eventCategoryLower.contains("sport") || eventCategoryLower.contains("game") {
                        return true
                    }
                case .community:
                    if eventCategoryLower.contains("community") || eventCategoryLower.contains("social") {
                        return true
                    }
                case .expo:
                    if eventCategoryLower.contains("expo") || eventCategoryLower.contains("exhibition") {
                        return true
                    }
                case .conference:
                    if eventCategoryLower.contains("conference") || eventCategoryLower.contains("meeting") {
                        return true
                    }
                case .permformingArt:
                    if eventCategoryLower.contains("art") || eventCategoryLower.contains("theater") || eventCategoryLower.contains("performance") {
                        return true
                    }
                }
            }
            
            return false
        }
    }

    var body: some View {
        NavigationView {
            mainBody
                .onAppear {
                    fetchEvents()
                    loadFavorites()
                }
                .refreshable {
                    fetchEvents()
                    loadFavorites()
                }
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

                    // Mostra il numero di eventi filtrati se ci sono filtri attivi
//                    if categoriesFilterActive && !selectedCategories.isEmpty {
//                        Text("\(filteredEvents.count) eventi")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                            .padding(.horizontal, 8)
//                            .padding(.vertical, 4)
//                            .background(Color.secondary.opacity(0.1))
//                            .clipShape(Capsule())
//                    }
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
                    .padding(.leading, 10)
                    .padding(.bottom, 10)
                }
                
                // Mostra le categorie selezionate se il filtro è attivo
                if categoriesFilterActive && !selectedCategories.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(selectedCategories), id: \.self) { category in
                                HStack(spacing: 4) {
                                    Image(systemName: category.icon)
                                        .font(.caption)
                                    Text(category.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(category.color.opacity(0.2))
                                .foregroundColor(category.color)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 20)
                    }.padding(.bottom, 10)
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
                    // Mostra messaggio se non ci sono eventi dopo il filtro
                    if filteredEvents.isEmpty && ((categoriesFilterActive && !selectedCategories.isEmpty) || selectedFilter == .favorites) {
                        VStack(spacing: 16) {
                            Image(systemName: selectedFilter == .favorites ? "heart" : "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            Text(selectedFilter == .favorites ? "Nessun preferito" : "Nessun evento trovato")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(selectedFilter == .favorites ? "Non hai ancora aggiunto eventi ai preferiti" : "Non ci sono eventi per le categorie selezionate")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Rimuovi filtri") {
                                selectedCategories.removeAll()
                                categoriesFilterActive = false
                                selectedFilter = .all
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredEvents.reversed()   , id: \.id) { event in
                                if compareEventDateWithToday(event.start_local) == .orderedDescending{
                                    Button(action: {
                                        selectedEvent = event
                                        // showingEventDetail = true
                                    }) {
                                        EventCard(event: event)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
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
    
    private func loadFavorites() {
        // Carica i preferiti dal UserDefaults o dal tuo sistema di persistenza
        if let favoritesData = UserDefaults.standard.data(forKey: "favoriteEvents"),
           let favorites = try? JSONDecoder().decode(Set<String>.self, from: favoritesData) {
            favoriteEventIds = favorites
        }
    }
    
    private func saveFavorites() {
        // Salva i preferiti nel UserDefaults o nel tuo sistema di persistenza
        if let encoded = try? JSONEncoder().encode(favoriteEventIds) {
            UserDefaults.standard.set(encoded, forKey: "favoriteEvents")
        }
    }
    
    func toggleFavorite(eventId: String) {
        if favoriteEventIds.contains(eventId) {
            favoriteEventIds.remove(eventId)
        } else {
            favoriteEventIds.insert(eventId)
        }
        saveFavorites()
    }
    
    func isFavorite(eventId: String) -> Bool {
        return favoriteEventIds.contains(eventId)
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
    
    func compareEventDateWithToday(_ eventDateString: String, today: Date = Date()) -> ComparisonResult {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let eventDate = formatter.date(from: eventDateString) else {
            return .orderedSame
        }
        
        return eventDate.compare(today)
    }
}

#Preview {
    EventListView()
}
