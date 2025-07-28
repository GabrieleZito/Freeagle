import SwiftUI

struct AddEventCard: View {
    @State private var textInput = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var foundEvent: Event?
    @State private var showEventDetail = false
    
    @Environment(\.dismiss) private var dismiss
    private var api = APIService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    HStack{
                        Spacer()
                        Button(action: {
                            dismiss()
                        }){
                            Image(systemName: "x.circle")
                        }
                        
                    }
                    Text("Enter Invite Code")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Please provide the invite code to continue")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Text Field
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Enter code here...", text: $textInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                        .disabled(isLoading)
                }
                
                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                // Continue Button
                Button(action: {
                    handleContinue()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isLoading ? "Searching..." : "Continue")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background((textInput.isEmpty || isLoading) ? Color.gray : Color.blue)
                    .cornerRadius(10)
                }
                .disabled(textInput.isEmpty || isLoading)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationBarTitleDisplayMode(.inline)
            //            .toolbar {
            //                ToolbarItem(placement: .navigationBarTrailing) {
            //                    Button("Close") {
            //                        dismiss()
            //                    }
            //                    .disabled(isLoading)
            //                }
            //            }
        }
        .sheet(isPresented: $showEventDetail) {
            // Replace EventDetailView with your actual detail view
            if let event = foundEvent {
                EventDetailView3(event: event)
            }
        }
    }
    
    private func handleContinue() {
        print("Continue with: \(textInput)")
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await api.searchEvent(inviteCode: textInput)
                print(result)
                await MainActor.run {
                    isLoading = false
                    foundEvent = result
                    showEventDetail = true
                    // Don't dismiss immediately - let user see the detail view first
                }
            } catch {
                print(error)
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to find event. Please check your invite code."
                }
            }
        }
    }
}
