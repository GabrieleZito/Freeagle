import SwiftUI

struct JoinedEventsListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var joinedEvents: [Event] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAddEvent = false
    
    private let api = APIService()
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading events...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            fetchJoinedEvents()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    mainBody
                }
            }
            .onAppear {
                fetchJoinedEvents()
            }
            .refreshable {
                fetchJoinedEvents()
            }
        }
    }
    
    private var mainBody: some View{
        VStack(spacing: 0) {
            // Header con titolo e profilo
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Groups")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .animation(.easeInOut(duration: 0.3))
                    
                    Spacer()
                    
                    Button(action: {showAddEvent.toggle()}) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .scaleEffect(1.5)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
            
            if joinedEvents.count > 0{
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(joinedEvents, id: \.id) { event in
                            NavigationLink(destination: EventDetailView2(event: event)) {
                                EventCardGroups(event: event)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }.refreshable {
                    fetchJoinedEvents()
                }
                //.navigationBarHidden(true)
            }else {
                Spacer()
                Text("You haven't joined any events yet")
                Spacer()
            }
            
            
            
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showAddEvent, content: {
            AddEventCard()
        })
    }
    
    func fetchJoinedEvents() {
        // Get events from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: "userEvents") else {
            // No data found
            joinedEvents = []
            //errorMessage = "No joined events found"
            return
        }
        
        do {
            // Decode the events from UserDefaults
            let events = try JSONDecoder().decode([Event].self, from: data)
            
            if events.isEmpty {
                joinedEvents = []
                //errorMessage = "No joined events found"
            } else {
                // Events found
                isLoading = false
                joinedEvents = events
                errorMessage = nil // Clear any previous error
                print("Successfully loaded \(events.count) joined events")
            }
            
        } catch {
            // Error decoding
            joinedEvents = []
            errorMessage = "Error loading joined events: \(error.localizedDescription)"
            print("Error decoding joined events: \(error)")
        }
    }
}

#Preview {
    JoinedEventsListView()
}
