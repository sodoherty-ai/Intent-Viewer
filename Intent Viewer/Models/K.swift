//
//  K.swift
//  Intent Viewer
//
//  Created by Simon O'Doherty on 28/02/2021.
//

import Foundation
import ChameleonFramework

struct K {

    static let intentCell = "intentCell"
    static let intentLabel = "Intent:"
    
    struct color {
        static let intentbg = UIColor.flatMint()
        static let examplebg = UIColor.flatPowderBlue()
        
        static let intentfg = UIColor.flatBlack()
        static let examplefg = UIColor.flatBlack()
    }
    
    struct api {
        static var version: String?
        static var apikey: String?
        static var endpoint: String?
        static var workspaceid: String?
    }
    
    struct storyboard {
        static let intents = "StoryboardIntents"
        static let arView = "StoryboardArView"
    }
    
}
