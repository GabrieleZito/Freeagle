import SwiftUI
import UniformTypeIdentifiers

struct EventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isDetailsExpanded = true
    @State private var isFavorite: Bool = false
    @State private var showToast: Bool = false
    @State var event: Event
    @State private var username = UserDefaults.standard.object(forKey: "username")!
    let people = PeopleService()
    let api = APIService()
    
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
                
                // Info cards con cuoricino
                HStack(spacing:15) {
                    InfoCard(
                        icon: "calendar",
                        title: "Date",
                        subtitle: event.start_local,
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
                            }
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if isDetailsExpanded {
                            Text(event.description.dropFirst(29))
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                                .lineSpacing(4)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .top)),
                                    removal: .opacity.combined(with: .move(edge: .top))
                                ))
                        }
                    }
                    .padding(.horizontal, 16)
                }.padding(.bottom, 40)
                
                //MARK: DA TOGLIERE
                HStack{
                    Button(action: {
                        print("1")
                        let x = people.setPerson(person: Person(id: "999"))
                        print(x)
                    } ){
                        Image(systemName: "plus")
                    }
                    Button(action: {
                        print("2")
                        let y = people.getPerson(id: "999")
                        print(y ?? "persona boh")
                    } ){
                        Image(systemName: "plus.circle")
                    }
                }

            }
        }
        .toast(isShown: $showToast, message: "Invite Code Copied!")
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
            //Share Button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    handleAddEvent()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
        
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
            UIPasteboard.general.setValue(inviteCode, forPasteboardType: UTType.plainText.identifier)
            showToast.toggle()
            print("Event already exists, copied invite code: \(inviteCode)")
        } else {
            // Event doesn't exist, add it to the array
            event.inviteCode = inviteCode
            events.append(event)
            
            // Save back to UserDefaults (encode to Data)
            do {
                let data = try JSONEncoder().encode(events)
                UserDefaults.standard.set(data, forKey: "userEvents")
                print("Successfully saved events to UserDefaults")
                
            } catch {
                print("Error encoding events: \(error)")
            }
            Task{
                //print(event)
                try await api.newEvent(event: event)
            }
            
            // Copy invite code to clipboard
            UIPasteboard.general.setValue(inviteCode, forPasteboardType: UTType.plainText.identifier)
            showToast.toggle()
            
            print("Added new event with invite code: \(inviteCode)")
            print("Total events in UserDefaults: \(events.count)")
        }
    }
}


extension View {
    func toast(isShown: Binding<Bool>, title: String? = nil, message: String, icon: Image = Image(systemName: "exclamationmark.circle"), alignment: Alignment = .top) -> some View {
        
        ZStack {
            self
            Toast(isShown: isShown, title: title, message: message, icon: icon, alignment: alignment)
        }
    }
}
#Preview {
    EventDetailView(event: Event(id: "", title: "", description: "", category: "", entities: [Entity(entity_id: "", name: "", type: "")], start_local: "", end_local: "", location: [1.0, 1.0], geo: Geo(address: Address(country_code: "", formatted_address: ""))))
}

