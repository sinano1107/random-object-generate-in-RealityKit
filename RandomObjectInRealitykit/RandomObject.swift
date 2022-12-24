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

func growth(positions inputPositions: [simd_float3], normals inputNormals: [simd_float3]) -> (positions: [simd_float3], normals: [simd_float3])? {
    struct GrowthData {
        /** 成長点（座標） */
        let growthPoint: simd_float3
        /** 成長させるメッシュの座標のリスト */
        let meshPositions: [simd_float3]
        /** 成長させるメッシュの法線 */
        let meshNormal: simd_float3
        /** 成長させるメッシュ以外のメッシュの座標のリスト */
        let positions: [simd_float3]
        /** 成長させつメッシュ以外のメッシュの法線のリスト */
        let normals: [simd_float3]
        
        init(positions inputPositions: [simd_float3], normals inputNormals: [simd_float3]) throws {
            // 成長させるメッシュ
            let startIndex = Int.random(in: 0 ..< inputPositions.count / 3) * 3
            let endIndex = startIndex + 2
            meshPositions = inputPositions[startIndex ... endIndex].map { $0 }
            meshNormal = inputNormals[startIndex]
            // 成長させるメッシュ以外のメッシュ
            var positions = inputPositions
            var normals = inputNormals
            positions.removeSubrange(startIndex ... endIndex)
            normals.removeSubrange(startIndex ... endIndex)
            self.positions = positions
            self.normals = normals
            // 外心の算出
            guard let circumcenter = getCircumcenter(meshPositions) else { throw GrowthError.failureGetCircumcenter }
            /** 半径 */
            let radius = distance(circumcenter, meshPositions[0])
            // 成長点ベクトルの取得
            let vector = randomInHemisphere(radius: radius)
            // 成長点ベクトルの法線方向への回転
            let quaternion = simd_quatf(from: [0, 1, 0], to: normalize(meshNormal))
            let turnedVector = quaternion.act(vector)
            // 外心から成長点ベクトル方向の点を成長点とする
            growthPoint = circumcenter + turnedVector
        }
        
        /**　成長点を採用した場合、既存のポリゴンと干渉（衝突）するか確認する */
        func checkCollision() -> Bool {
            for point_index in 0...2 {
                /** 成長面を構成する一点（ループによってすべてチェックする）*/
                let point = meshPositions[point_index]
                let linePoints = [growthPoint, point]
                for polygon_index in 0 ..< positions.count / 3 {
                    // 既存のポリゴン（ループによってすべてチェックする）
                    let startIndex = polygon_index * 3
                    let endIndex = startIndex + 2
                    let polygonPoints = positions[startIndex ... endIndex].map { $0 }
                    let normal = normals[startIndex] // 三点の法線はすべて同じ値なので適当に最初のを取り出す
                    if doesItCollision(polygonPoints: polygonPoints, normal: normal, linePoints: linePoints) {
                        return true
                    }
                }
            }
            return false
        }
        
        /** MeshDescriptorに代入できるデータを生成する */
        func build() -> (positions: [simd_float3], normals: [simd_float3]) {
            var positions = self.positions
            var normals = self.normals
            for i in 0...2 {
                let a = meshPositions[i]
                let b = meshPositions[(i + 1) % 3]
                let normal = normalize(cross(a - growthPoint, b - a))
                positions += [growthPoint, a, b]
                normals += [simd_float3](repeating: normal, count: 3)
            }
            return (positions, normals)
        }
    }
    
    enum GrowthError: Error {
        case failureGetCircumcenter
    }
    
    do {
        var data = try GrowthData(positions: inputPositions, normals: inputNormals)
        // 衝突しなくなるまで試行する
        while data.checkCollision() {
            data = try GrowthData(positions: inputPositions, normals: inputNormals)
        }
        // ビルドして返す
        return data.build()
    } catch GrowthError.failureGetCircumcenter {
        print("外心の算出に失敗しました")
        return nil
    } catch {
        print("成長に失敗しました: \(error)")
        return nil
    }
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
    print("面数: \(positions.count / 3)")
    
    do {
        let resource = try MeshResource.generate(from: [descr])
        return ModelEntity(mesh: resource, materials: [SimpleMaterial()])
    } catch let error {
        print("生成に失敗しました: \(error)")
        return nil
    }
}
