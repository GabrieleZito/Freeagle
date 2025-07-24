//
//  CategoryFilter.swift
//  Freeagle
//
//  Created by Gabriele Zito on 24/07/25.
//
import SwiftUI

struct CategoryFilterView: View {
    @Binding var selectedCategories: Set<EventListView.EventCategory>
    let onApply: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var tempSelectedCategories: Set<EventListView.EventCategory>
    
    init(selectedCategories: Binding<Set<EventListView.EventCategory>>, onApply: @escaping (Bool) -> Void) {
        self._selectedCategories = selectedCategories
        self.onApply = onApply
        self._tempSelectedCategories = State(initialValue: selectedCategories.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(EventListView.EventCategory.allCases, id: \.self) { category in
                        HStack {
                            HStack(spacing: 12) {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                    .frame(width: 24)
                                
                                Text(category.rawValue)
                                    .font(.body)
                            }
                            
                            Spacer()
                            
                            if tempSelectedCategories.contains(category) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if tempSelectedCategories.contains(category) {
                                tempSelectedCategories.remove(category)
                            } else {
                                tempSelectedCategories.insert(category)
                            }
                        }
                    }
                } header: {
                    Text("Seleziona le categorie da visualizzare")
                }
                
                Section {
                    Button(action: {
                        if tempSelectedCategories.count == EventListView.EventCategory.allCases.count {
                            tempSelectedCategories.removeAll()
                        } else {
                            tempSelectedCategories = Set(EventListView.EventCategory.allCases)
                        }
                    }) {
                        HStack {
                            Image(systemName: tempSelectedCategories.count == EventListView.EventCategory.allCases.count ? "checkmark.square.fill" : "square")
                                .foregroundColor(.blue)
                            Text(tempSelectedCategories.count == EventListView.EventCategory.allCases.count ? "Deseleziona tutto" : "Seleziona tutto")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Categorie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Applica") {
                        selectedCategories = tempSelectedCategories
                        let hasCustomSelection = tempSelectedCategories.count > 0
                        onApply(hasCustomSelection)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            // Reset delle categorie quando si riapre il filtro se un altro filtro era attivo
            tempSelectedCategories = selectedCategories
        }
    }
}
