//
//  ContentView.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/02.
//

import SwiftUI
import RealityKit

let camera = PerspectiveCamera()

var radius: Float = 2
var dragspeed: Float = 0.01
var rotationAngle: Float = 0
var inclinationAngle: Float = 0
var dragstart_rotation: Float = 0
var dragstart_inclination: Float = 0

@MainActor private func updateCamera() {
    let translationTransform = Transform(scale: .one,
                                         rotation: simd_quatf(),
                                         translation: SIMD3<Float>(0, 0, radius))
    let combinedRotationTransform: Transform = .init(pitch: inclinationAngle, yaw: rotationAngle, roll: 0)
    let computed_transform = matrix_identity_float4x4 * combinedRotationTransform.matrix * translationTransform.matrix
    camera.transform = Transform(matrix: computed_transform)
}

struct ContentView: View {
    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
            .gesture(DragGesture().onChanged({ value in
                let deltaX = Float(value.location.x - value.startLocation.x)
                let deltaY = Float(value.location.y - value.startLocation.y)
                rotationAngle = dragstart_rotation - deltaX * dragspeed
                inclinationAngle = dragstart_inclination - deltaY * dragspeed
                if inclinationAngle > Float.pi / 2 {
                    inclinationAngle = Float.pi / 2
                }
                if inclinationAngle < -Float.pi / 2 {
                    inclinationAngle = -Float.pi / 2
                }

                updateCamera()
            }).onEnded({ _ in
                dragstart_rotation = rotationAngle
                dragstart_inclination = inclinationAngle
            }))
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        #if targetEnvironment(simulator)
        let arView = ARView(frame: .zero)
        #else
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        #endif
        
        let anchor = AnchorEntity(world: .zero)
        let newBox = ModelEntity(mesh: .generateBox(size: 0.5))
        camera.position = [0, 0, 2]
        anchor.addChild(newBox)
        anchor.addChild(camera)
        arView.scene.addAnchor(anchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
