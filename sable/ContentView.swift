//
//  ContentView.swift
//  sable
//
//  Created by ADMIN on 6/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ThreadInventoryView()) {
                    Label("Thread Inventory", systemImage: "spool")
                }
                
                NavigationLink(destination: FabricView()) {
                    Label("Fabric", systemImage: "square.grid.2x2")
                }
                
                NavigationLink(destination: KitsView()) {
                    Label("Kits", systemImage: "shippingbox")
                }
                
                NavigationLink(destination: PatternsView()) {
                    Label("Patterns", systemImage: "doc.text")
                }
                
                NavigationLink(destination: ShoppingListView()) {
                    Label("Shopping List", systemImage: "cart")
                }
            }
            .navigationTitle("S.A.B.L.E")
        }
    }
}

#Preview {
    ContentView()
}
