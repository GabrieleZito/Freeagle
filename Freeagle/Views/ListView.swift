import SwiftUI

struct Photo: Identifiable {
    var id = UUID()
    var title: String
    var file: String
    var multiplyRed = 1.0
    var multiplyGreen = 1.0
    var multiplyBlue = 1.0
    var saturation: Double?
    var contrast: Double?
}

struct ListView: View {
    @State var photos = [
        Photo(title: "Event 1 in Piazza Maggione", file: "bari"),
        Photo(title: "Event 2 in via Candelai", file: "firenze"),
        Photo(title: "Event 3 in via Roma", file: "genova"),
        Photo(title: "Event 4 in cattedrale", file: "napoli"),
        Photo(title: "Aperitivo free in Nautoscopio", file: "palermo")
    ]
    
    @State private var selectedTab = 0
    @State private var selectedFilter = FilterType.all
    @State private var showingProfile = false
    @State private var showingCategoryFilter = false
    @State private var showingCalendarPicker = false
    @State private var selectedCategories: Set<EventCategory> = [] // Deselezionate di default
    @State private var selectedDate = Date()
    @State private var calendarFilterActive = false
    @State private var selectedTime = Date()
    @State private var categoriesFilterActive = false
    @State private var showingEventDetail = false
    @State private var selectedPhoto: Photo?
    
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
        VStack(spacing: 0) {
            // Header con titolo e profilo
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(selectedTab == 0 ? "Events in Palermo" : "Groups")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    
                    Spacer()
                    
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .scaleEffect(1.5)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Filtri (solo per Events)
                if selectedTab == 0 {
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
                        .padding(.horizontal, 20)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
            
            // Contenuto principale
            if selectedTab == 0 {
                eventsView
            } else {
                groupsView
            }
            
            // Tab selector spostato in basso
            HStack(spacing: 0) {
                TabButton(title: "Events", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                TabButton(title: "Groups", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
        .sheet(isPresented: $showingCategoryFilter) {
            CategoryFilterView(selectedCategories: $selectedCategories) { hasSelection in
                categoriesFilterActive = hasSelection
                if hasSelection {
                    selectedFilter = .category
                } else {
                    selectedFilter = .all
                }
            }
        }
        .sheet(isPresented: $showingCalendarPicker) { // Calendario a mezzo schermo
            CalendarPickerView(selectedDate: $selectedDate) {
                selectedFilter = .calendar
                calendarFilterActive = true
            }
        }
        .fullScreenCover(isPresented: $showingEventDetail) { // Eventi a schermo intero
            if let photo = selectedPhoto {
                EventDetailView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
    }
    
    // Gestione selezione filtri
    private func handleFilterSelection(_ filter: FilterType) {
        switch filter {
        case .category:
            showingCategoryFilter = true
        case .calendar:
            showingCalendarPicker = true
        default:
            selectedFilter = filter
            categoriesFilterActive = false // Reset filtro categorie quando si seleziona altro
            calendarFilterActive = false // Reset filtro calendario quando si seleziona altro
            // Reset selezioni specifiche quando si cambia filtro
            if filter != .category {
                selectedCategories.removeAll()
            }
            if filter != .calendar {
                selectedDate = Date() // Reset data quando si cambia filtro
            }
        }
    }
    
    // Stato selezione filtri
    private func getFilterSelectionState(_ filter: FilterType) -> Bool {
        switch filter {
        case .category:
            return categoriesFilterActive && selectedCategories.count > 0
        case .calendar:
            return calendarFilterActive
        default:
            return selectedFilter == filter && !categoriesFilterActive && !calendarFilterActive
        }
    }
    
    // Vista degli eventi
    private var eventsView: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(photos, id: \.id) { photo in
                        Button(action: {
                            selectedPhoto = photo
                            showingEventDetail = true
                        }) {
                            EventCard(photo: photo)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .navigationBarHidden(true)
        }
    }
    
    // Vista dei gruppi (placeholder)
    private var groupsView: some View {
        VStack {
            Spacer()
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding(.bottom, 16)
            
            Text("Groups")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Coming soon...")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// Vista per il picker calendario - MODIFICATA per mostrare solo la data
struct CalendarPickerView: View {
    @Binding var selectedDate: Date
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Picker data
                VStack(alignment: .leading, spacing: 12) {
                    DatePicker(
                        "Data evento",
                        selection: $selectedDate,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationTitle("Filtra per Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Applica") {
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// Componente per la vista categoria filtri
struct CategoryFilterView: View {
    @Binding var selectedCategories: Set<ListView.EventCategory>
    let onApply: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var tempSelectedCategories: Set<ListView.EventCategory>
    
    init(selectedCategories: Binding<Set<ListView.EventCategory>>, onApply: @escaping (Bool) -> Void) {
        self._selectedCategories = selectedCategories
        self.onApply = onApply
        self._tempSelectedCategories = State(initialValue: selectedCategories.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(ListView.EventCategory.allCases, id: \.self) { category in
                        HStack {
                            HStack(spacing: 12) {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                    .frame(width: 24)
                                
                                Text(category.rawValue)
                                    .font(.body)
                            }
                            
                            Spacer()
                            
                            if tempSelectedCategories.contains(category) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if tempSelectedCategories.contains(category) {
                                tempSelectedCategories.remove(category)
                            } else {
                                tempSelectedCategories.insert(category)
                            }
                        }
                    }
                } header: {
                    Text("Seleziona le categorie da visualizzare")
                }
                
                Section {
                    Button(action: {
                        if tempSelectedCategories.count == ListView.EventCategory.allCases.count {
                            tempSelectedCategories.removeAll()
                        } else {
                            tempSelectedCategories = Set(ListView.EventCategory.allCases)
                        }
                    }) {
                        HStack {
                            Image(systemName: tempSelectedCategories.count == ListView.EventCategory.allCases.count ? "checkmark.square.fill" : "square")
                                .foregroundColor(.blue)
                            Text(tempSelectedCategories.count == ListView.EventCategory.allCases.count ? "Deseleziona tutto" : "Seleziona tutto")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Categorie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Applica") {
                        selectedCategories = tempSelectedCategories
                        let hasCustomSelection = tempSelectedCategories.count > 0
                        onApply(hasCustomSelection)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            // Reset delle categorie quando si riapre il filtro se un altro filtro era attivo
            tempSelectedCategories = selectedCategories
        }
    }
}

// Vista profilo placeholder
struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Avatar
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("Mario Rossi")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("mario.rossi@email.com")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 16) {
                    ProfileMenuItem(icon: "person.fill", title: "Modifica Profilo")
                    ProfileMenuItem(icon: "heart.fill", title: "Eventi Preferiti")
                    ProfileMenuItem(icon: "calendar", title: "I Miei Eventi")
                    ProfileMenuItem(icon: "gear", title: "Impostazioni")
                }
                .padding(.top, 24)
                
                Spacer()
                
                Button("Logout") {
                    // Azione logout
                }
                .foregroundColor(.red)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
            .navigationTitle("Profilo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Componente menu item profilo
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            // Azione per navigare alla sezione specifica
        }
    }
}

// Componente per i pulsanti filtro
struct FilterButton: View {
    let filter: ListView.FilterType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.caption)
                
                Text(filter.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// Componente per i pulsanti tab
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 3)
                    .animation(.easeInOut(duration: 0.3), value: isSelected)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

// Componente card per gli eventi
struct EventCard: View {
    let photo: Photo
    
    var body: some View {
        HStack(spacing: 16) {
            // Immagine con shadow e corner radius
            Image(photo.file)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 90)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Contenuto testuale
            VStack(alignment: .leading, spacing: 8) {
                Text(photo.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("Palermo, Sicily")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Spacer()
            
            // Freccia indicatore
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    ListView()
}
