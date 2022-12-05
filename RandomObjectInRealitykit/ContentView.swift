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
    
    var body: some View {
        VStack {
            OrbitView(model: $model)
                .edgesIgnoringSafeArea(.all)
            
            Button("三角形を生成") {
                let positions: [SIMD3<Float>] = [[-1, -1, 0], [1, -1, 0], [0, 1, 0]]
                
                var descr = MeshDescriptor()
                descr.positions = MeshBuffers.Positions(positions[0...2])
                descr.primitives = .triangles([0, 1, 2])
                
                let generatedModel = ModelEntity(mesh: try! .generate(from: [descr]))
                
                model = generatedModel
            }
        }
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
