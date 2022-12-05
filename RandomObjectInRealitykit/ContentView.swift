//
//  ContentView.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/02.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @State var model = ModelEntity(mesh: .generateBox(size: 0.5))
    @State var isBox = true
    
    var body: some View {
        VStack {
            OrbitView(model: $model)
                .edgesIgnoringSafeArea(.all)
            Button("トグル") {
                isBox.toggle()
                if isBox {
                    model = ModelEntity(mesh: .generateBox(size: 0.5))
                } else {
                    model = ModelEntity(mesh: .generateSphere(radius: 0.5))
                }
            }
        }
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
