//
//  ContentView.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/02.
//

import SwiftUI
import RealityKit

struct Position {
    let position: SIMD3<Float>
    let color: UIColor
    let name: String
}

struct ContentView: View {
    @State var model: ModelEntity
    @State var message: String = ""
    
    init() {
        let positions: [Position] = [
            Position(position: [1, 1, 1], color: .red, name: "赤"),
            Position(position: [-1, -1, 1], color: .green, name: "緑"),
            Position(position: [1, -1, -1], color: .blue, name: "青"),
            Position(position: [-1, 1, -1], color: .yellow, name: "黄")
        ]
        
        // tetrahedronを活用
        // ランダムな順序でポジションを渡す
        let ps = positions.shuffled()
        guard let resource = tetrahedron(ps[0].position, ps[1].position, ps[2].position, ps[3].position)
        else {
            model = ModelEntity(mesh: .generateBox(size: 1), materials: [SimpleMaterial()])
            message = "四面体の生成に失敗しました"
            return
        }
        let generatedModel = ModelEntity(mesh: resource, materials: [SimpleMaterial()])
        
        self.model = generatedModel
    }
    
    var body: some View {
        VStack {
            OrbitView(model: $model)
                .edgesIgnoringSafeArea(.all)
            Text(message)
                .font(.title)
            Button("ランダム生成") {
                var positions: [SIMD3<Float>] = []
                for _ in 1...4 {
                    positions.append([
                        Float.random(in: -1...1),
                        Float.random(in: -1...1),
                        Float.random(in: -1...1),
                    ])
                }
                
                guard let resource = tetrahedron(
                    positions[0],
                    positions[1],
                    positions[2],
                    positions[3]
                ) else {
                    message = "ランダム生成に失敗しました"
                    return
                }
                
                self.model = ModelEntity(mesh: resource, materials: [SimpleMaterial()])
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
