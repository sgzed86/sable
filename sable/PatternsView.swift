import SwiftUI

struct Pattern: Identifiable {
    let id = UUID()
    var name: String
    var designer: String
    var location: String
    var details: String
}

struct PatternsView: View {
    @State private var patterns: [Pattern] = []
    @State private var showingAddPattern = false
    
    var body: some View {
        List {
            ForEach(patterns) { pattern in
                VStack(alignment: .leading, spacing: 8) {
                    Text(pattern.name)
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "person")
                        Text(pattern.designer)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "folder")
                        Text(pattern.location)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    if !pattern.details.isEmpty {
                        Text(pattern.details)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Patterns")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddPattern = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddPattern) {
            AddPatternView(patterns: $patterns)
        }
    }
}

struct AddPatternView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var patterns: [Pattern]
    @State private var name = ""
    @State private var designer = ""
    @State private var location = ""
    @State private var details = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pattern Information")) {
                    TextField("Pattern Name", text: $name)
                    TextField("Designer", text: $designer)
                    TextField("Location (e.g., Magazine, Book, Digital)", text: $location)
                }
                
                Section(header: Text("Additional Details")) {
                    TextEditor(text: $details)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Pattern")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    let newPattern = Pattern(
                        name: name,
                        designer: designer,
                        location: location,
                        details: details
                    )
                    patterns.append(newPattern)
                    dismiss()
                }
                .disabled(name.isEmpty || designer.isEmpty || location.isEmpty)
            )
        }
    }
}

#Preview {
    NavigationView {
        PatternsView()
    }
} 