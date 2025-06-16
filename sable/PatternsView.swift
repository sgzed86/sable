import SwiftUI

struct Pattern: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var designer: String
    var location: String
    var details: String
    
    init(id: UUID = UUID(), name: String, designer: String, location: String, details: String) {
        self.id = id
        self.name = name
        self.designer = designer
        self.location = location
        self.details = details
    }
    
    static func == (lhs: Pattern, rhs: Pattern) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.designer == rhs.designer &&
        lhs.location == rhs.location &&
        lhs.details == rhs.details
    }
}

struct PatternsView: View {
    @AppStorage("patternData") private var patternData: Data = Data()
    @State private var patterns: [Pattern] = []
    @State private var showingAddPattern = false
    @State private var patternToEdit: Pattern?
    
    init() {
        // Try to load saved data
        if let savedPatterns = try? JSONDecoder().decode([Pattern].self, from: patternData) {
            _patterns = State(initialValue: savedPatterns)
        }
    }
    
    private func savePatternState() {
        if let encodedData = try? JSONEncoder().encode(patterns) {
            patternData = encodedData
        }
    }
    
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
                .contentShape(Rectangle())
                .onTapGesture {
                    patternToEdit = pattern
                }
            }
            .onDelete(perform: { indexSet in
                patterns.remove(atOffsets: indexSet)
                savePatternState()
            })
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
        .sheet(item: $patternToEdit) { pattern in
            EditPatternView(pattern: pattern) { updatedPattern in
                if let index = patterns.firstIndex(where: { $0.id == pattern.id }) {
                    patterns[index] = updatedPattern
                    savePatternState()
                }
            }
        }
        .onDisappear {
            savePatternState()
        }
        .onChange(of: patterns) { oldValue, newValue in
            savePatternState()
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

struct EditPatternView: View {
    @Environment(\.dismiss) var dismiss
    let pattern: Pattern
    let onUpdate: (Pattern) -> Void
    
    @State private var name: String
    @State private var designer: String
    @State private var location: String
    @State private var details: String
    
    init(pattern: Pattern, onUpdate: @escaping (Pattern) -> Void) {
        self.pattern = pattern
        self.onUpdate = onUpdate
        _name = State(initialValue: pattern.name)
        _designer = State(initialValue: pattern.designer)
        _location = State(initialValue: pattern.location)
        _details = State(initialValue: pattern.details)
    }
    
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
            .navigationTitle("Edit Pattern")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    let updatedPattern = Pattern(
                        id: pattern.id,
                        name: name,
                        designer: designer,
                        location: location,
                        details: details
                    )
                    onUpdate(updatedPattern)
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