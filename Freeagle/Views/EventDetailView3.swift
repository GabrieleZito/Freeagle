import SwiftUI
import MapKit

struct EventDetailView3: View {
    @Environment(\.dismiss) private var dismiss
    @State private var inviteStatus: InviteStatus = .pending
    @State var event: Event
    var api = APIService()
    @State private var username = UserDefaults.standard.object(forKey: "username")!
    @State private var showAlreadyParticipatingAlert = false

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
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header fisso con immagine hero
                ZStack(alignment: .topLeading) {
                    Image(event.category)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: 300)
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
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                }
                .frame(width: geometry.size.width)
                
                // Informazioni evento fisse
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
                    
                    // Info cards
                    HStack(spacing: 12) {
                        InfoCard(
                            icon: "calendar",
                            title: "Date",
                            subtitle: formatDateString(event.start_local),
                            color: .blue
                        )
                    }
                    
                    Divider()
                        .padding(.vertical, 2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)
                .background(Color(.systemBackground))
                
                // ScrollView solo per i dettagli
                ScrollView {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Details")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                        if event.description.dropFirst(29).count > 2 {
                            Text(event.description)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                                .lineSpacing(4)
                        } else {
                            Text("No description available")
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                            handleSubmit(inviteCode: event.inviteCode!, username: username as! String, accepted: "false")
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
                            // Controlla se l'utente sta già partecipando all'evento
                            if isUserAlreadyParticipating() {
                                showAlreadyParticipatingAlert = true
                                return
                            }
                            
                            handleSubmit(inviteCode: event.inviteCode!, username: username as! String, accepted: "true")

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
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .alert("Already Participating", isPresented: $showAlreadyParticipatingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You are already participating in this event.")
        }
        .onAppear {
            // Controlla lo stato iniziale quando la view appare
            checkInitialParticipationStatus()
        }
        
    }
    
    // funzione per controllare se l'utente sta già partecipando
    func isUserAlreadyParticipating() -> Bool {
        var events: [Event] = []
        if let data = UserDefaults.standard.data(forKey: "userEvents") {
            do {
                events = try JSONDecoder().decode([Event].self, from: data)
            } catch {
                print("Error decoding events: \(error)")
                return false
            }
        }
        
        // Controlla se esiste già un evento con lo stesso inviteCode
        return events.contains { $0.inviteCode == event.inviteCode }
    }
    
    // Nuova funzione per controllare lo stato iniziale
    func checkInitialParticipationStatus() {
        if isUserAlreadyParticipating() {
            inviteStatus = .accepted
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
        outputFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        outputFormatter.locale = Locale(identifier: "en_US")
        
        return outputFormatter.string(from: date)
    }
    
    func handleSubmit(inviteCode: String, username: String, accepted: String){
        Task{
            do{
                let result = try await api.confirmEvent(inviteCode: inviteCode, username: username, confirmed: accepted)
                print(result)
                if result{
                    var events: [Event] = []
                    if let data = UserDefaults.standard.data(forKey: "userEvents") {
                        do {
                            events = try JSONDecoder().decode([Event].self, from: data)
                        } catch {
                            print("Error decoding events: \(error)")
                            events = []
                        }
                    }
                    
                    // Solo per accettazione, aggiungi l'evento se non esiste già
                    if accepted == "true" {
                        let existingEvent = events.first { $0.inviteCode == inviteCode }
                        if existingEvent == nil{
                            events.append(event)
                            
                            do {
                                let data = try JSONEncoder().encode(events)
                                UserDefaults.standard.set(data, forKey: "userEvents")
                                print("Successfully saved events to UserDefaults")
                                
                            } catch {
                                print("Error encoding events: \(error)")
                            }
                        }
                    } else {
                        // Per il rifiuto, rimuovi l'evento se esiste
                        events.removeAll { $0.inviteCode == inviteCode }
                        do {
                            let data = try JSONEncoder().encode(events)
                            UserDefaults.standard.set(data, forKey: "userEvents")
                            print("Successfully removed event from UserDefaults")
                        } catch {
                            print("Error encoding events: \(error)")
                        }
                    }
                    
                    dismiss()
                }else{
                    print("error")
                }
            }catch{
                print(error)
            }
        }
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
    
    func handleAddEvent() {
        let inviteCode = "\(event.id)-\(username)"
        
        // Get existing events from UserDefaults (decode from Data)
        var events: [Event] = []
        if let data = UserDefaults.standard.data(forKey: "userEvents") {
            do {
                events = try JSONDecoder().decode([Event].self, from: data)
            } catch {
                print("Error decoding events: \(error)")
                events = []
            }
        }
        //print(events)
        // Check if an event with this invite code already exists
        let existingEvent = events.first { $0.inviteCode == inviteCode }
        
        if existingEvent != nil {
            // Event already exists, just copy the invite code
            print("Event already exists, copied invite code: \(inviteCode)")
        } else {
            // Event doesn't exist, add it to the array
            event.inviteCode = inviteCode
            events.append(event)
            
            // Save to UserDefaults
            do {
                let data = try JSONEncoder().encode(events)
                UserDefaults.standard.set(data, forKey: "userEvents")
                print("Successfully saved events to UserDefaults")
                
            } catch {
                print("Error encoding events: \(error)")
            }
        }
    }
}
