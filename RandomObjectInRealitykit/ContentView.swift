//
//  ContentView.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/02.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @State var model = ModelEntity(mesh: .generateBox(size: 1))
    
    var body: some View {
        VStack {
            OrbitView(model: $model)
                .edgesIgnoringSafeArea(.all)
            
            Button("三角形を生成") {
                let positions: [SIMD3<Float>] = [[-1, -1, 0], [1, -1, 0], [0, 1, 0]]
                let colors: [UIColor] = [.red, .green, .blue]
                
                var descr = MeshDescriptor()
                descr.positions = MeshBuffers.Positions(positions[0...2])
                descr.primitives = .triangles([0, 1, 2])
                
                let material = SimpleMaterial(color: .white, isMetallic: false)
                let generatedModel = ModelEntity(mesh: try! .generate(from: [descr]), materials: [material])
                
                // 頂点に球を追加
                for (index, p) in positions.enumerated() {
                    let material = SimpleMaterial(color: colors[index], isMetallic: false)
                    let sphere = ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [material])
                    sphere.position = p
                    generatedModel.addChild(sphere)
                }
                
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
