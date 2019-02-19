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
    
    private var planeNode: SCNNode = SCNNode()
    private var definitionPlane: SCNNode = SCNNode()
    private var definitionText: SCNNode = SCNNode()
    private var definitionTextNode: SCNText = SCNText()
    private var textNode: SCNNode = SCNNode()
    private var text: String = ""
    private var currentDef: String = "testing"
    var textNodeArray: [SCNNode] = []
    
    private var width: CGFloat
    private var height: CGFloat
    
    let app_id = "faa06bfa"
    let app_key = "a2fe9da627b566e4ce05ca33490639a5"

    
    init(width:CGFloat, height: CGFloat, text:String = "") {
        self.text = text
        self.width = width
        self.height = height
        super.init();

        createDefinition3D()
        createPlane(width: width, height: height)
        self.renderWords()
        createDefinitionPlane()
        self.addChildNode(self.planeNode)
        self.addChildNode(self.textNode)
        self.addChildNode(definitionPlane)
        self.definitionPlane.addChildNode(self.definitionText)

    }
    
    private func splitText() {
        let textArray = self.text.components(separatedBy: " ")
        for word in textArray {
            textNodeArray.append(self.createText(word: word))
        }
    }
    
    private func renderWords() {
        splitText()
        spaceWords()
        for word in textNodeArray {
            self.planeNode.addChildNode(word)
        }
    }
    
    private func spaceWords() {
        var currentX: Float = Float(-1 * self.getWidth()/2.0) + 0.006
        var currentY:Float =  Float(self.getHeight() / 2.0) - 0.015
        let currentZ: Float = 0.1/1000
        let spacing: Float = 8
        let spacingY: Float = 7
        let height: Float = (textNodeArray[0].boundingBox.max.y - textNodeArray[0].boundingBox.min.y)
        for (index, _) in textNodeArray.enumerated() {
            if index == 0 {
                textNodeArray[index].position = SCNVector3(x: currentX, y: currentY, z: currentZ)
            }
            else {
                let width = Float(textNodeArray[index - 1].boundingBox.max.x - textNodeArray[index - 1].boundingBox.min.x)
                let currentWidth = Float(textNodeArray[index].boundingBox.max.x - textNodeArray[index].boundingBox.min.x)/1000.0
                currentX += (width + spacing)/1000
                if (currentX + currentWidth + Float(self.getWidth() / 2.0)) > Float(self.getWidth())
                {
                    currentY -= (height + spacingY) / 1000
                    currentX = Float(-1 * self.getWidth()/2.0) + 0.006
                }
                textNodeArray[index].position = SCNVector3(x: currentX, y: currentY, z: currentZ)
            }
        }
    }
    
    public func findClosest(referencePoint: SCNVector3) -> SCNNode{
        
        var closestIndex = 0
        var closestLength:Float = 0.0
        var lengths: Dictionary<Int, Float> = Dictionary<Int, Float>()
        for (index, word) in textNodeArray.enumerated() {
            let wordPos = word.worldPosition
            let distance = SCNVector3(
                wordPos.x - referencePoint.x,
                wordPos.y - referencePoint.y,
                wordPos.z - referencePoint.z
            )
            let length = sqrtf(distance.x * distance.x + distance.y * distance.y + distance.z * distance.z)
            if (index == 0) {
                closestLength = length
                closestIndex = 0
            }
            else {
                if length < closestLength {
                    closestIndex = index
                    closestLength = length
                }
            }
        }
        return textNodeArray[closestIndex]
    }
    
    private func createText(word: String) -> SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        
        let text = SCNText(string: word, extrusionDepth: 1)
        text.isWrapped = true
        text.materials = [material]
        text.flatness = 1.5
        let myFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.medium)
        text.font = myFont
       // text.containerFrame.size = CGSize(width: self.getWidth() * 1000 / 2.0, height: self.getHeight() * 1000)

        let textNode = SCNNode()
        textNode.geometry = text
    //    textNode.position = SCNVector3(x: Float(-1 * self.getWidth()/2.0), y: 0.0, z: -0.1)

        textNode.scale = SCNVector3(x: 0.001, y: 0.001, z: 0.001)

        return textNode
    }
    
    private func updateDefinition() {
        self.definitionTextNode.string = self.currentDef
        self.definitionText.geometry = definitionTextNode
    }
    
    private func createDefinitionPlane() {
        let plane = SCNPlane(width: self.width / 2.0, height: self.height)
        let mat = SCNMaterial()
        plane.cornerRadius = 0.005
        plane.cornerSegmentCount = 3
        mat.diffuse.contents = UIColor.white
        self.definitionPlane = SCNNode(geometry: plane)
        self.definitionPlane.geometry?.materials = [mat]
        self.definitionPlane.position = SCNVector3(x: -0.17, y: 0.0, z: 0.0)
    }
    
    private func createDefinition3D() {
        //text
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        self.definitionTextNode = SCNText(string: self.currentDef, extrusionDepth: 1)
        definitionTextNode.isWrapped = true
        definitionTextNode.materials = [material]
        
        definitionTextNode.flatness = 0.6
        let myFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.medium)
        definitionTextNode.font = myFont
        definitionTextNode.containerFrame.size = CGSize(width: self.getWidth() * 1000 / 2.0, height: self.getHeight() * 1000)
        
        let textNode = SCNNode()
        textNode.geometry = definitionTextNode
        
      //  textNode.position = SCNVector3(x: -0.05, y: 0.0, z: 0.0)
        textNode.position = SCNVector3(x: Float(-1 * self.getWidth()/4.0), y:Float(-1 * self.getHeight()/2.0), z:0.0 )
        
        textNode.scale = SCNVector3(x: 0.001, y: 0.001, z: 0.001)
        // textNode.eulerAngles.x = -.pi/2
        
        self.definitionText = textNode
    }

    private func createPlane(width: CGFloat, height: CGFloat) {
        let plane = SCNPlane(width: width, height: height)
        plane.cornerRadius = 0.007
        plane.cornerSegmentCount = 3
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
      //  self.planeNode.runAction(self.imageHighlightAction)
    }
    
    func getPlane() -> SCNNode {
        return self.planeNode
    }
    
    func getText() -> SCNNode {
        return self.textNode
    }
    
    private func createMainText() {
        //text
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        let text = SCNText(string: self.text, extrusionDepth: 1)
        text.isWrapped = true
        text.materials = [material]
        
        text.flatness = 1.5
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
    
    func getDefinition(word: String) {
        let cleanWord = word.stripped
        let unencoded = "https://od-api.oxforddictionaries.com/api/v1/entries/en/" + cleanWord + "/regions=us"
        let url = NSURL(string: unencoded)!
        var request = URLRequest(url: url as URL)
        request.httpMethod = "GET"
        request.setValue(self.app_id, forHTTPHeaderField: "app_id")
        request.setValue(self.app_key, forHTTPHeaderField: "app_key")
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    if let array = convertedJsonIntoDict["results"] as? [Any]
                    {
                        if let results = array.first as? NSDictionary {
                            if let lexicalEntries = results["lexicalEntries"] as? [Any] {
                                if let lexicalResults = lexicalEntries.first as? NSDictionary {
                                    if let entries = lexicalResults["entries"] as? [Any] {
                                        if let entriesDict = entries.first as? NSDictionary {
                                            if let senses = entriesDict["senses"] as? [Any]
                                            {
                                                if let sensesDict = senses.first as? NSDictionary {
                                                    if let defArray = sensesDict["short_definitions"] as? [Any]
                                                    {
                                                        if let myDef = defArray.first as? String {
                                                            self.currentDef = myDef
                                                            DispatchQueue.main.async {
                                                                self.updateDefinition()
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        
        task.resume()
        
        
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

extension String {
    
    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
        return self.filter {okayChars.contains($0) }
    }
}
