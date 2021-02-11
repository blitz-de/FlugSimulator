//
//  MenuScene.swift
//  FlyTheSkyBeleg iOS
//
//  Created by zacki on 07.02.21.
//

import Foundation
import SpriteKit

class MenuScene: SKScene {
    var startGame = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var gameSettings = Settings.sharedInstance
    var distanceLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        startGame = self.childNode(withName: "startGame") as! SKLabelNode
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel.text = "Time: \(gameSettings.highScore)"
        
        distanceLabel = self.childNode(withName: "distanceLabel") as! SKLabelNode
        distanceLabel.text = "Distance: \(gameSettings.distance)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            if atPoint(touchLocation).name == "startGame" { // when the user presses the start game label
                let gameScene = SKScene(fileNamed: "GameScene")!
                gameScene.scaleMode = .aspectFill
                view?.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(2)))
            }
        }
    }
}

