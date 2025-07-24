//
//  CalendarPicker.swift
//  Freeagle
//
//  Created by Gabriele Zito on 24/07/25.
//
import SwiftUI

struct CalendarPickerView: View {
    @Binding var selectedDate: Date
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Picker data
                VStack(alignment: .leading, spacing: 12) {
                    DatePicker(
                        "Data evento",
                        selection: $selectedDate,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationTitle("Filtra per Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Applica") {
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
