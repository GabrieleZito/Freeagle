import SwiftUI
import CoreLocation

struct EventListView: View {
    @State private var events: [Event] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedFilter = FilterType.all
    @State private var categoriesFilterActive = false
    @State private var showingCategoryFilter = false
    @State private var selectedCategories: Set<EventCategory> = []
    @State private var favoriteEventIDs: Set<String> = []
    @State private var selectedTime = Date()
    @State private var showingEventDetail = false
    @State private var selectedEvent: Event?
    @State private var showEventDetail = false

    private let api = APIService()

    enum FilterType: String, CaseIterable {
        case all = "All"
        case category = "Categories"
        case favorites = "Favorites"

        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .category: return "tag.fill"
            case .favorites: return "heart.fill"
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
        var eventsToFilter = events
        
        // Filtra per eventi preferiti
        if selectedFilter == .favorites {
            eventsToFilter = eventsToFilter.filter { favoriteEventIDs.contains($0.id) }
        }
        
        // Filtra per categorie
        if categoriesFilterActive && !selectedCategories.isEmpty {
            eventsToFilter = eventsToFilter.filter { event in
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
        
        return eventsToFilter
    }

    var body: some View {
        NavigationView {
            mainBody
                .onAppear {
                    fetchEvents()
                    loadFavorites() // Carica i preferiti all'avvio
                }
                .refreshable {
                    fetchEvents()
                    loadFavorites() // Ricarica anche i preferiti quando si fa refresh
                }
                // Ascolta per cambiamenti nei preferiti
                .onReceive(NotificationCenter.default.publisher(for: .favoritesChanged)) { _ in
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
                    if filteredEvents.isEmpty && (
                        (categoriesFilterActive && !selectedCategories.isEmpty) ||
                        selectedFilter == .favorites
                    ) {
                        VStack(spacing: 16) {
                            Image(systemName: getEmptyStateIcon())
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            
                            Text(getEmptyStateTitle())
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(getEmptyStateMessage())
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Remove Filters") {
                                resetAllFilters()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        LazyVStack(spacing: 16) {
                            if filteredEvents.count > 0{
                                ForEach(filteredEvents.reversed(), id: \.id) { event in
                                    if compareEventDateWithToday(event.start_local) == .orderedDescending || compareEventDateWithToday(event.start_local) == .orderedSame {
                                        Button(action: {
                                            selectedEvent = event
                                            // showingEventDetail = true
                                        }) {
                                            EventCard(event: event)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }else{
                                Text("There are no events for this category")
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
    }

    private func fetchEvents() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let x = try await api.fetchEvents2()
                await MainActor.run {
                    self.events = x.results
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Funzioni per gestire i preferiti
    private func loadFavorites() {
        // Usa FavoritesManager per ottenere tutti gli ID degli eventi preferiti
        favoriteEventIDs = Set(FavoritesManager.shared.getAllFavoriteEventIDs())
    }

    private func getFilterSelectionState(_ filter: FilterType) -> Bool {
        switch filter {
        case .category:
            return categoriesFilterActive && !selectedCategories.isEmpty
        default:
            return selectedFilter == filter && !categoriesFilterActive
        }
    }

    private func handleFilterSelection(_ filter: FilterType) {
        switch filter {
        case .category:
            showingCategoryFilter = true
        case .favorites:
            // Ricarica i preferiti quando viene selezionato il filtro
            loadFavorites()
            selectedFilter = filter
            categoriesFilterActive = false
            selectedCategories.removeAll()
        default:
            selectedFilter = filter
            categoriesFilterActive = false
            selectedCategories.removeAll()
        }
    }

    private func getEmptyStateIcon() -> String {
        if selectedFilter == .favorites {
            return "heart.slash"
        } else {
            return "magnifyingglass"
        }
    }
    
    private func getEmptyStateTitle() -> String {
        if selectedFilter == .favorites {
            return "No favorite events"
        } else {
            return "No events found"
        }
    }
    
    private func getEmptyStateMessage() -> String {
        if selectedFilter == .favorites {
            return "You haven't added any events to your favorites yet. Tap the heart icon on events you like to see them here."
        } else {
            return "There are no events for the selected categories"
        }
    }
    
    private func resetAllFilters() {
        selectedCategories.removeAll()
        categoriesFilterActive = false
        selectedFilter = .all
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

// MARK: - Extension per NotificationCenter
extension Notification.Name {
    static let favoritesChanged = Notification.Name("favoritesChanged")
}

#Preview {
    EventListView()
}
