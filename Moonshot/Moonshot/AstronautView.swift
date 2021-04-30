//
//  AstronautView.swift
//  Moonshot
//
//  Created by Nick Timmer on 3/11/21.
//

import SwiftUI

struct AstronautView: View {
    
    let astronaut: Astronaut
//    var missions: [Mission]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack {
                    Image(self.astronaut.id)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                    
                    Text(self.astronaut.description)
                        .padding()
                    
//                    T
                }
            }
        }
        .navigationBarTitle(Text(astronaut.name), displayMode: .inline)
    }
    
    
//    init(astronaut: Astronaut, missions: [Mission]) {
//        self.astronaut = astronaut
//        self.missions = missions
//
//        var matches = [Mission]()
//
//        for member in missions {
//            if let match = member.crew.first(where: {$0.name == self.astronaut.id}) {
//                matches.append(member)
//            } else {
//                fatalError("Missing \(member)")
//            }
//        }
//        self.missions = matches
//    }
}

struct AstronautView_Previews: PreviewProvider {
    static let astronauts: [Astronaut] = Bundle.main.decode("astronauts.json")
    static let missions: [Mission] = Bundle.main.decode("missions.json")
    
    static var previews: some View {
//        AstronautView(astronaut: astronauts[0], missions: missions)
        AstronautView(astronaut: astronauts[0])
    }
}
