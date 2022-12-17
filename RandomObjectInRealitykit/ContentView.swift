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
    var descr = MeshDescriptor()
    var positions: [SIMD3<Float>] = []
    var normals: [SIMD3<Float>] = []
    
    // MARK: - 最初の面の向きを策定
    /** 1->2->3の順で結んだ場合の法線（正規化済み）*/
    let normalVector = normalize(cross(p2 - p1, p3 - p2))
    
    /** p1->p4のベクトル（正規化済み） */
    let vector1to4 = normalize(p4 - p1)
    
    /**
     normalVectorとvector1to4の内積
     正の値の時、同じ方向を向いているため1->2->3の結び方は正しくない
     負の時、別方向を向いているため1->2->3の結び方で正しい
     */
    let theta = dot(normalVector, vector1to4)
    
    if theta < 0 {
        // 正しいためそのまま代入
        positions += [p1, p2, p3]
        normals += [SIMD3<Float>](repeating: normalVector, count: 3)
    } else {
        // 正しくないため反転して代入
        positions += [p1, p3, p2]
        normals += [SIMD3<Float>](repeating: -normalVector, count: 3)
    }
    
    // MARK: - 残り3面を策定
    for (index, pos_a) in positions.enumerated() {
        let pos_b = positions[(index + 2) % 3]
        positions += [p4, pos_a, pos_b]
        let normal = cross(pos_a - p4, pos_b - pos_a)
        normals += [SIMD3<Float>](repeating: normal, count: 3)
    }

    // MARK: - 生成
    descr.positions = MeshBuffers.Positions(positions)
    descr.normals = MeshBuffers.Normals(normals)
    descr.primitives = .triangles([UInt32](0...11))
    
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
