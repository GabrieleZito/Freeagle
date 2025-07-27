//
//  AddEventCard.swift
//  Freeagle
//
//  Created by Gabriele Zito on 26/07/25.
//

import SwiftUI

struct AddEventCard: View {
    @State private var textInput = ""
    @Environment(\.dismiss) private var dismiss
    private var api = APIService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
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
                }
                
                // Continue Button
                Button(action: {
                    handleContinue()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(textInput.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(textInput.isEmpty)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func handleContinue() {
        print("Continue with: \(textInput)")
        Task{
            do{
                let result = try await api.searchEvent(inviteCode: textInput)
                print(result)
            }catch{
                print(error)
            }
        }
        dismiss()
    }
}

