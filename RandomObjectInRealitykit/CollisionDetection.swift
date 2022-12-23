//
//  CollisionDetection.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/24.
//

import SwiftUI
import RealityKit

func doesCollideWithLineSegment(normal: simd_float3, linePoints: [simd_float3]) -> Bool {
    precondition(linePoints.count == 2, "linePointsには２つの値を代入してください")
    // 平行だったら衝突しない
    if dot(normal, linePoints[1] - linePoints[0]) == 0 { return false }
    
    // linePoints[0], linePoints[1]は位置ベクトルだが、
    // 平面上の原点(0,0,0)からの向きベクトルでもある。
    // なのでそのまま向きベクトルとして利用している。
    return dot(normal, linePoints[0]) * dot(normal, linePoints[1]) <= 0
}

struct CollisionDetection: View {
    @State var model = ModelEntity()
    @State var message = "未入力"
    
    init() {
        var result = (red: false, blue: false, yellow: false, green: false)
        let polygonPoints: [simd_float3] = [[1, 0, -1], [-1, 0, -1], [-1, 0, 1]]
        
        // polygon
        var descr = MeshDescriptor()
        descr.positions = MeshBuffer(polygonPoints)
        descr.primitives = .triangles([UInt32](0...2))
        let resource = try! MeshResource.generate(from: [descr])
        let polygon = ModelEntity(mesh: resource, materials: [SimpleMaterial()])
        model.addChild(polygon)
        
        func check(_ start: simd_float3, _ end: simd_float3, _ color: UIColor) -> Bool {
            let start_sphere = ModelEntity(mesh: .generateSphere(radius: 0.1), materials: [SimpleMaterial(color: color, isMetallic: true)])
            let end_sphere = start_sphere.clone(recursive: false)
            start_sphere.setPosition(start, relativeTo: nil)
            end_sphere.setPosition(end, relativeTo: nil)
            model.addChild(start_sphere)
            model.addChild(end_sphere)
            return doesCollideWithLineSegment(normal: [0, 1, 0], linePoints: [start, end])
        }
        
        // red
        do {
            let start = simd_float3(x: -1, y: 1, z: -1)
            let end = simd_float3(x: 1, y: 1, z: -1)
            result.red = check(start, end, .red)
        }
        
        // blue
        do {
            let start = simd_float3(x: -0.5, y: 1, z: -0.5)
            let end = simd_float3(x: -0.5, y: -1, z: -0.5)
            result.blue = check(start, end, .blue)
        }
        
        // yellow
        do {
            let start = simd_float3(x: -1, y: 1, z: 0)
            let end = simd_float3(x: 1, y: 0.5, z: 0)
            result.yellow = check(start, end, .yellow)
        }
        
        // green
        do {
            let start = simd_float3(x: 1, y: 1, z: 0.5)
            let end = simd_float3(x: 1, y: -1, z: 0.5)
            result.green = check(start, end, .green)
        }
        
        func m(_ v: Bool) -> String { v ? "衝突する" : "衝突しない"}
        let message = "赤=\(m(result.red)), 青=\(m(result.blue)), 黄=\(m(result.yellow)), 緑=\(m(result.green))"
        _message = State(initialValue: message)
    }
    
    var body: some View {
        VStack {
            OrbitView($model)
            Text(message)
        }
    }
}

struct CollisionDetection_Previews: PreviewProvider {
    static var previews: some View {
        CollisionDetection()
    }
}
