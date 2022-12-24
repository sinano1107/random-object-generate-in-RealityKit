//
//  CollisionDetection.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/24.
//

import SwiftUI
import RealityKit

func doesItCollision(polygonPoints: [simd_float3], normal: simd_float3, linePoints: [simd_float3]) -> Bool {
    precondition(polygonPoints.count == 3, "polygonPointsには３つの値を代入してください")
    precondition(linePoints.count == 2, "linePointsには２つの値を代入してください")
    // 平行だったら衝突しない
    if dot(normal, linePoints[1] - linePoints[0]) == 0 { return false }
    
    // 2点が平面の同一方向にあるので衝突しない
    let vector_point0 = linePoints[0] - polygonPoints[0]
    let vector_point1 = linePoints[1] - polygonPoints[0]
    let theta_point0 = dot(normal, vector_point0)
    let theta_point1 = dot(normal, vector_point1)
    if theta_point0 * theta_point1 >= 0 { return false }
    
    // 衝突点を算出
    let normal_length = length(normal)
    // 平面との各点の距離
    let d_point0 = abs(theta_point0) / normal_length
    let d_point1 = abs(theta_point1) / normal_length
    /** 内分比 */
    let a = d_point0 / (d_point0 + d_point1)
    /** 衝突点に対するベクトル */
    let vector = (1 - a) * vector_point0 + a * vector_point1
    /** 衝突点 */
    let collisionPoint = polygonPoints[0] + vector
    
    // 衝突点がポリゴン内に含まれるか確認
    let dot_results = [Int](0...2).map {
        let start = polygonPoints[$0]
        let end = polygonPoints[($0 + 1) % 3]
        let cross = normalize(cross(end - start, collisionPoint - end))
        return dot(normal, cross)
    }
    // 全てが正の値(鋭角)ならば衝突点はポリゴン内に含まれる
    return dot_results.allSatisfy { $0 > 0 }
}

struct CollisionDetection: View {
    @State var model = ModelEntity()
    @State var message = "未入力"
    
    init() {
        var result = (red: false, blue: false, yellow: false, green: false)
        let polygonPoints: [simd_float3] = [[1, 0, -1], [-1, 0, -1], [-1, 0, 1]]
        let normal = normalize(cross(polygonPoints[1] - polygonPoints[0], polygonPoints[2] - polygonPoints[1]))
        
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
            return doesItCollision(polygonPoints: polygonPoints, normal: normal, linePoints: [start, end])
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
