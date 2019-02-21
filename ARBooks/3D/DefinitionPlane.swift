//
//  DefinitionPlane.swift
//  ARBooks
//
//  Created by Rahul Sarathy on 2/19/19.
//  Copyright © 2019 Rahul Sarathy. All rights reserved.
//

import Foundation
import ARKit

class DefinitionPlane: SCNNode {
    
    private var width: Float
    private var height: Float
    private var word: String
    private var definition: String
    
    private var mainPlane: SCNNode?
    private var definitionText: SCNNode?
    private var definitionTextNode: SCNText = SCNText()
    private var definitionWord: SCNNode?
    private var definitionWordNode: SCNText = SCNText()
    
    private var noCorners: Bool = true
    
    init(width:CGFloat, height: CGFloat, word:String = "", definition:String = "") {
        self.width = Float(width)
        self.height = Float(height)
        self.word = word
        self.definition = definition
        super.init();

        createPlane()
        createWordText()
        createDefinitionText()

    }
    
    func createPlane() {
        let plane = SCNPlane(width: CGFloat(self.width), height: CGFloat(self.height))
        let mat = SCNMaterial()
        if (!noCorners)
        {
            plane.cornerRadius = 0.005
        }
        plane.cornerSegmentCount = 1
        mat.diffuse.contents = UIColor.white
        self.mainPlane = SCNNode(geometry: plane)
        self.mainPlane?.geometry?.materials = [mat]
        self.addChildNode(mainPlane!)
     //   self.mainPlane.position = SCNVector3(x: -0.17, y: 0.0, z: 0.0)
    }
    
    // Method to create SCNText for the title word of the current definition
    private func createWordText() {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        print(word)
        self.definitionWordNode = SCNText(string: "testing", extrusionDepth: 1)
        definitionWordNode.isWrapped = true
        definitionWordNode.materials = [material]
        
        definitionWordNode.flatness = 0.6
        let myFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.medium)
        definitionWordNode.font = myFont
        definitionWordNode.containerFrame.size = CGSize(width: CGFloat(self.width * 1000 / 2.0), height: CGFloat(self.height * 1000 / 10.0))
        
        let textNode = SCNNode()
        textNode.geometry = definitionWordNode
        
        //  textNode.position = SCNVector3(x: -0.05, y: 0.0, z: 0.0)
      //  textNode.position = SCNVector3(x: Float(-1 * self.width/1.5), y: 0.0, z:0.0 )
        textNode.position = SCNVector3(x: Float(-0.17 * self.width), y:self.height/2.0 - 0.02, z:0.0 )

        textNode.scale = SCNVector3(x: 0.001, y: 0.001, z: 0.001)
        // textNode.eulerAngles.x = -.pi/2
        
        self.definitionWord = textNode
        definitionWord?.name = "definitionWord"
        self.mainPlane?.addChildNode(definitionWord!)

    }
    
    private func createDefinitionText() {
        //text
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        self.definitionTextNode = SCNText(string: self.definition, extrusionDepth: 1)
        definitionTextNode.isWrapped = true
        definitionTextNode.materials = [material]
        
        definitionTextNode.flatness = 0.6
        let myFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.medium)
        definitionTextNode.font = myFont
        definitionTextNode.containerFrame.size = CGSize(width: CGFloat(self.width * 1000), height: CGFloat(self.height * 1000))
        
        let textNode = SCNNode()
        textNode.geometry = definitionTextNode
        
        //  textNode.position = SCNVector3(x: -0.05, y: 0.0, z: 0.0)
        textNode.position = SCNVector3(x: Float(-1 * self.width/2.0), y:Float(-1 * (self.height/1.5)), z:0.0 )
        
        textNode.scale = SCNVector3(x: 0.001, y: 0.001, z: 0.001)
        // textNode.eulerAngles.x = -.pi/2
        
        self.definitionText = textNode
        definitionWord?.name = "definitionText"
        self.mainPlane?.addChildNode(definitionText!)

    }
    
    public func updateDefinition(word: String, definition: String) {
        print("updating definition with: " + definition)
        updateWord(word: word)
        self.definition = definition
        self.definitionTextNode.string = definition
        self.definitionText?.geometry = definitionTextNode
    }
    
    public func updateWord(word: String) {
        self.word = word
        self.definitionWordNode.string = word
        self.definitionWord?.geometry = definitionWordNode
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
