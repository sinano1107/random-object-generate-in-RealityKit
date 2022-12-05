//
//  OrbitView.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/03.
//

import SwiftUI
import RealityKit

struct OrbitView: View {
    @Binding var model: ModelEntity
    
    private let camera = PerspectiveCamera()
    private let radius: Float = 2
    private let dragspeed: Float = 0.01
    
    @State private var rotationAngle: Float = 0
    @State private var inclinationAngle: Float = 0
    @State private var dragstart_rotation: Float = 0
    @State private var dragstart_inclination: Float = 0
    
    private struct ARViewContainer: UIViewRepresentable {
        let entity: Entity
        let camera: PerspectiveCamera
        
        func makeUIView(context: Context) -> ARView {
            // arViewの初期化
            #if targetEnvironment(simulator)
            let arView = ARView(frame: .zero)
            #else
            let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
            #endif
            // アンカーを生成
            let anchor = AnchorEntity(world: .zero)
            // カメラのポジションを変更
            camera.position = [0, 0, 2]
            // アンカーにカメラを追加
            anchor.addChild(camera)
            // シーンにアンカーを追加
            arView.scene.addAnchor(anchor)
            return arView
        }
        
        func updateUIView(_ uiView: ARView, context: Context) {
            let anchor = uiView.scene.anchors.first!
            anchor.addChild(entity)
            if anchor.children.count == 3 {
                anchor.children.remove(at: 1)
            }
        }
    }
    
    @MainActor private func updateCamera() {
        let translationTransform = Transform(
            scale: .one,
            rotation: simd_quatf(),
            translation: SIMD3<Float>(0, 0, radius))
        let combinedRotationTransform: Transform = .init(
            pitch: inclinationAngle,
            yaw: rotationAngle,
            roll: 0)
        let computed_transform = matrix_identity_float4x4 * combinedRotationTransform.matrix * translationTransform.matrix
        camera.transform = Transform(matrix: computed_transform)
    }
    
    var body: some View {
        ARViewContainer(entity: model, camera: camera)
            .gesture(DragGesture().onChanged({ value in
                let deltaX = Float(value.location.x - value.startLocation.x)
                let deltaY = Float(value.location.y - value.startLocation.y)
                rotationAngle = dragstart_rotation - deltaX * dragspeed
                inclinationAngle = dragstart_inclination - deltaY * dragspeed
                // 傾きが90度以下、-90度以上になるようにクランプ
                if inclinationAngle > Float.pi / 2 {
                    inclinationAngle = Float.pi / 2
                } else if inclinationAngle < -Float.pi / 2 {
                    inclinationAngle = -Float.pi / 2
                }
                
                updateCamera()
            }).onEnded({ _ in
                dragstart_rotation = rotationAngle
                dragstart_inclination = inclinationAngle
            }))
    }
}

struct OrbitView_Previews: PreviewProvider {
    @State static var model = ModelEntity(mesh: .generateBox(size: 0.5))
    
    static var previews: some View {
        OrbitView(model: $model)
    }
}
