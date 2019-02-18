//
//  BookPage.swift
//  ChessboardDetection
//
//  Created by Rahul Sarathy on 2/11/19.
//  Copyright © 2019 Rahul Sarathy. All rights reserved.
//

import Foundation
import ARKit

class BookPage: SCNNode {
    
    private var planeNode: SCNNode
    private var textNode: SCNNode
    private let text: String
    
    private var width: CGFloat
    private var height: CGFloat

    
    init(width:CGFloat, height: CGFloat, text:String = "") {
        self.planeNode = SCNNode()
        self.textNode = SCNNode()
        self.text = text
        self.width = width
        self.height = height
        super.init();
        createPlane(width: width, height: height)
        createText()

    }

    private func createPlane(width: CGFloat, height: CGFloat) {
        let plane = SCNPlane(width: width, height: height)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.white
        self.planeNode = SCNNode(geometry: plane)
        self.planeNode.geometry?.materials = [mat]
      //  self.planeNode.eulerAngles.x = -.pi/2
    }
    
    func getWidth() -> CGFloat{
        return self.width
    }
    
    func getHeight() -> CGFloat {
        return self.height
    }
    
    func highlight() {
        self.planeNode.runAction(self.imageHighlightAction)
    }
    
    func getPlane() -> SCNNode {
        print(self.planeNode)
        return self.planeNode
    }
    
    func getText() -> SCNNode {
        return self.textNode
    }
    
    private func createText() {
        //text
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        let text = SCNText(string: self.text, extrusionDepth: 1)
        text.isWrapped = true
        text.materials = [material]
        
        text.flatness = 0.0
        let myFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.medium)
        text.font = myFont
        text.containerFrame.size = CGSize(width: self.getWidth() * 1000, height: self.getHeight() * 1000)
        
        let textNode = SCNNode()
        textNode.geometry = text
        textNode.position = SCNVector3(x: -0.1, y: -0.1, z: 0.0)
        //textNode.position = SCNVector3(x: Float(-1 * self.getWidth()/2.0), y: 0.0, z: -0.1)
        
        textNode.scale = SCNVector3(x: 0.001, y: 0.001, z: 0.001)
       // textNode.eulerAngles.x = -.pi/2
        
        self.textNode = textNode
    }
    
    private var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            // .fadeOut(duration: 0.5),
            //   .removeFromParentNode()
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
