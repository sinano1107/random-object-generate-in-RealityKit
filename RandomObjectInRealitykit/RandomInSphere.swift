//
//  RandomInSphere.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/21.
//

import SwiftUI
import RealityKit

/** 上に凸な半球内のランダムなポジションを返す */
func randomInHemisphere(radius: Float = 1) -> simd_float3 {
    let cosTheta = Float.random(in: -1...1)
    let sinTheta = sqrt(1 - cosTheta * cosTheta)
    // 0...1にすると全球となる
    let phi = 2 * Float.pi * Float.random(in: 0...0.5)
    let r = pow(Float.random(in: 0...1), 1 / 3) * radius
    
    return simd_float3(
        x: r * sinTheta * cos(phi),
        y: r * sinTheta * sin(phi),
        z: r * cosTheta)
}

struct RandomInSphere: View {
    @State private var model = ModelEntity()
    
    func addSphere(_ b: simd_float3) {
        let sphere = ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [SimpleMaterial()])
        
        let pos = randomInHemisphere()
        
        let a = simd_float3(0, 1, 0)
        let quaternion = simd_quatf(from: a, to: b)
        let rotedPos = quaternion.act(pos)

        sphere.setPosition(rotedPos, relativeTo: nil)
        sphere.setPosition(rotedPos, relativeTo: nil)
        
        model.addChild(sphere)
    }
    
    init() {
        // 原点=青
        let blue = ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .blue, isMetallic: false)])
        model.addChild(blue)
        // 右上の点=赤
        let vec: SIMD3<Float> = normalize(simd_float3([1, 1, 0]))
        let red = ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .red, isMetallic: false)])
        red.position = vec
        model.addChild(red)
        // ランダムな点を追加
        for _ in 1...300 {
            addSphere(vec)
        }
        // radiusの検証用
        // model.addChild(ModelEntity(mesh: .generateSphere(radius: 1)))
    }
    
    var body: some View {
        OrbitView($model)
    }
}

struct RandomInSphere_Previews: PreviewProvider {
    static var previews: some View {
        RandomInSphere()
    }
}
