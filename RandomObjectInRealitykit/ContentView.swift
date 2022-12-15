//
//  ContentView.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/02.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @State var model: ModelEntity
    
    init() {
        let positions: [SIMD3<Float>] = [[1, 1, 1], [-1, -1, 1], [1, -1, -1], [-1, 1, -1]]
        let colors: [UIColor] = [.red, .green, .blue, .yellow]
        
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
        
        // 頂点に球を追加
        for (index, p) in positions.enumerated() {
            let material = SimpleMaterial(color: colors[index], isMetallic: true)
            let sphere = ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [material])
            sphere.position = p
            generatedModel.addChild(sphere)
        }
        
        self.model = generatedModel
    }
    
    var body: some View {
        OrbitView(model: $model)
            .edgesIgnoringSafeArea(.all)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
