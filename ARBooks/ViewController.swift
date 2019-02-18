//
//  ViewController.swift
//  ChessboardDetection
//
//  Created by Rahul Sarathy on 2/1/19.
//  Copyright © 2019 Rahul Sarathy. All rights reserved.
//

import UIKit
import ARKit

let MARKER_SIZE_IN_METERS : CGFloat = 0.2032;


class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var xValue: UITextField!
    @IBOutlet weak var yValue: UITextField!
    @IBOutlet weak var zValue: UITextField!
    
    var showPlane: Bool = false
    
    let sample1 = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    
    let sample = "Oxymoron"
    let app_id = "faa06bfa"
    let app_key = "a2fe9da627b566e4ce05ca33490639a5"
    
    var currentDef: String? = nil
    var pageText : SCNNode! = nil
    var myPage : BookPage! = nil
    private var originNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.session.delegate = self
        
        self.useArKit()
        self.getDefinition(word: sample)
        
        myPage = BookPage(width: MARKER_SIZE_IN_METERS, height: MARKER_SIZE_IN_METERS, text: sample)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let hitResults = sceneView.hitTest(touch.location(in: sceneView), options: [:])
            if !hitResults.isEmpty {
                guard let hitResult = hitResults.first else {
                    return
                }
                vibrateWithHaptic()
                let node = hitResult.node
                showDefinition(myNode: node)
               // node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            }
    }
    
    func showDefinition(myNode: SCNNode) {
        
    }
    
    func getDefinition(word:String) {
        let unencoded = "https://od-api.oxforddictionaries.com/api/v1/entries/en/" + word + "/regions=us"
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
    
    func vibrateWithHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        
        generator.impactOccurred()
    }

    
    private func useArKit() {
      //  sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
        let configuration = ARWorldTrackingConfiguration()
        self.sceneView.session.run(configuration)
    }
    
    @IBAction func goTOOpenCV(_ sender: Any) {
        performSegue(withIdentifier: "goToCV", sender: self)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        localizeMarker()
    }

    private func localizeMarker() {
        
        guard let frame = self.sceneView.session.currentFrame else { return }
        
        let pixelBuffer = frame.capturedImage
        
        let intrinsics = frame.camera.intrinsics
        
        let transMatrix = OpenCVWrapper.transformMatrix(from: pixelBuffer, withIntrinsics: intrinsics, andMarkerSize: Float64(MARKER_SIZE_IN_METERS));
        
        if (SCNMatrix4IsIdentity(transMatrix)) {
            return
        }
        
        let cameraTransform = SCNMatrix4.init(frame.camera.transform);
        //Multiply camera current position with translation matrix
        let targTransform = SCNMatrix4Mult(transMatrix, cameraTransform);
        originNode.setWorldTransform(targTransform)
        if !sceneView.scene.rootNode.childNodes.contains(originNode)
        {
            sceneView.scene.rootNode.addChildNode(originNode)
        }
        if !(showPlane)
        {
            originNode.addChildNode(myPage.getPlane())
            originNode.addChildNode(myPage.getText())
            myPage.highlight()
            showPlane = true
        }
    }

}

