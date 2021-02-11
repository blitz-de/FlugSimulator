//
//  GameScene.swift
//  FlyTheSkyBeleg Shared
//
//  Created by zacki on 07.02.21.
//

import SpriteKit
import GameplayKit

/**
 Given:
 
 FuelConsumbtion: 2400 liter / hr --->  40 liters / min ---> 2/3 liter/ sec ---->
 Fuel for 2 complete minutes: 80 liters per minute
 airPlaneSpeed: 837 km / hr ---> 23527.8 cm / second
 stallSpeed : 235 km / hr --> 6527.78 cm / sec

 ---- Speed of airplane is nothing rather than :
 
 speed = distance / time --- and hence we've distance and time, we can calcualte the speed in regard to distance
                  -- distance is equal the height of the screen 1334 ---> 13,34 cm
 */
class GameScene: SKScene, SKPhysicsContactDelegate {
 
    var leftAirplane = SKSpriteNode()
    //var rightAirplane = SKSpriteNode()

    var canMove = false
    var leftToMoveLeft = true
    var rightAirplaneToMoveRight = true
    
    var leftAirplaneAtRight = false
    var rightAirplaneAtLeft = false
    var centerPoint : CGFloat!
    var score = 0
    var distance: Double = 0
    
    let leftCloudMinimumX :CGFloat = -230//-280
    let leftCloudMaximumX : CGFloat = 230//-100
    
    let rightAirplaneMinimumX :CGFloat = 60
    let rightAirplaneMaximumX :CGFloat = 230
    
    var countDown = 1
    var stopEverything = true
    var scoreText = SKLabelNode()
    var distanceText = SKLabelNode() // show speed
    var fuelText = SKLabelNode()
    var speedText = SKLabelNode()
    
    var gameSettings = Settings.sharedInstance
    
