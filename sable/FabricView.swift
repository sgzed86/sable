import SwiftUI

struct Fabric: Identifiable {
    let id = UUID()
    var count: String
    var amount: Double
    var color: String
}

struct FabricView: View {
    @State private var fabrics: [Fabric] = []
    @State private var showingAddFabric = false
    
    var body: some View {
        List {
            ForEach(fabrics) { fabric in
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(fabric.count) Count")
                            .font(.headline)
                        Spacer()
                        Text("\(String(format: "%.1f", fabric.amount)) yards")
                            .font(.subheadline)
                    }
                    Text(fabric.color)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
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
    }
}

struct AddFabricView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var fabrics: [Fabric]
    @State private var count = ""
    @State private var amount = ""
    @State private var color = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Count (e.g., 14, 18)", text: $count)
                    .keyboardType(.numberPad)
                TextField("Amount (yards)", text: $amount)
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
                       let amountDouble = Double(amount) {
                        let newFabric = Fabric(
                            count: String(countInt),
                            amount: amountDouble,
                            color: color
                        )
                        fabrics.append(newFabric)
                        dismiss()
                    }
                }
                .disabled(count.isEmpty || amount.isEmpty || color.isEmpty)
            )
        }
    }
}

#Preview {
    NavigationView {
        FabricView()
    }
} 