//
//  ContentView.swift
//  iExpense
//
//  Created by Nick Timmer on 3/7/21.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: String
    let amount: Int
}

class Expenses: ObservableObject {
    @Published var items = [ExpenseItem]() {
        didSet {
            let encoder = JSONEncoder()
            
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let items = UserDefaults.standard.data(forKey: "Items") {
            let decoder = JSONDecoder()
            
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items) {
                self.items = decoded
                return
            }
        }
        self.items = []
    }
}

struct ContentView: View {
    @ObservedObject var expenses = Expenses()
    @State private var showingAddEspense = false
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(expenses.items) { item in
                    HStack{
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                        }
                        if item.amount <= 10 {
                            Spacer()
                            Text("$\(item.amount)")
                                .foregroundColor(.green)
                        } else if (item.amount > 10) && (item.amount <= 100) {
                            Spacer()
                            Text("$\(item.amount)")
                                .foregroundColor(.orange)
                        } else {
                            Spacer()
                            Text("$\(item.amount)")
                                .foregroundColor(.red)
                        }
                    }
                }
                .onDelete(perform: removeItems)
            }
            .navigationBarTitle("iExpense")
            .environment(\.editMode, $editMode)
            .animation(.spring(response: 0))
            .navigationBarItems(leading: HStack {
                EditButton(editMode: $editMode)
            }, trailing: HStack {
                Button(action: {
                    self.showingAddEspense = true
                }) {
                    Image(systemName: "plus")
                }
            })
            .sheet(isPresented: $showingAddEspense) {
                AddView(expenses: self.expenses)
            }
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}

struct EditButton: View {
    @Binding var editMode: EditMode

    var body: some View {
        Button {
            switch editMode {
            case .active: editMode = .inactive
            case .inactive: editMode = .active
            default: break
            }
        } label: {
            if let isEditing = editMode.isEditing, isEditing {
                Text("Done")
            } else {
                Text("Edit")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
