//
//  RandomObject.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/20.
//

import RealityKit

func tetrahedron(_ p: [SIMD3<Float>]) -> (positions: [SIMD3<Float>], normals: [SIMD3<Float>]) {
    precondition(p.count == 4, "値が４つの配列を渡してください")
    
    var positions: [SIMD3<Float>] = []
    var normals: [SIMD3<Float>] = []
    
    // MARK: - 最初の面の向きを確定
    /** 1->2->3の順で結んだ場合の法線（正規化済み）*/
    let normalVector = normalize(cross(p[1] - p[0], p[2] - p[1]))
    
    /** p1->p4のベクトル（正規化済み） */
    let vector1to4 = normalize(p[3] - p[0])
    
    /**
     normalVectorとvector1to4の内積
     正の値の時、同じ方向を向いているため1->2->3の結び方は正しくない
     負の時、別方向を向いているため1->2->3の結び方で正しい
     */
    let theta = dot(normalVector, vector1to4)
    
    if theta < 0 {
        // 正しいためそのまま代入
        positions += [p[0], p[1], p[2]]
        normals += [SIMD3<Float>](repeating: normalVector, count: 3)
    } else {
        // 正しくないため反転して代入
        positions += [p[0], p[2], p[1]]
        normals += [SIMD3<Float>](repeating: -normalVector, count: 3)
    }
    
    // MARK: - 残り3面を確定
    for (index, pos_a) in positions.enumerated() {
        let pos_b = positions[(index + 2) % 3]
        positions += [p[3], pos_a, pos_b]
        let normal = cross(pos_a - p[3], pos_b - pos_a)
        normals += [SIMD3<Float>](repeating: normal, count: 3)
    }
    
    return (positions, normals)
}

func randomObject() -> ModelEntity? {
    var positions: [SIMD3<Float>] = []
    for _ in 1...4 {
        positions.append([
            Float.random(in: -1...1),
            Float.random(in: -1...1),
            Float.random(in: -1...1),
        ])
    }
    
    let result = tetrahedron(positions)
    
    var descr = MeshDescriptor()
    descr.positions = MeshBuffers.Positions(result.positions)
    descr.normals = MeshBuffers.Normals(result.normals)
    descr.primitives = .triangles([UInt32](0...11))
    
    do {
        let resource = try MeshResource.generate(from: [descr])
        return ModelEntity(mesh: resource, materials: [SimpleMaterial()])
    } catch let error {
        print("生成に失敗しました: \(error)")
        return nil
    }
}
