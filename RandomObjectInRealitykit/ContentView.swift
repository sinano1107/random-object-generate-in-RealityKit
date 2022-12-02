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
        let arView = ARView(frame: .zero)
        
        let newAnchor = AnchorEntity(plane: .horizontal)
        let newBox = ModelEntity(mesh: .generateBox(size: 0.3))
        newBox.generateCollisionShapes(recursive: true)
        newAnchor.addChild(newBox)
        arView.scene.addAnchor(newAnchor)
        
        arView.installGestures(for: newBox)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
