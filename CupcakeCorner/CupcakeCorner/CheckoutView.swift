//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Nick Timmer on 3/24/21.
//

import SwiftUI

struct CheckoutView: View {
    @ObservedObject var order: Order
    @State private var confirmationMessage = ""
    @State private var showAlert = false
    @State private var showingConfirmation = false
    @State private var connectionError = false
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    Image("cupcakes")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width)
                    
                    Text("Your total is $\(self.order.cost, specifier: "%.2f")")
                        .font(.title)
                    
                    Button("Place order") {
                        self.placeOrder()
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitle("Checkout", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            alertMessage
        }
    }
    
    var alertMessage: Alert {
        if showingConfirmation == true {
            return Alert(title: Text("Thank you!"), message: Text(confirmationMessage), dismissButton: .default(Text("OK")))
        } else {
            return Alert(title: Text("test"), message: Text("test"), dismissButton: .default(Text("OK")))
        }
    }
    
    func placeOrder() {
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            return
        }
        
        let url =  URL(string: "https://reqres.in/api/cupcakes")!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = encoded
        
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error.").")
                self.connectionError = true
                self.showAlert = true
                return
            }
            if let decodedOrder = try? JSONDecoder().decode(Order.self, from: data) {
                self.confirmationMessage = "Your order for \(decodedOrder.quantity) \(Order.types[decodedOrder.type].lowercased()) cupcakes is on its way!"
                self.showingConfirmation = true
                self.showAlert = true
            } else {
                print("Invalid response from server")
            }
        }.resume()
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(order: Order())
    }
}
