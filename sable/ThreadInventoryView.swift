import SwiftUI

struct Thread: Identifiable, Codable, Equatable {
    var id: UUID
    var brand: String
    var color: String
    var quantity: Int
    var spokenFor: Bool
    
    init(id: UUID = UUID(), brand: String, color: String, quantity: Int, spokenFor: Bool) {
        self.id = id
        self.brand = brand
        self.color = color
        self.quantity = quantity
        self.spokenFor = spokenFor
    }
    
    static func == (lhs: Thread, rhs: Thread) -> Bool {
        lhs.id == rhs.id &&
        lhs.brand == rhs.brand &&
        lhs.color == rhs.color &&
        lhs.quantity == rhs.quantity &&
        lhs.spokenFor == rhs.spokenFor
    }
}

struct ThreadInventoryView: View {
    @AppStorage("threadData") private var threadData: Data = Data()
    @State private var threads: [Thread] = []
    @State private var showingAddThread = false
    @State private var searchText = ""
    
    init() {
        // Initialize with DMC threads
        let dmcThreads = getAllDMCThreads()
        var initialThreads = dmcThreads.map { dmcThread in
            Thread(
                brand: "DMC",
                color: "\(dmcThread.number) - \(dmcThread.name)",
                quantity: 0,
                spokenFor: false
            )
        }
        
        // Try to load saved data
        if let savedThreads = try? JSONDecoder().decode([Thread].self, from: threadData) {
            // Merge saved data with initial threads
            for (index, thread) in initialThreads.enumerated() {
                if let savedThread = savedThreads.first(where: { $0.color == thread.color }) {
                    initialThreads[index].quantity = savedThread.quantity
                    initialThreads[index].spokenFor = savedThread.spokenFor
                }
            }
        }
        
        _threads = State(initialValue: initialThreads)
    }
    
    var filteredThreads: [Thread] {
        if searchText.isEmpty {
            return threads
        }
        return threads.filter { thread in
            thread.color.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func saveThreadState() {
        if let encodedData = try? JSONEncoder().encode(threads) {
            threadData = encodedData
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredThreads) { thread in
                ThreadRow(thread: thread) { updatedThread in
                    if let index = threads.firstIndex(where: { $0.id == thread.id }) {
                        threads[index] = updatedThread
                        saveThreadState()
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search by number or color")
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
        .onDisappear {
            saveThreadState()
        }
        .onChange(of: threads) { oldValue, newValue in
            saveThreadState()
        }
    }
}

struct ThreadRow: View {
    let thread: Thread
    let onUpdate: (Thread) -> Void
    @State private var quantity: Int
    @State private var spokenFor: Bool
    
    init(thread: Thread, onUpdate: @escaping (Thread) -> Void) {
        self.thread = thread
        self.onUpdate = onUpdate
        _quantity = State(initialValue: thread.quantity)
        _spokenFor = State(initialValue: thread.spokenFor)
    }
    
    var threadComponents: (number: String, name: String) {
        let components = thread.color.components(separatedBy: " - ")
        return (components[0], components.count > 1 ? components[1] : "")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(thread.brand)
                    .font(.headline)
                Spacer()
                if spokenFor {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            HStack(spacing: 8) {
                Circle()
                    .fill(getColorForDMCThread(threadComponents.name))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                VStack(alignment: .leading) {
                    Text(threadComponents.number)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(threadComponents.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("Quantity:")
                Spacer()
                Stepper("\(quantity)", value: $quantity, in: 0...100)
                    .labelsHidden()
                    .onChange(of: quantity) { oldValue, newValue in
                        var updatedThread = thread
                        updatedThread.quantity = newValue
                        onUpdate(updatedThread)
                    }
                Text("\(quantity)")
                    .frame(minWidth: 30)
            }
            
            HStack {
                Text("Spoken For")
                    .foregroundColor(.secondary)
                Spacer()
                Toggle("Spoken For", isOn: $spokenFor)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .onChange(of: spokenFor) { oldValue, newValue in
                        var updatedThread = thread
                        updatedThread.spokenFor = newValue
                        onUpdate(updatedThread)
                    }
            }
        }
        .padding(.vertical, 4)
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

#Preview {
    NavigationStack {
        ThreadInventoryView()
    }
} 