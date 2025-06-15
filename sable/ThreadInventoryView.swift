import SwiftUI

struct Thread: Identifiable {
    let id = UUID()
    var brand: String
    var color: String
    var quantity: Int
    var spokenFor: Bool
}

struct ThreadInventoryView: View {
    @State private var threads: [Thread] = []
    @State private var showingAddThread = false
    
    var body: some View {
        List {
            ForEach(threads) { thread in
                VStack(alignment: .leading) {
                    HStack {
                        Text(thread.brand)
                            .font(.headline)
                        Spacer()
                        if thread.spokenFor {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    Text(thread.color)
                        .font(.subheadline)
                    HStack {
                        Text("Quantity: \(thread.quantity)")
                        Spacer()
                        if thread.spokenFor {
                            Text("Spoken For")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Thread Inventory")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddThread = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddThread) {
            AddThreadView(threads: $threads)
        }
    }
}

struct AddThreadView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var threads: [Thread]
    @State private var brand = ""
    @State private var color = ""
    @State private var quantity = ""
    @State private var spokenFor = false
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Brand", text: $brand)
                TextField("Color", text: $color)
                TextField("Quantity", text: $quantity)
                    .keyboardType(.numberPad)
                Toggle("Spoken For", isOn: $spokenFor)
            }
            .navigationTitle("Add Thread")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    if let quantityInt = Int(quantity) {
                        let newThread = Thread(
                            brand: brand,
                            color: color,
                            quantity: quantityInt,
                            spokenFor: spokenFor
                        )
                        threads.append(newThread)
                        dismiss()
                    }
                }
                .disabled(brand.isEmpty || color.isEmpty || quantity.isEmpty)
            )
        }
    }
}

#Preview {
    NavigationView {
        ThreadInventoryView()
    }
} 