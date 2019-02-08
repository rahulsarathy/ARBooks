//
//  OpenCVViewController.swift
//  ChessboardDetection
//
//  Created by Rahul Sarathy on 2/8/19.
//  Copyright © 2019 Rahul Sarathy. All rights reserved.
//

import UIKit
import ARKit

class OpenCVViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate{
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var mainImage: UIImageView!
    
    var displayLink: CADisplayLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.session.delegate = self
        
        self.useArKit()
        self.useOpenCV()
    }
    @IBAction func goToARKit(_ sender: Any) {
        self.sceneView.session.pause()
        self.displayLink?.isPaused = true
        dismiss(animated: true, completion: nil)
    }
    
    private func useArKit() {
        let configuration = ARWorldTrackingConfiguration()
        self.sceneView.session.run(configuration)
    }
    
    private func useOpenCV() {
        self.displayLink?.isPaused = false
        self.displayLink = CADisplayLink(target: self, selector: #selector(self.displayLinkDidFire))
        self.displayLink?.preferredFramesPerSecond = self.sceneView.preferredFramesPerSecond
        
        displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    
    @objc func displayLinkDidFire(timer: CADisplayLink) {
        // Our capturer polls the ARSCNView's snapshot for processed AR video content, and then copies the result into a CVPixelBuffer.
        // This process is not ideal, but it is the most straightforward way to capture the output of SceneKit.
        let myImage = self.sceneView.snapshot()
        
        //let openCVWrapper = OpenCVWrapper()
        
        //let arImage = openCVWrapper.addAR(myImage)
        // let markedImage = openCVWrapper.findMarkers(myImage)
        
        let markedImage = OpenCVWrapper.findMarkers(myImage)
        
        DispatchQueue.main.async {
            self.mainImage.image = markedImage
        }
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
