import SwiftUI

struct ShoppingItem: Identifiable {
    let id = UUID()
    var name: String
    var isChecked: Bool
}

struct ShoppingListView: View {
    @State private var items: [ShoppingItem] = []
    @State private var newItemName = ""
    
    var body: some View {
        VStack {
            // Add new item field
            HStack {
                TextField("Add new item", text: $newItemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: addItem) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                .disabled(newItemName.isEmpty)
            }
            .padding()
            
            // Shopping list
            List {
                ForEach(items) { item in
                    HStack {
                        Button(action: {
                            toggleItem(item)
                        }) {
                            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isChecked ? .green : .gray)
                        }
                        
                        Text(item.name)
                            .strikethrough(item.isChecked)
                            .foregroundColor(item.isChecked ? .gray : .primary)
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationTitle("Shopping List")
    }
    
    private func addItem() {
        let newItem = ShoppingItem(name: newItemName, isChecked: false)
        items.append(newItem)
        newItemName = ""
    }
    
    private func toggleItem(_ item: ShoppingItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isChecked.toggle()
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}

#Preview {
    NavigationView {
        ShoppingListView()
    }
} 