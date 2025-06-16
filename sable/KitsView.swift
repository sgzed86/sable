import SwiftUI

struct Kit: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var size: String
    var estimatedTime: String
    var details: String
    
    init(id: UUID = UUID(), name: String, size: String, estimatedTime: String, details: String) {
        self.id = id
        self.name = name
        self.size = size
        self.estimatedTime = estimatedTime
        self.details = details
    }
    
    static func == (lhs: Kit, rhs: Kit) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.size == rhs.size &&
        lhs.estimatedTime == rhs.estimatedTime &&
        lhs.details == rhs.details
    }
}

struct KitsView: View {
    @AppStorage("kitData") private var kitData: Data = Data()
    @State private var kits: [Kit] = []
    @State private var showingAddKit = false
    @State private var kitToEdit: Kit?
    
    init() {
        // Try to load saved data
        if let savedKits = try? JSONDecoder().decode([Kit].self, from: kitData) {
            _kits = State(initialValue: savedKits)
        }
    }
    
    private func saveKitState() {
        if let encodedData = try? JSONEncoder().encode(kits) {
            kitData = encodedData
        }
    }
    
    var body: some View {
        List {
            ForEach(kits) { kit in
                VStack(alignment: .leading, spacing: 8) {
                    Text(kit.name)
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "ruler")
                        Text(kit.size)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "clock")
                        Text("Est. Time: \(kit.estimatedTime)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    if !kit.details.isEmpty {
                        Text(kit.details)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    kitToEdit = kit
                }
            }
            .onDelete { indexSet in
                kits.remove(atOffsets: indexSet)
                saveKitState()
            }
        }
        .navigationTitle("Kits")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddKit = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddKit) {
            AddKitView(kits: $kits)
        }
        .sheet(item: $kitToEdit) { kit in
            EditKitView(kit: kit) { updatedKit in
                if let index = kits.firstIndex(where: { $0.id == kit.id }) {
                    kits[index] = updatedKit
                    saveKitState()
                }
            }
        }
        .onDisappear {
            saveKitState()
        }
        .onChange(of: kits) { oldValue, newValue in
            saveKitState()
        }
    }
}

struct AddKitView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var kits: [Kit]
    @State private var name = ""
    @State private var size = ""
    @State private var estimatedTime = ""
    @State private var details = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kit Information")) {
                    TextField("Name", text: $name)
                    TextField("Size (e.g., 8x10 inches)", text: $size)
                    TextField("Estimated Time (e.g., 20 hours)", text: $estimatedTime)
                }
                
                Section(header: Text("Additional Details")) {
                    TextEditor(text: $details)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Kit")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    let newKit = Kit(
                        name: name,
                        size: size,
                        estimatedTime: estimatedTime,
                        details: details
                    )
                    kits.append(newKit)
                    dismiss()
                }
                .disabled(name.isEmpty || size.isEmpty || estimatedTime.isEmpty)
            )
        }
    }
}

struct EditKitView: View {
    @Environment(\.dismiss) var dismiss
    let kit: Kit
    let onUpdate: (Kit) -> Void
    
    @State private var name: String
    @State private var size: String
    @State private var estimatedTime: String
    @State private var details: String
    
    init(kit: Kit, onUpdate: @escaping (Kit) -> Void) {
        self.kit = kit
        self.onUpdate = onUpdate
        _name = State(initialValue: kit.name)
        _size = State(initialValue: kit.size)
        _estimatedTime = State(initialValue: kit.estimatedTime)
        _details = State(initialValue: kit.details)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kit Information")) {
                    TextField("Name", text: $name)
                    TextField("Size (e.g., 8x10 inches)", text: $size)
                    TextField("Estimated Time (e.g., 20 hours)", text: $estimatedTime)
                }
                
                Section(header: Text("Additional Details")) {
                    TextEditor(text: $details)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Kit")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    let updatedKit = Kit(
                        id: kit.id,
                        name: name,
                        size: size,
                        estimatedTime: estimatedTime,
                        details: details
                    )
                    onUpdate(updatedKit)
                    dismiss()
                }
                .disabled(name.isEmpty || size.isEmpty || estimatedTime.isEmpty)
            )
        }
    }
}

#Preview {
    NavigationView {
        KitsView()
    }
} 