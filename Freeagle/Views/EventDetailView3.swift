import SwiftUI

struct EventDetailView3: View {
    @Environment(\.dismiss) private var dismiss
    @State private var inviteStatus: InviteStatus = .pending
    @State var event: Event
    
    enum InviteStatus {
        case pending, accepted, declined
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
                Image("sport")
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
                }
                .padding(.top, 50)
                .padding(.horizontal, 40)
            }
            
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
                VStack(alignment: .leading, spacing: 10) {
                    Text("Details")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(event.description)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 20)
            }
            
            // Pulsanti per accettare/rifiutare invito
            VStack(spacing: 16) {
                // Status indicator se già risposto
                if inviteStatus != .pending {
                    HStack {
                        Image(systemName: inviteStatus == .accepted ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(inviteStatus == .accepted ? .green : .red)
                            .font(.system(size: 20))
                        
                        Text(inviteStatus == .accepted ? "Invitation Accepted" : "Invitation Declined")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(inviteStatus == .accepted ? .green : .red)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .transition(.opacity.combined(with: .scale))
                }
                
                HStack(spacing: 12) {
                    // Pulsante Rifiuta
                    Button(action: {
                        //print(event)
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            inviteStatus = .declined
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Decline")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(inviteStatus == .declined ? .white : .red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            inviteStatus == .declined ? .red : Color.red.opacity(0.1),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: inviteStatus == .declined ? 0 : 1.5)
                        )
                    }
                    .disabled(inviteStatus == .accepted)
                    .opacity(inviteStatus == .accepted ? 0.5 : 1.0)
                    
                    // Pulsante Accetta
                    Button(action: {
                        //print(event)
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            inviteStatus = .accepted
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Accept")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(inviteStatus == .accepted ? .white : .green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            inviteStatus == .accepted ? .green : Color.green.opacity(0.1),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green, lineWidth: inviteStatus == .accepted ? 0 : 1.5)
                        )
                    }
                    .disabled(inviteStatus == .declined)
                    .opacity(inviteStatus == .declined ? 0.5 : 1.0)
                }
                .padding(.horizontal, 20)
                
            }
            .padding(.bottom, 10)
            .padding(.top, 20)
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        
    }
}



//#Preview {
//    EventDetailView3()
//}
