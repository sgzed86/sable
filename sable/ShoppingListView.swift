import SwiftUI

struct ShoppingListView: View {
    var body: some View {
        Text("Shopping List")
            .navigationTitle("Shopping List")
    }
}

#Preview {
    NavigationView {
        ShoppingListView()
    }
} 