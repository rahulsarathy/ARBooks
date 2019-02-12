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
        planeNode = SCNPlane(width: width, height: height)
        self.renderSelf();
        super.init();
    }
    
    private func renderSelf() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
