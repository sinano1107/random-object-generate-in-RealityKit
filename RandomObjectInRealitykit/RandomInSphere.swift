//
//  RandomInSphere.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/21.
//

import SwiftUI
import RealityKit

struct RandomInSphere: View {
    @State var model = ModelEntity()
    
    func addSphere(_ b: simd_float3) {
        let sphere = ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [SimpleMaterial()])
        
        let cosTheta = Float.random(in: -1...1)
        let sinTheta = sqrt(1 - cosTheta * cosTheta)
        // ここ0...0.5にすると半球になる！
        let phi = 2 * Float.pi * Float.random(in: 0...0.5)
        let radius = pow(Float.random(in: 0...1), 1 / 3)
        
        let pos: SIMD3<Float> = [
            radius * sinTheta * cos(phi),
            radius * sinTheta * sin(phi),
            radius * cosTheta
        ]
        
        let a = simd_float3(0, 1, 0)
        
        let quaternion = simd_quatf(from: a, to: b)
        let rotedPos = quaternion.act(pos)
        
        sphere.setPosition(rotedPos, relativeTo: nil)
        
        model.addChild(sphere)
    }
    
    init() {
        let blue = ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .blue, isMetallic: false)])
        model.addChild(blue)
        let vec: SIMD3<Float> = normalize(simd_float3([1, 1, 0]))
        let red = ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .red, isMetallic: false)])
        red.position = vec
        model.addChild(red)
        for _ in 1...300 {
            addSphere(vec)
        }
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
