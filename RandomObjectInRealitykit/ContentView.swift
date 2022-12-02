//
//  ContentView.swift
//  RandomObjectInRealitykit
//
//  Created by 長政輝 on 2022/12/02.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        #if targetEnvironment(simulator)
        let arView = ARView(frame: .zero)
        #else
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        #endif
        
        let newAnchor = AnchorEntity(world: [0, 0, -1])
        let newBox = ModelEntity(mesh: .generateBox(size: 1))
        newBox.generateCollisionShapes(recursive: true)
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
