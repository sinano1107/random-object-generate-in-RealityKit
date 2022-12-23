//
//  CollisionDetection.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/24.
//

import SwiftUI
import RealityKit

/// ３点を含む平面と別の２点を含む直線が平行でないか
/// - Parameters:
///   - planePoints: 平面を構成する３点
///   - linePoints: 直線を構成する２点
/// - Returns: true: 平行ではない, false: 平行である
func isNotParallel(planePoints: [simd_float3], linePoints: [simd_float3]) -> Bool {
    precondition(planePoints.count == 3, "planePointsには３つの値を代入してください")
    precondition(linePoints.count == 2, "linePointsには２つの値を代入してください")
    let normal = cross(planePoints[1] - planePoints[0], planePoints[2] - planePoints[1])
    let vector = linePoints[1] - linePoints[0]
    let theta = dot(normal, vector)
    return theta != 0
}

struct CollisionDetection: View {
    @State var model = ModelEntity()
    @State var message = "未入力"
    
    init() {
        var result = (red: false, blue: false, yellow: false)
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
            return isNotParallel(planePoints: polygonPoints, linePoints: [start, end])
        }
        
        // red 平行
        do {
            let start = simd_float3(x: -1, y: 1, z: -1)
            let end = simd_float3(x: 1, y: 1, z: -1)
            result.red = check(start, end, .red)
        }
        
        // blue 平行でない
        do {
            let start = simd_float3(x: -0.5, y: 1, z: -0.5)
            let end = simd_float3(x: -0.5, y: -1, z: -0.5)
            result.blue = check(start, end, .blue)
        }
        
        // yellow 平行でない 線分としては衝突しない
        do {
            let start = simd_float3(x: -1, y: 1, z: 0)
            let end = simd_float3(x: 1, y: 0.5, z: 0)
            result.yellow = check(start, end, .yellow)
        }
        
        func m(_ v: Bool) -> String { v ? "平行でない" : "平行である"}
        let message = "赤=\(m(result.red)), 青=\(m(result.blue)), 黄=\(m(result.yellow))"
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
