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

func growth(positions: [simd_float3], normals: [simd_float3]) -> (positions: [simd_float3], normals: [simd_float3])? {
    // 面の選択
    let startIndex = Int.random(in: 0 ..< positions.count / 3) * 3
    let endIndex = startIndex + 2
    let selectedMeshPositions = positions[startIndex ... endIndex].map { $0 }
    let selectedMeshNormal = normals[startIndex]
    
    // 選択した面の削除
    var positions = positions
    var normals = normals
    positions.removeSubrange(startIndex ... endIndex)
    normals.removeSubrange(startIndex ... endIndex)
    
    // 外心の算出
    guard let circumcenter = circumcenter(selectedMeshPositions) else {
        print("外心の算出に失敗しました")
        return nil
    }
    
    // 成長点ベクトルの取得
    let radius = distance(circumcenter, selectedMeshPositions[0])
    let vector = randomInHemisphere(radius: radius)
    
    // 成長点ベクトルの法線方向への回転
    let quaternion = simd_quatf(from: [0, 1, 0], to: normalize(selectedMeshNormal))
    let turnedVector = quaternion.act(vector)
    
    // 成長点の取得
    let growthPoint = circumcenter + turnedVector
    
    // 成長点を接続
    for i in 0...2 {
        let a = selectedMeshPositions[i]
        let b = selectedMeshPositions[(i + 1) % 3]
        let normal = normalize(cross(a - growthPoint, b - a))
        positions += [growthPoint, a, b]
        normals += [simd_float3](repeating: normal, count: 3)
    }

    return (positions, normals)
}

func randomObject(growthCount: Int = 0) -> ModelEntity? {
    // MARK: - 最初の四面体の生成
    var positions = [simd_float3]()
    var normals = [simd_float3]()
    
    for _ in 1...4 {
        positions.append([
            Float.random(in: -1...1),
            Float.random(in: -1...1),
            Float.random(in: -1...1),
        ])
    }
    
    let result = tetrahedron(positions)
    positions = result.positions
    normals = result.normals
    
    // MARK: - 成長
    for _ in 0..<growthCount {
        guard let result = growth(positions: positions, normals: normals) else {
            print("成長に失敗しました")
            return nil
        }
        positions = result.positions
        normals = result.normals
    }
    
    // MARK: - Descrに代入し生成
    var descr = MeshDescriptor()
    descr.positions = MeshBuffers.Positions(positions)
    descr.normals = MeshBuffers.Normals(normals)
    descr.primitives = .triangles([UInt32](0...UInt32(positions.count)))
    
    do {
        let resource = try MeshResource.generate(from: [descr])
        return ModelEntity(mesh: resource, materials: [SimpleMaterial()])
    } catch let error {
        print("生成に失敗しました: \(error)")
        return nil
    }
}
