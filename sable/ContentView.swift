//
//  ContentView.swift
//  sable
//
//  Created by ADMIN on 6/15/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                List {
                    Button(action: {
                        selectedTab = 1 // Switch to Thread Inventory tab
                    }) {
                        Label("Thread Inventory", systemImage: "scribble")
                    }
                    
                    Button(action: {
                        selectedTab = 2 // Switch to Fabric tab
                    }) {
                        Label("Fabric", systemImage: "square.grid.2x2")
                    }
                    
                    Button(action: {
                        selectedTab = 3 // Switch to Kits tab
                    }) {
                        Label("Kits", systemImage: "shippingbox")
                    }
                    
                    Button(action: {
                        selectedTab = 4 // Switch to Patterns tab
                    }) {
                        Label("Patterns", systemImage: "doc.text")
                    }
                    
                    Button(action: {
                        selectedTab = 5 // Switch to Shopping List tab
                    }) {
                        Label("Shopping List", systemImage: "cart")
                    }
                }
                .navigationTitle("S.A.B.L.E")
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(0)
            
            NavigationStack {
                ThreadInventoryView()
            }
            .tabItem {
                Label("Threads", systemImage: "scribble")
            }
            .tag(1)
            
            NavigationStack {
                FabricView()
            }
            .tabItem {
                Label("Fabric", systemImage: "square.grid.2x2")
            }
            .tag(2)
            
            NavigationStack {
                KitsView()
            }
            .tabItem {
                Label("Kits", systemImage: "shippingbox")
            }
            .tag(3)
            
            NavigationStack {
                PatternsView()
            }
            .tabItem {
                Label("Patterns", systemImage: "doc.text")
            }
            .tag(4)
            
            NavigationStack {
                ShoppingListView()
            }
            .tabItem {
                Label("Shopping", systemImage: "cart")
            }
            .tag(5)
        }
        .onAppear {
            selectedTab = 0 // Ensure we start on the home tab
        }
    }
}

#Preview {
    ContentView()
}
