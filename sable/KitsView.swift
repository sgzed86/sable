import SwiftUI

struct Kit: Identifiable {
    let id = UUID()
    var name: String
    var size: String
    var estimatedTime: String
    var details: String
}

struct KitsView: View {
    @State private var kits: [Kit] = []
    @State private var showingAddKit = false
    
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

#Preview {
    NavigationView {
        KitsView()
    }
} 