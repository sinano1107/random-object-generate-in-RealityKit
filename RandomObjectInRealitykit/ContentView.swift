//
//  ContentView.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/02.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var model: ModelEntity
    @State private var message: String = ""
    
    init() {
        // 正四面体のポジション
        let positions: [SIMD3<Float>] = [[1, 1, 1], [-1, -1, 1], [1, -1, -1], [-1, 1, -1]]
        
        // tetrahedron関数で正しく結ぶ
        let result = tetrahedron(positions)
        
        // descriptorに値を代入
        var descr = MeshDescriptor()
        descr.positions = MeshBuffers.Positions(result.positions)
        descr.normals = MeshBuffers.Normals(result.normals)
        descr.primitives = .triangles([UInt32](0...11))
        
        do {
            // resourceを生成しmodelに代入
            let resource = try MeshResource.generate(from: [descr])
            model = ModelEntity(mesh: resource, materials: [SimpleMaterial()])
        } catch {
            // 失敗した場合は立方体を代入
            message = "四面体の生成に失敗しました"
            model = ModelEntity(mesh: .generateBox(size: 1), materials: [SimpleMaterial()])
        }
    }
    
    var body: some View {
        VStack {
            OrbitView($model)
                .edgesIgnoringSafeArea(.all)
            Text(message)
            Button("ランダム生成") {
                guard let randomObject = randomObject(growthCount: 10) else {
                    message = "ランダム生成に失敗しました"
                    return
                }
                self.model = randomObject
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
