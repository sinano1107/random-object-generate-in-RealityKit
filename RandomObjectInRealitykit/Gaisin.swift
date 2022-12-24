//
//  Gaisin.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/21.
//

import SwiftUI
import RealityKit

func getCircumcenter(_ positions: [SIMD3<Float>]) -> SIMD3<Float>? {
    precondition(positions.count == 3, "値が３つの配列を渡してください")
    
    let dimension = (m: 3, n: 3)
    let p1 = positions[0]
    let p2 = positions[1]
    let p3 = positions[2]
    
    // 平面の連立方程式
    let planeA: [Float] = [
        p1.x, p2.x, p3.x,
        p1.y, p2.y, p3.y,
        p1.z, p2.z, p3.z
    ]
    let planeB: [Float] = [1, 1, 1]
    guard let planeX = leastSquares_nonsquare(a: planeA, dimension: dimension, b: planeB) else {
        print("平面の連立方程式の解決に失敗しました")
        return nil
    }
    
    // 外心点の連立方程式
    let vector_p1_p2 = p2 - p1
    let vector_p1_p3 = p3 - p1
    let center_p1_p2 = (p1 + p2) / 2
    let center_p1_p3 = (p1 + p3) / 2
    
    let centerA: [Float] = [
        planeX[0], vector_p1_p2[0], vector_p1_p3[0],
        planeX[1], vector_p1_p2[1], vector_p1_p3[1],
        planeX[2], vector_p1_p2[2], vector_p1_p3[2]
    ]
    let centerB: [Float] = [
        1,
        (vector_p1_p2 * center_p1_p2).sum(),
        (vector_p1_p3 * center_p1_p3).sum()
    ]
    guard let centerX = leastSquares_nonsquare(a: centerA, dimension: dimension, b: centerB) else {
        print("外心点の連立方程式の解決に失敗しました")
        return nil
    }
    
    return SIMD3(x: centerX[0], y: centerX[1], z: centerX[2])
}

struct Gaisin: View {
    @State var model = ModelEntity()
    
    func show(_ p1: SIMD3<Float>, _ p2: SIMD3<Float>, _ p3: SIMD3<Float>) {
        model = ModelEntity()
        
        guard let circumcenter = getCircumcenter([p1, p2, p3]) else { return }
        
        // 各ポジションにsphereを配置
        for (index, p) in [p1, p2, p3, circumcenter].enumerated() {
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.3),
                materials: [SimpleMaterial(
                    color: index == 3 ? .red : .white,
                    isMetallic: false
                )])
            sphere.position = p
            model.addChild(sphere)
        }
    }
    
    init() {
        let p1: SIMD3<Float> = [2, 5, 3]
        let p2: SIMD3<Float> = [-4, 2, -1]
        let p3: SIMD3<Float> = [1, -3, 2]
        show(p1, p2, p3)
    }
    
    var body: some View {
        VStack {
            OrbitView($model, radius: 20)
            Button("ランダム") {
                let p1: SIMD3<Float> = SIMD3.random(in: -5...5)
                let p2: SIMD3<Float> = SIMD3.random(in: -5...5)
                let p3: SIMD3<Float> = SIMD3.random(in: -5...5)
                show(p1, p2, p3)
            }
        }
    }
}

struct Gaisin_Previews: PreviewProvider {
    static var previews: some View {
        Gaisin()
    }
}
