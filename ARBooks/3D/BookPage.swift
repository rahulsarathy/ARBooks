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
    
    private let planeNode: SCNPlane
    
    init(width:CGFloat, height: CGFloat) {
        self.planeNode = SCNPlane(width: width, height: height)
        super.init();
        self.renderSelf();

    }
    
    private func renderSelf() {
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.white
        self.geometry = self.planeNode
        self.geometry?.materials = [mat]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
