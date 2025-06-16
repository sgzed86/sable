import SwiftUI

struct ShoppingItem: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var isChecked: Bool
    
    init(id: UUID = UUID(), name: String, isChecked: Bool = false) {
        self.id = id
        self.name = name
        self.isChecked = isChecked
    }
    
    static func == (lhs: ShoppingItem, rhs: ShoppingItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.isChecked == rhs.isChecked
    }
}

struct ShoppingListView: View {
    @AppStorage("shoppingListData") private var shoppingListData: Data = Data()
    @State private var items: [ShoppingItem] = []
    @State private var newItemName = ""
    
    init() {
        // Try to load saved data
        if let savedItems = try? JSONDecoder().decode([ShoppingItem].self, from: shoppingListData) {
            _items = State(initialValue: savedItems)
        }
    }
    
    private func saveShoppingListState() {
        if let encodedData = try? JSONEncoder().encode(items) {
            shoppingListData = encodedData
        }
    }
    
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
        .onDisappear {
            saveShoppingListState()
        }
        .onChange(of: items) { oldValue, newValue in
            saveShoppingListState()
        }
    }
    
    private func addItem() {
        let newItem = ShoppingItem(name: newItemName)
        items.append(newItem)
        newItemName = ""
        saveShoppingListState()
    }
    
    private func toggleItem(_ item: ShoppingItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isChecked.toggle()
            saveShoppingListState()
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        saveShoppingListState()
    }
}

#Preview {
    NavigationView {
        ShoppingListView()
    }
} 