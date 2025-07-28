import SwiftUI

struct EventDetailView2: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isDetailsExpanded = true
    @State var event: Event
    @State private var isFavorite: Bool = false
    @State var users: [User] = []
    var api = APIService()

    // Vista per ogni partecipante
    struct ParticipantRow: View {
        let participant: User
        
        var body: some View {
            HStack(spacing: 12) {
                
                // Informazioni utente
                HStack() {
                    Text(participant.username)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(participant.participate == "true" ? " joined the event": "")
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
            // Header fisso con immagine hero
            ZStack(alignment: .topLeading) {
                Image(event.category)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()
                    .padding(.horizontal, 40)
            }
            .ignoresSafeArea(edges: .top)
            
            // Informazioni evento fisse
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(event.title)
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                        Text(event.geo.address.formatted_address)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Info cards
                HStack(spacing:15) {
                    InfoCard(
                        icon: "calendar",
                        title: "Date",
                        subtitle: formatDateString(event.start_local),
                        color: .blue
                    )
                    
                    Spacer()
                    
                    // Cuoricino per i preferiti
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isFavorite.toggle()
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
            
            // ScrollView solo per i dettagli
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Sezione dettagli
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
                                    .rotationEffect(.degrees(isDetailsExpanded ? 0 : 0))
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
                    
                    // Sezione partecipanti
                    if users.count > 0{
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
                .padding(.top, 0)
                .padding(.bottom, 50)
            }
            .padding(.bottom, 10)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {dismiss()}) {
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
        }.onAppear{
            getUsers()
        }
        
        //.toolbar(.hidden, for: .tabBar)
    }
    private func getUsers() {
        print("CIAO")
        Task{
            do{
                let x = try await api.searchEvent(inviteCode: event.inviteCode!)
                print(x.users ?? [])
                users = x.users ?? []
            }
        }
    }
    func formatDateString(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US")
        
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString // Return original if parsing fails
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        outputFormatter.locale = Locale(identifier: "en_US")
        
        return outputFormatter.string(from: date)
    }
}

#Preview {
    EventDetailView2(event: Event(id: "", title: "", description: "", category: "", entities: [Entity(entity_id: "", name: "", type: "")], start_local: "", end_local: "", location: [1.0, 1.0], geo: Geo(address: Address(country_code: "", formatted_address: ""))))
}
