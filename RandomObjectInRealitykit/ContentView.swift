//
//  ContentView.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/02.
//

import SwiftUI
import RealityKit

let newBox = ModelEntity(mesh: .generateBox(size: 1))

struct ContentView: View {
    @State var value: Float = 1
    
    var body: some View {
        VStack {
            ARViewContainer().edgesIgnoringSafeArea(.all)
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
        
        let anchor = AnchorEntity(world: .zero)
        newBox.position = [0, 0, -1]
        anchor.addChild(newBox)
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
