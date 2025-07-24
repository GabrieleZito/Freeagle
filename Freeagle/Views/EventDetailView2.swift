import SwiftUI

struct EventDetailView2: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isDetailsExpanded = true
    
    // Modello per i partecipanti
    struct Participant {
        let id = UUID()
        let name: String
        let username: String
        let profileImage: String
        let isOnline: Bool
    }
    
    // Dati di esempio
    let sampleParticipants = [
        Participant(name: "Marco Rossi", username: "@marcorossi", profileImage: "person.circle.fill", isOnline: true),
        Participant(name: "Sofia Bianchi", username: "@sofiab", profileImage: "person.circle.fill", isOnline: true),
        Participant(name: "Luca Verdi", username: "@lucav", profileImage: "person.circle.fill", isOnline: false),
        Participant(name: "Anna Neri", username: "@annan", profileImage: "person.circle.fill", isOnline: true),
        Participant(name: "Giulio Romano", username: "@giulior", profileImage: "person.circle.fill", isOnline: false),
        Participant(name: "Elena Conte", username: "@elenac", profileImage: "person.circle.fill", isOnline: true),
        Participant(name: "Davide Moretti", username: "@davidem", profileImage: "person.circle.fill", isOnline: false),
        Participant(name: "Chiara Ferrari", username: "@chiaraf", profileImage: "person.circle.fill", isOnline: true)
    ]
    
    // Vista per ogni partecipante
    struct ParticipantRow: View {
        let participant: Participant
        
        var body: some View {
            HStack(spacing: 12) {
                // Avatar del partecipante
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: participant.profileImage)
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                        .frame(width: 50, height: 50)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                    
                    // Indicatore online
                    if participant.isOnline {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                }
                
                // Informazioni utente
                VStack(alignment: .leading, spacing: 2) {
                    Text(participant.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(participant.username)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Bottone messaggio
                Button(action: {}) {
                    Image(systemName: "message.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    struct InfoCard: View {
        let icon: String
        let title: String
        let subtitle: String
        let color: Color
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 16, weight: .semibold))
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header fisso con immagine hero
            ZStack(alignment: .topLeading) {
                Image("palermo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()

                
                // Back button personalizzato
                HStack {
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
                    
                    Spacer()
                    
                    // Share button
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal, 40)
            }
            
            // Informazioni evento fisse
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Event Name")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                        Text("Event Place")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Info cards
                HStack(spacing: 12) {
                    InfoCard(
                        icon: "calendar",
                        title: "Date",
                        subtitle: "Event Date",
                        color: .blue
                    )
                    
                    InfoCard(
                        icon: "creditcard",
                        title: "Price",
                        subtitle: "Event Price",
                        color: .green
                    )
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
                            Text("Lorem ipsum dolor sit amet. Qui minus explicabo ex ducimus mollitia aut praesentium culpa eos ipsa cupiditate et quod alias et corrupti asperiores hic esse aspernatur. Et voluptas quam aut voluptates rerum ut possimus repudiandae sed aliquid earum est labore commodi rem dolorem blanditiis. Sed nobis voluptates eum deserunt quae et esse velit eum placeat veritatis ut repellat numquam aut nobis labore. Eos culpa eveniet sed vitae galisum qui dolor dolorum aut perferendis adipisci et distinctio maxime ex praesentium maiores est tempora voluptatem? Quo aperiam maiores est natus ullam rem animi voluptate aut suscipit assumenda ea voluptatem dolor et voluptate maiores! Ad optio nihil rem corrupti rerum ut laudantium deleniti et magnam commodi..")
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
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Participants")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("12 going")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        LazyVStack(spacing: 12) {
                            ForEach(sampleParticipants, id: \.id) { participant in
                                ParticipantRow(participant: participant)
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
        .navigationBarHidden(true)
    }
}

#Preview {
    EventDetailView2()
}
