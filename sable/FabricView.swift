import SwiftUI

struct Fabric: Identifiable, Codable, Equatable {
    var id: UUID
    var count: String
    var length: Double
    var width: Double
    var color: String
    
    init(id: UUID = UUID(), count: String, length: Double, width: Double, color: String) {
        self.id = id
        self.count = count
        self.length = length
        self.width = width
        self.color = color
    }
    
    static func == (lhs: Fabric, rhs: Fabric) -> Bool {
        lhs.id == rhs.id &&
        lhs.count == rhs.count &&
        lhs.length == rhs.length &&
        lhs.width == rhs.width &&
        lhs.color == rhs.color
    }
}

struct FabricView: View {
    @AppStorage("fabricData") private var fabricData: Data = Data()
    @State private var fabrics: [Fabric] = []
    @State private var showingAddFabric = false
    @State private var fabricToEdit: Fabric?
    
    init() {
        // Try to load saved data
        if let savedFabrics = try? JSONDecoder().decode([Fabric].self, from: fabricData) {
            _fabrics = State(initialValue: savedFabrics)
        }
    }
    
    private func saveFabricState() {
        if let encodedData = try? JSONEncoder().encode(fabrics) {
            fabricData = encodedData
        }
    }
    
    var body: some View {
        List {
            ForEach(fabrics) { fabric in
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(fabric.count) Count")
                            .font(.headline)
                        Spacer()
                        Text("\(String(format: "%.1f", fabric.length))\" × \(String(format: "%.1f", fabric.width))\"")
                            .font(.subheadline)
                    }
                    Text(fabric.color)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    fabricToEdit = fabric
                }
            }
            .onDelete(perform: { indexSet in
                fabrics.remove(atOffsets: indexSet)
                saveFabricState()
            })
        }
        .navigationTitle("Fabric")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddFabric = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddFabric) {
            AddFabricView(fabrics: $fabrics)
        }
        .sheet(item: $fabricToEdit) { fabric in
            EditFabricView(fabric: fabric) { updatedFabric in
                if let index = fabrics.firstIndex(where: { $0.id == fabric.id }) {
                    fabrics[index] = updatedFabric
                    saveFabricState()
                }
            }
        }
        .onDisappear {
            saveFabricState()
        }
        .onChange(of: fabrics) { oldValue, newValue in
            saveFabricState()
        }
    }
}

struct AddFabricView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var fabrics: [Fabric]
    @State private var count = ""
    @State private var length = ""
    @State private var width = ""
    @State private var color = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Count (e.g., 14, 18)", text: $count)
                    .keyboardType(.numberPad)
                TextField("Length (inches)", text: $length)
                    .keyboardType(.decimalPad)
                TextField("Width (inches)", text: $width)
                    .keyboardType(.decimalPad)
                TextField("Color", text: $color)
            }
            .navigationTitle("Add Fabric")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    if let countInt = Int(count),
                       let lengthDouble = Double(length),
                       let widthDouble = Double(width) {
                        let newFabric = Fabric(
                            count: String(countInt),
                            length: lengthDouble,
                            width: widthDouble,
                            color: color
                        )
                        fabrics.append(newFabric)
                        dismiss()
                    }
                }
                .disabled(count.isEmpty || length.isEmpty || width.isEmpty || color.isEmpty)
            )
        }
    }
}

struct EditFabricView: View {
    @Environment(\.dismiss) var dismiss
    let fabric: Fabric
    let onUpdate: (Fabric) -> Void
    
    @State private var count: String
    @State private var length: String
    @State private var width: String
    @State private var color: String
    
    init(fabric: Fabric, onUpdate: @escaping (Fabric) -> Void) {
        self.fabric = fabric
        self.onUpdate = onUpdate
        _count = State(initialValue: fabric.count)
        _length = State(initialValue: String(fabric.length))
        _width = State(initialValue: String(fabric.width))
        _color = State(initialValue: fabric.color)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Count (e.g., 14, 18)", text: $count)
                    .keyboardType(.numberPad)
                TextField("Length (inches)", text: $length)
                    .keyboardType(.decimalPad)
                TextField("Width (inches)", text: $width)
                    .keyboardType(.decimalPad)
                TextField("Color", text: $color)
            }
            .navigationTitle("Edit Fabric")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    if let countInt = Int(count),
                       let lengthDouble = Double(length),
                       let widthDouble = Double(width) {
                        let updatedFabric = Fabric(
                            id: fabric.id,
                            count: String(countInt),
                            length: lengthDouble,
                            width: widthDouble,
                            color: color
                        )
                        onUpdate(updatedFabric)
                        dismiss()
                    }
                }
                .disabled(count.isEmpty || length.isEmpty || width.isEmpty || color.isEmpty)
            )
        }
    }
}

#Preview {
    NavigationView {
        FabricView()
    }
} 