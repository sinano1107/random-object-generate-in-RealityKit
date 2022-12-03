//
//  ContentView.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/02.
//

import SwiftUI
import RealityKit

let cameraAnchor = AnchorEntity(world: .zero)
let camera = PerspectiveCamera()
let newAnchor = AnchorEntity(world: .zero)
let newBox = ModelEntity(mesh: .generateBox(size: 0.2))

var mouse: simd_float2 = [0, 0]
var nowPos = camera.position
var pos: simd_float3 = [0, 0, 0]
var prevX: CGFloat?
var prevY: CGFloat?
var prevTime: Date?
func orbit(value: DragGesture.Value) {
    let deltaTime = prevTime != nil ? value.time.timeIntervalSince(prevTime!) : 0
    prevTime = value.time
    
    let deltaX = prevX != nil ? Float(value.location.x - prevX!) : 0
    let deltaY = prevY != nil ? Float(value.location.y - prevY!) : 0
    prevX = value.location.x
    prevY = value.location.y

    mouse += vector2(deltaX, deltaY) * Float(deltaTime) * 0.3
    print(mouse)
    
    mouse.y = min(max(mouse.y, 0), 1)
    
    pos.x = -1 * sin(mouse.y * .pi) * cos(mouse.x * .pi)
    pos.y = -1 * cos(mouse.y * .pi)
    pos.z = -1 * sin(mouse.y * .pi) * sin(mouse.x * .pi)
    
    camera.look(at: newBox.position(relativeTo: nil), from: pos, relativeTo: nil)
}

struct ContentView: View {
    @State var value: Float = 1
    
    var body: some View {
        VStack {
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
                .gesture(DragGesture().onChanged(orbit).onEnded({ value in
                    prevX = nil
                    prevY = nil
                    prevTime = nil
                }))
            Slider(value: Binding(get: { value }, set: { newValue in
                newBox.setScale(SIMD3(repeating: newValue), relativeTo: nil)
                value = newValue
            }), in: 0.1...2).padding(.horizontal)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        #if targetEnvironment(simulator)
        let arView = ARView(frame: .zero)
        #else
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        #endif

        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)

        newAnchor.addChild(newBox)
        arView.scene.addAnchor(newAnchor)
        
        arView.installGestures(.rotation, for: newBox)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
