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
                    Text("Select the categories to view")
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
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
