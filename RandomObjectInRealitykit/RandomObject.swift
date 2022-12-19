//
//  RandomObject.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/20.
//

import RealityKit

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
