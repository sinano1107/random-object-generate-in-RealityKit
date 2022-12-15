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

func tetrahedron(_ p1: SIMD3<Float>, _ p2: SIMD3<Float>, _ p3: SIMD3<Float>, _ p4: SIMD3<Float>) -> MeshResource? {
    // descriptor
    var descr = MeshDescriptor()
    descr.positions = MeshBuffers.Positions([
        p1, p2, p3
    ])
    descr.primitives = .triangles([UInt32](0...2))
    
    do {
        return try MeshResource.generate(from: [descr])
    } catch {
        print("四面体の生成に失敗しました")
        return nil
    }
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
        
        /*
        // 正四面体を作成
        var descr = MeshDescriptor()
        // positions
        descr.positions = MeshBuffers.Positions([
            positions[0], positions[1], positions[2],
            positions[1], positions[0], positions[3],
            positions[2], positions[3], positions[0],
            positions[3], positions[2], positions[1],
        ])
        // primitives
        descr.primitives = .triangles([
            0, 1, 2,
            3, 4, 5,
            6, 7, 8,
            9, 10, 11,
        ])
        // normals
        let normal_0 = cross(positions[1] - positions[0], positions[2] - positions[1])
        let normal_1 = cross(positions[0] - positions[1], positions[3] - positions[0])
        let normal_2 = cross(positions[3] - positions[2], positions[0] - positions[3])
        let normal_3 = cross(positions[2] - positions[3], positions[1] - positions[2])
        descr.normals = MeshBuffers.Normals([
            normal_0, normal_0, normal_0,
            normal_1, normal_1, normal_1,
            normal_2, normal_2, normal_2,
            normal_3, normal_3, normal_3,
        ])
        
        let generatedModel = ModelEntity(mesh: try! .generate(from: [descr]), materials: [SimpleMaterial()])
         */
        
        // tetrahedronを活用
        // ランダムな順序でポジションを渡す
        let ps = positions.shuffled()
        guard let resource = tetrahedron(ps[0].position, ps[1].position, ps[2].position, ps[3].position)
        else {
            model = ModelEntity(mesh: .generateBox(size: 1), materials: [SimpleMaterial()])
            message = "四面体の生成に失敗しました"
            return
        }
        // メッセージに順序を記載
        message = "\(ps[0].name), \(ps[1].name), \(ps[2].name), \(ps[3].name)"
        let generatedModel = ModelEntity(mesh: resource, materials: [SimpleMaterial()])
        
        // 頂点に球を追加
        for p in positions {
            let material = SimpleMaterial(color: p.color, isMetallic: true)
            let sphere = ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [material])
            sphere.position = p.position
            generatedModel.addChild(sphere)
        }
        
        self.model = generatedModel
    }
    
    var body: some View {
        VStack {
            OrbitView(model: $model)
                .edgesIgnoringSafeArea(.all)
            Text(message)
                .font(.title)
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
