import SwiftUI
import MapKit
import UniformTypeIdentifiers


struct EventDetailView2: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isDetailsExpanded = true
    @State var event: Event
    @State private var isFavorite: Bool = false
    @State var users: [User] = []
    @State private var showToast: Bool = false

    var api = APIService()
    @State private var username = UserDefaults.standard.object(forKey: "username")!


    struct ParticipantRow: View {
        let participant: User
        
        var body: some View {
            HStack(spacing: 12) {
                HStack {
                    Text(participant.username)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(participant.participate == "true" ? " joined the event" : "")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                Image(event.category)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()
                    .padding(.horizontal, 40)
            }
            .ignoresSafeArea(edges: .top)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(event.title)
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .foregroundColor(.primary)
                    
                    Button(action: {
                        openInMaps()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                            Text(event.geo.address.formatted_address)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                                .underline()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                HStack(spacing: 15) {
                    InfoCard(
                        icon: "calendar",
                        title: "Date",
                        subtitle: formatDateString(event.start_local),
                        color: .blue
                    )
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            toggleFavorite()
                        }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(isFavorite ? .red : .secondary)
                            .scaleEffect(isFavorite ? 1.1 : 1.0)
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFavorite)
                    
                    Spacer()
                }
                
                Divider()
                    .padding(.vertical, 2)
            }
            .padding(.horizontal, 15)
            .padding(.top, 24)
            .padding(.bottom, 16)
            .background(Color(.systemBackground))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                isDetailsExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Text("Details")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: isDetailsExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if isDetailsExpanded {
                            Text(event.description)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                                .lineSpacing(4)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .top)),
                                    removal: .opacity.combined(with: .move(edge: .top))
                                ))
                        }
                    }

                    if users.count > 0 {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Participants")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(users.count) going")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                            
                            LazyVStack(spacing: 12) {
                                ForEach(users, id: \.username) { participant in
                                    ParticipantRow(participant: participant)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 50)
            }
            .padding(.bottom, 10)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
                
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    handleAddEvent()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
        .onAppear {
            getUsers()
            loadFavoriteStatus()
        }
        .toast(isShown: $showToast,
               message: "Invite code copied!",
               icon: Image(systemName: "doc.on.clipboard.fill"))
    }
    
    private func openInMaps() {
        let latitude = event.location[1]
        let longitude = event.location[0]
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = event.title
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    private func handleAddEvent(){
        let inviteCode = "\(event.id)-\(username)"
        UIPasteboard.general.setValue(inviteCode, forPasteboardType: UTType.plainText.identifier)
        
        // Show toast after copying to clipboard
        showToast = true
    }

    // MARK: - Funzioni per i Preferiti
    
    private func loadFavoriteStatus() {
        isFavorite = FavoritesManager.shared.isEventFavorite(eventID: event.id)
    }
    
    private func toggleFavorite() {
        isFavorite = FavoritesManager.shared.toggleFavorite(eventID: event.id)
    }

    // MARK: - Funzioni Utili
    
    private func getUsers() {
        Task {
            guard let inviteCode = event.inviteCode else {
                print("⚠️ Invite code is nil – cannot load users.")
                return
            }
            
            do {
                let x = try await api.searchEvent(inviteCode: inviteCode)
                print(x.users ?? [])
                users = x.users ?? []
            } catch {
                print("❌ Failed to fetch users: \(error)")
            }
        }
    }

    func formatDateString(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US")
        
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM dd, YYYY 'at' h:mm a"
        outputFormatter.locale = Locale(identifier: "en_US")
        
        return outputFormatter.string(from: date)
    }
}

#Preview {
    EventDetailView2(event: Event(
        inviteCode: "INV123",
        id: "1",
        title: "Sample Event",
        description: "This is a sample event description.",
        category: "sample-category-image",
        entities: [Entity(entity_id: "1", name: "Sample Org", type: "organization")],
        start_local: "2025-08-01T19:00:00",
        end_local: "2025-08-01T21:00:00",
        location: [45.0, 9.0],
        geo: Geo(address: Address(country_code: "IT", formatted_address: "Milan, Italy"))
    ))
}
