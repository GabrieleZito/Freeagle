import SwiftUI

struct EventListView: View {
    @State private var events: [Event] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let api = APIService()

    //private let eventService = eventService()
    
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
                            fetchEvents()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(events, id: \.id) { event in
                        // Customize this based on your Event model
                        VStack(alignment: .leading) {
                            Text(event.title)
                                .font(.headline)
                             
                            Text(event.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            
                        }
                    }
                }
            }
            .navigationTitle("Events")
            .onAppear {
                fetchEvents()
            }
            .refreshable {
                fetchEvents()
            }
        }
    }
    
    private func fetchEvents() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedEvents = try await api.fetchEvents()
                
                await MainActor.run {
                    self.events = fetchedEvents
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
#Preview {
    EventListView()
}



