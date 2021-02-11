//
//  Support.swift
//  FlyTheSkyBeleg iOS
//
//  Created by zacki on 07.02.21.
//

import Foundation
import UIKit

struct ColliderType {
    static let AIRPLANE_COLLIDER : UInt32 = 0

    static let ITEM_COLLIDER : UInt32 = 1
    static let ITEM_COLLIDER_1 : UInt32 = 2
}

class Helper : NSObject {
    
    func randomBetweenTwoNumbers(firstNumber : CGFloat ,  secondNumber : CGFloat) -> CGFloat{
        return CGFloat(arc4random())/CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
    }
}

class Settings {
    static let sharedInstance = Settings()
    private init () {
        
    }
    var highScore = 0
    var distance = 0
}