    var airplaneVelocity: CGFloat = 23527.8 // in cm/sec
    var fuel: CGFloat = 80 // liters to fly for 2 complete minutes
    let stallSpeed: CGFloat = 6527.78 // velocity (cm/sec)
    var currentPosition: CGFloat = 13.34 // to calculate speed in regard to movement of position through the y-achse
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setUp()
        physicsWorld.contactDelegate = self
        Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.startCountDown), userInfo: nil, repeats: true)
        
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 0.8, secondNumber: 1.8)), target: self, selector: #selector(GameScene.leftSkyLine), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 0.8, secondNumber: 1.8)), target: self, selector: #selector(GameScene.rightSkyLine), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)
        let deadTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: deadTime) {
            Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.increaseScorePerSecond), userInfo: nil, repeats: true)
        }
        // to decrease fuel in response to time
        DispatchQueue.main.asyncAfter(deadline: deadTime) {
            Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.showFuelConsumbtion), userInfo: nil, repeats: true)
        }
        // to increase distance
        DispatchQueue.main.asyncAfter(deadline: deadTime) {
            Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.increaseDistance), userInfo: nil, repeats: true)
        }
        
        // to increase speed
        DispatchQueue.main.asyncAfter(deadline: deadTime) {
            Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.showSpeed), userInfo: nil, repeats: true)
        }
    }
    
    // COLLISION
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "leftAirplane" {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
       // firstBody.node?.removeFromParent()
        afterCollision()
        print(currentPosition, "current Airplane Velocity")
    }
        
    func decreasePosition() -> CGFloat { //
        currentPosition = currentPosition - 0.2*currentPosition
        currentPosition(newPosition: currentPosition)
        return airplaneVelocity
    }
    
    func currentPosition (newPosition: CGFloat) -> CGFloat{
        currentPosition = newPosition
        return currentPosition
    }
    

    func decreaseSpeed () -> CGFloat { //
        airplaneVelocity = airplaneVelocity - 0.2*airplaneVelocity
        currentSpeed(airplaneSpeed: airplaneVelocity)
        return airplaneVelocity
    }
    
    func decreaseFuelPerSecond () -> CGFloat {
        fuel = fuel - (2/3)
        return fuel
    }
    
    func currentFuel () -> CGFloat {

        print(fuel, "amount of fuel")
        if fuel <= 0  {
            let menuScene = SKScene(fileNamed: "MenuScene")!
            menuScene.scaleMode = .aspectFill
            view?.presentScene(menuScene, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(0.5)))
        }
        return fuel
    }
    func currentSpeed (airplaneSpeed: CGFloat) -> CGFloat{
        airplaneVelocity = airplaneSpeed
        return airplaneVelocity
    }
    
    func afterCollision()  {
        decreaseSpeed()
        decreasePosition()
        //newPosition()
        if gameSettings.highScore < score {
            gameSettings.distance = Int(increaseDistance()) // increaseDistance as current distance
            gameSettings.highScore = score
            
        }
        
        if airplaneVelocity <= stallSpeed {
            let menuScene = SKScene(fileNamed: "MenuScene")!
            menuScene.scaleMode = .aspectFill
            view?.presentScene(menuScene, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(0.5)))
        }
    }
    
    func setUp() {
        leftAirplane = self.childNode(withName: "leftAirplane") as! SKSpriteNode
        centerPoint = self.frame.size.width / self.frame.size.height
        
        leftAirplane.physicsBody?.categoryBitMask = ColliderType.AIRPLANE_COLLIDER
        leftAirplane.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER
        leftAirplane.physicsBody?.collisionBitMask = 0
   
        let scoreBackGround = SKShapeNode(rect:CGRect(x:-self.size.width/2 + 520 ,y:self.size.height/2 - 130 ,width:150,height:80), cornerRadius: 20)
        scoreBackGround.zPosition = 4
        scoreBackGround.fillColor = SKColor.black.withAlphaComponent(0.3)
        scoreBackGround.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(scoreBackGround)
        
        scoreText.name = "score"
        scoreText.fontName = "AvenirNext-Bold"
        scoreText.text = "0"
        scoreText.fontColor = SKColor.white
        scoreText.position = CGPoint(x: -self.size.width/2 + 600, y: self.size.height/2 - 105)
        scoreText.fontSize = 30
        scoreText.zPosition = 4
        addChild(scoreText)
        
        let distanceBackGround = SKShapeNode(rect:CGRect(x:-self.size.width/2 + 208 ,y:self.size.height/2 - 130 ,width:140,height:80), cornerRadius: 20)
        distanceBackGround.zPosition = 4
        distanceBackGround.fillColor = SKColor.black.withAlphaComponent(0.3)
        distanceBackGround.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(distanceBackGround)
        
        // distance showing
        distanceText.name = "distance"
        distanceText.fontName = "AvenirNext-Bold"
        distanceText.text = "0.0"
        distanceText.fontColor = SKColor.white
        distanceText.position = CGPoint(x: -self.size.width/2 + 280, y: self.size.height/2 - 105)
        distanceText.fontSize = 30
        distanceText.zPosition = 4
        addChild(distanceText)
        
        let fuelBackGround = SKShapeNode(rect:CGRect(x:-self.size.width/2 + 70 ,y:self.size.height/2 - 130 ,width:120,height:80), cornerRadius: 20)
        fuelBackGround.zPosition = 4
        fuelBackGround.fillColor = SKColor.black.withAlphaComponent(0.3)
        fuelBackGround.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(fuelBackGround)
        
        // fuel showing
        fuelText.name = "fuel"
        fuelText.fontName = "AvenirNext-Bold"
        fuelText.text = "0"
        fuelText.fontColor = SKColor.white
        fuelText.position = CGPoint(x: -self.size.width/2 + 129, y: self.size.height/2 - 105)
        fuelText.fontSize = 30
        fuelText.zPosition = 4
        addChild(fuelText)
        
        let speedBackGround = SKShapeNode(rect:CGRect(x:-self.size.width/2 + 360 ,y:self.size.height/2 - 130 ,width:140,height:80), cornerRadius: 20)
        speedBackGround.zPosition = 4
        speedBackGround.fillColor = SKColor.black.withAlphaComponent(0.3)
        speedBackGround.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(speedBackGround)
        
        // speed showing
        speedText.name = "fuel"
        speedText.fontName = "AvenirNext-Bold"
        speedText.text = "0"
        speedText.fontColor = SKColor.white
        speedText.position = CGPoint(x: -self.size.width/2 + 430, y: self.size.height/2 - 105)
        speedText.fontSize = 25
        speedText.zPosition = 4
        addChild(speedText)
        
        
    }
    
    var velocity: CGFloat = 0
    override func update(_ currentTime: TimeInterval) {
        if canMove{
            move(leftSide:leftToMoveLeft)
        }
        showSkyStrip()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            
            let touchLocation = touch.location(in: self)
            if touchLocation.x > centerPoint{
                if rightAirplaneAtLeft{
                    rightAirplaneAtLeft = false
                    rightAirplaneToMoveRight = true
                }else{
                    rightAirplaneAtLeft = true
                    rightAirplaneToMoveRight = false
                }
            }
            else{
                if leftAirplaneAtRight{
                    leftAirplaneAtRight = false
                    leftToMoveLeft = true
                }else{
                    leftAirplaneAtRight = true
                    leftToMoveLeft = false
                }

            }
            canMove = true
        }
    }
    
    // Mark: Show skyStrip
    func showSkyStrip() {

        enumerateChildNodes(withName: "cloud1", using: { (leftCloud, stop) in
            let cloud = leftCloud as! SKSpriteNode
            cloud.size = CGSize(width: 100, height: 100)
            cloud.position.y -= self.currentPosition(newPosition: self.currentPosition)
        })
        
        enumerateChildNodes(withName: "cloud2", using: { (rightCloud, stop) in
            let cloud = rightCloud as! SKSpriteNode
            cloud.size = CGSize(width: 100, height: 100)
            cloud.position.y -= self.currentPosition(newPosition: self.currentPosition)
            
        })
        
        enumerateChildNodes(withName: "sonderCloud", using: { (leftCloud, stop) in
            let cloud = leftCloud as! SKSpriteNode
            cloud.size = CGSize(width: 100, height: 100)
            cloud.position.y -= 15
        })
    }

    @objc func removeItems(){
       for child in children{
           if child.position.y < -self.size.height - 100{
               child.removeFromParent()
           }
       }
       
   }
   
    @objc func leftSkyLine () {
        if !stopEverything{
        let leftSkylineItem : SKSpriteNode!
        let randonNumber = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
        switch Int(randonNumber) {
        case 1...4:
            leftSkylineItem = SKSpriteNode(imageNamed: "cloud1")
            leftSkylineItem.name = "cloud1"
            leftSkylineItem.size = CGSize(width: 100, height: 100)

            break
        case 5...8:
            leftSkylineItem = SKSpriteNode(imageNamed: "cloud2")
            leftSkylineItem.size = CGSize(width: 100, height: 100)
            leftSkylineItem.name = "cloud2"
            break
        default:
            leftSkylineItem = SKSpriteNode(imageNamed: "sonderCloud")
            leftSkylineItem.name = "sonderCloud"
            leftSkylineItem.size = CGSize(width: 100, height: 100)

        }
            leftSkylineItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            leftSkylineItem.zPosition = 10
            
        let randomNum = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 10)
        switch Int(randomNum) {
        case 1...4:
            leftSkylineItem.position.x = -250
            break
        case 5...10:
            leftSkylineItem.position.x = -100
            break
        default:
            leftSkylineItem.position.x = -250
        }
        leftSkylineItem.position.y = 700
        leftSkylineItem.physicsBody = SKPhysicsBody(circleOfRadius: leftSkylineItem.size.height/2)
        leftSkylineItem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER
        leftSkylineItem.physicsBody?.collisionBitMask = 0
        leftSkylineItem.physicsBody?.affectedByGravity = false
        addChild(leftSkylineItem)
        }
    }
   
    @objc func rightSkyLine(){
        if !stopEverything{
        let rightSkylineItem : SKSpriteNode!
        let randonNumber = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
        switch Int(randonNumber) {
        case 1...4:
            rightSkylineItem = SKSpriteNode(imageNamed: "cloud1")
            rightSkylineItem.name = "cloud1"
            rightSkylineItem.size = CGSize(width: 100, height: 100)

            break
        case 5...8:
            rightSkylineItem = SKSpriteNode(imageNamed: "cloud2")
            rightSkylineItem.name = "cloud2"
            rightSkylineItem.size = CGSize(width: 100, height: 100)

            break
        default:
            rightSkylineItem = SKSpriteNode(imageNamed: "sonderCloud")
            rightSkylineItem.name = "sonderCloud"
            rightSkylineItem.size = CGSize(width: 100, height: 100)

        }
            rightSkylineItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            rightSkylineItem.zPosition = 10
        let randomNum = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 10)
        switch Int(randomNum) {
        case 1...4:
            rightSkylineItem.position.x = 250
            break
        case 5...10:
            rightSkylineItem.position.x = 100
            break
        default:
            rightSkylineItem.position.x = 250
        }
            rightSkylineItem.position.y = 700
            rightSkylineItem.position.y = 700
            rightSkylineItem.physicsBody = SKPhysicsBody(circleOfRadius: rightSkylineItem.size.height/2)
            rightSkylineItem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER
            rightSkylineItem.physicsBody?.collisionBitMask = 0
            rightSkylineItem.physicsBody?.affectedByGravity = false
        addChild(rightSkylineItem)
        }
    }
     
     
     @objc func startCountDown(){
         if countDown>0{
             if countDown < 4{
                 let countDownLabel = SKLabelNode()
                 countDownLabel.fontName = "AvenirNext-Bold"
                 countDownLabel.fontColor = SKColor.black
                 countDownLabel.fontSize = 300
                 countDownLabel.text = String(countDown)
                 countDownLabel.position = CGPoint(x: 0, y: 0)
                 countDownLabel.zPosition = 300
                 countDownLabel.name = "cLabel"
                 countDownLabel.horizontalAlignmentMode = .center
                 addChild(countDownLabel)
                 
                 let deadTime = DispatchTime.now() + 0.5
                 DispatchQueue.main.asyncAfter(deadline: deadTime, execute: {
                     countDownLabel.removeFromParent()
                 })
             }
             countDown += 1
             if countDown == 4 {
                 self.stopEverything = false
             }
         }
     }
     
     @objc func increaseScorePerSecond(){
         if !stopEverything{
             score += 1
            decreaseFuelPerSecond ()
             let scoreInsec = String(score) + " sec"
             scoreText.text = scoreInsec
            if currentFuel() <= 0 || airplaneVelocity <= stallSpeed {
                print("now stop")
                stopEverything = true
            }
         }
     }
    
    @objc func showFuelConsumbtion(){
        if !stopEverything{
//            fuel -= 0.6666666667
                let fuel = currentFuel()
                let fuelLeft: String = String (Int(fuel)) + " liter"
            fuelText.text = String(fuelLeft)
        }
    }
    
    @objc func showSpeed(){
        if !stopEverything{
//            // speed in cm / seconds -> km / hr [23527.8 * 0.036 km/hr]
            let speed = currentSpeed(airplaneSpeed: airplaneVelocity) * 0.036
                let speedo: String = String (Int(speed)) + " km/hr"
            speedText.text = String(speedo)
        }
    }
    
    @objc func increaseDistance() -> Double {
        if !stopEverything{
            // every second -> 23527.8 cm is crossed - 847 km/h - 0.235278 km/sec
            distance += 0.235278
            let distancey = Double(round(100*distance)/100)
            let distanceInKm: String = String (distancey) + " km"
            distanceText.text = distanceInKm
            return distance
        }
        return distance
    }
    
    func move(leftSide:Bool){
        if leftSide{
            leftAirplane.position.x -= 20
            if leftAirplane.position.x < leftCloudMinimumX{
                leftAirplane.position.x = leftCloudMinimumX
            }
        }else{
            leftAirplane.position.x += 20
            if leftAirplane.position.x > leftCloudMaximumX{
                leftAirplane.position.x = leftCloudMaximumX
            }

        }
    }
    
}
