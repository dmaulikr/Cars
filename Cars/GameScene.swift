//
//  GameScene.swift
//  Cars
//
//  Created by Arnau Timoneda Heredia on 30/5/17.
//  Copyright © 2017 Arnau Timoneda Heredia. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var car:Car!
    
    //X central point position of road tracks.
    let POSITION_TRACK_1: CGFloat = 0.275 //103,125
    let POSITION_TRACK_2: CGFloat = 0.5 //187,5
    let POSITION_TRACK_3: CGFloat = 0.725 //271,875
    
    let POSITION_MOVE:CGFloat = 0.225
    
    var textureEnemyUp = SKTexture()
    var textureEnemyDown = SKTexture()
    var blueTextureEnemyUp = SKTexture()
    var blueTextureEnemyDown = SKTexture()
    var greenTextureEnemyUp = SKTexture()
    var greenTextureEnemyDown = SKTexture()
    var yellowTextureEnemyUp = SKTexture()
    var yellowTextureEnemyDown = SKTexture()
    
    let categoryCar: UInt32 = 1 << 0
    let categoryEnemy: UInt32 = 1 << 1
    
    let enemys = SKNode()
    let roads = SKNode()
    
    var xTrackPositions: [UInt32:CGFloat] = [:]
    var enemyColorTextures: [UInt32:String] = [:]
    
    var reset = false
    
    var score = NSInteger()
    let scoreLabel = SKLabelNode()
    
    var lives:Int = 3
    var live1 = SKSpriteNode()
    var live2 = SKSpriteNode()
    var live3 = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.clear
        
        self.physicsWorld.contactDelegate = self
        self.initializeApp()
        
        let textureCarUp = SKTexture(imageNamed: "CarUp")
        textureCarUp.filteringMode = SKTextureFilteringMode.nearest
        
        let textureCarDown = SKTexture(imageNamed: "CarDown")
        textureCarDown.filteringMode = SKTextureFilteringMode.nearest
        
        //Banner
        let infoBar = SKSpriteNode(color: UIColor.brown , size: CGSize(width: self.size.width, height: 100))
        infoBar.anchorPoint = CGPoint.zero
        infoBar.position = CGPoint(x: 0, y:self.size.height - 100)
        infoBar.zPosition = 11
        self.addChild(infoBar)
        
        let blackLine = SKSpriteNode(color: UIColor.black, size: CGSize(width: self.size.width, height: 5))
        blackLine.anchorPoint = CGPoint.zero
        blackLine.position = CGPoint(x: 0, y: self.size.height - 100)
        blackLine.zPosition = 12
        self.addChild(blackLine)
        
        self.score = 0
        self.scoreLabel.fontName = "Arial"
        self.scoreLabel.fontSize = 40
        self.scoreLabel.alpha = 1
        self.scoreLabel.position = CGPoint(x: self.frame.width*0.85, y: self.frame.height-70)
        self.scoreLabel.zPosition = 12
        self.scoreLabel.text = "Score: \(score)"
        self.addChild(self.scoreLabel)
        
        live1 = SKSpriteNode(texture: textureCarUp)
        live1.setScale(0.6)
        live1.position = CGPoint(x: self.frame.width*0.1, y: self.frame.height-60)
        live1.zPosition = 12
        self.addChild(live1)
        live2 = SKSpriteNode(texture: textureCarUp)
        live2.setScale(0.6)
        live2.position = CGPoint(x: self.frame.width*0.2, y: self.frame.height-60)
        live2.zPosition = 12
        self.addChild(live2)
        live3 = SKSpriteNode(texture: textureCarUp)
        live3.setScale(0.6)
        live3.position = CGPoint(x: self.frame.width*0.3, y: self.frame.height-60)
        live3.zPosition = 12
        self.addChild(live3)

        

        //Añadir la carretera
        let textureRoad = SKTexture(imageNamed: "Road")
        textureRoad.filteringMode = SKTextureFilteringMode.nearest
        
        let roadMovement = SKAction.moveBy(x: 0.0, y: -textureRoad.size().height, duration: 3)
        let resetRoad = SKAction.moveBy(x: 0.0, y: textureRoad.size().height, duration: 0.0)
        let continuousRoadMovement = SKAction.repeatForever(SKAction.sequence([roadMovement, resetRoad]))
        
        for i:Int in 0 ..< Int(2 + self.frame.size.height/textureRoad.size().height) {
            var road = SKSpriteNode(texture: textureRoad)
            road = SKSpriteNode(texture: textureRoad)
            road.anchorPoint = CGPoint.zero
            road.position = CGPoint(x: 0, y: i*Int(road.size.height))
            road.size.width = self.size.width
            road.zPosition = -10
            road.run(continuousRoadMovement)
            roads.addChild(road)
        }
        self.addChild(roads)
        
        
        /* to refactor textures */
        blueTextureEnemyUp = SKTexture(imageNamed: "BlueEnemyUp")
        blueTextureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
        
        blueTextureEnemyDown = SKTexture(imageNamed: "BlueEnemyDown")
        blueTextureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
        
        greenTextureEnemyUp = SKTexture(imageNamed: "GreenEnemyUp")
        greenTextureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
        
        greenTextureEnemyDown = SKTexture(imageNamed: "GreenEnemyDown")
        greenTextureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
        
        yellowTextureEnemyUp = SKTexture(imageNamed: "YellowEnemyUp")
        yellowTextureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
        
        yellowTextureEnemyDown = SKTexture(imageNamed: "YellowEnemyDown")
        yellowTextureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
        /* end */
        
        let carMovement = SKAction.animate(with: [textureCarDown, textureCarUp], timePerFrame: 0.30)
        let driving = SKAction.repeatForever(carMovement)
        
        car = Car()
        car.node = SKSpriteNode(texture: textureCarUp)
        
        car.node.position = CGPoint(x: self.frame.size.width/2, y: 100)
        car.node.zPosition = 11
        
        //Colisiones
        //car.node.physicsBody? = false
        car.node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: car.node.size.width*0.8, height: car.node.size.height*0.8))
        car.node.physicsBody?.affectedByGravity = false
        car.node.physicsBody?.categoryBitMask = categoryCar
        car.node.physicsBody?.collisionBitMask = categoryEnemy
        car.node.physicsBody?.contactTestBitMask = categoryEnemy
        
        car.node.run(driving)
        
        self.addChild(car.node)
        
        //Enemigos
        textureEnemyUp = SKTexture(imageNamed: "enemyUp")
        textureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
        
        textureEnemyDown = SKTexture(imageNamed: "enemyDown")
        textureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
        self.addChild(enemys)
        self.startEnemyCycle()
 
        print("la pantalla mide \(self.frame.size)")
    }
    
    func startEnemyCycle(){
        let createEnemy = SKAction.run({ () in self.manageEnemies()})
        let delayEnemies = SKAction.wait(forDuration: 0.8)
        let createNextEnemy = SKAction.sequence([createEnemy, delayEnemies])
        let continuousEnemies = SKAction.repeatForever(createNextEnemy)
        enemys.run(continuousEnemies)
    }
    
    func manageEnemies(){
        let textures = self.getRandomEnemyTexture()
        
        let enemyMovement = SKAction.animate(with:textures, timePerFrame: 0.30)
        let drivingEnemy = SKAction.repeatForever(enemyMovement)
        
        let enemy = SKSpriteNode(texture: textures[0])
        
        enemy.position = CGPoint(x: xTrackPositions[arc4random_uniform(3) + 1]! , y: self.frame.height + enemy.size.height)
        enemy.zPosition = 10
        enemy.run(drivingEnemy)
        
        //Colisions
        enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:enemy.size.width*0.8,height:enemy.size.height*0.8))
        //enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = categoryEnemy
        enemy.physicsBody?.collisionBitMask = categoryCar
        enemy.physicsBody?.contactTestBitMask = categoryCar
        
        let enemyRide = SKAction.move(to: CGPoint(x: enemy.position.x, y: -enemy.frame.height) , duration: 4)
        let removeEnemy = SKAction.removeFromParent()
        
        let enemyCycle = SKAction.sequence([enemyRide, removeEnemy])
        
        enemy.run(enemyCycle)
        enemys.addChild(enemy)
        if self.enemys.speed < 4 {
            self.enemys.speed = self.enemys.speed + 0.02
        }
        if(self.car.node.speed < 2){
            self.car.node.speed = self.car.node.speed + 0.01
        }
        if(self.roads.speed < 2){
            self.roads.speed = self.roads.speed + 0.02
        }
        self.score = self.score + 1
        self.scoreLabel.text = "Score: \(score)"
        //print("SPEED ENEMY:::\(self.enemys.speed) AND CAR::\(self.car.node.speed)")
    }

    /* Move the car between tracks */
    func moveCarTo(position:Car.Status){
        var pos = POSITION_TRACK_2
        switch position {
        case .left:
            pos = POSITION_TRACK_1
        case .center:
            pos = POSITION_TRACK_2
        case .right:
            pos = POSITION_TRACK_3
        }
        let carTurn = SKAction.move(to: CGPoint(x:(self.frame.size.width) * pos, y: 100), duration: 0.5)
        self.car.node.run(carTurn)
    }
    
    /* Fix tracks positions and defines enemies color */
    func initializeApp(){
        xTrackPositions[1] = POSITION_TRACK_1 * self.frame.size.width
        xTrackPositions[2] = POSITION_TRACK_2 * self.frame.size.width
        xTrackPositions[3] = POSITION_TRACK_3 * self.frame.size.width
        
        enemyColorTextures[1] = "Red"
        enemyColorTextures[2] = "Blue"
        enemyColorTextures[3] = "Yellow"
        enemyColorTextures[4] = "Green"
    }
    
    /* Get random color car enemy */
    func getRandomEnemyTexture() -> [SKTexture] {
        var result:[SKTexture]
        let color = enemyColorTextures[arc4random_uniform(4) + 1]!
        switch color {
        case "Yellow":
            result = [yellowTextureEnemyUp, yellowTextureEnemyDown]
        case "Blue":
            result = [blueTextureEnemyUp, blueTextureEnemyDown]
        case "Red":
            result = [textureEnemyUp, textureEnemyDown]
        case "Green":
            result = [greenTextureEnemyUp, greenTextureEnemyDown]
        default:
            result = [textureEnemyUp, textureEnemyDown]
        }
        return result
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        self.lives -= 1
        if lives == 0 {
            live1.isHidden = true
            self.stopMovement()
            self.reset = true
        } else {
            switch(self.lives) {
            case 2:
                live3.isHidden = true
            case 1:
                live2.isHidden = true
            default:
                break
            }
            
            self.pauseMovement()
            let continueGame = SKAction.run({ () in self.restartGame()})
            let delayRestart = SKAction.wait(forDuration: 1)
            let cont = SKAction.sequence([delayRestart, continueGame])
            self.run(cont)
            
            car.node.run(delayRestart)
            //TODO activar modo invulnerable y parpadear
        }
    }
    
    /* When the game starts, this function prepare the scenario */
    func newGame(){
        self.car.node.position = CGPoint(x: self.frame.size.width/2, y: 100)
        enemys.speed = 1
        car.node.speed = 1
        roads.speed = 1
        self.score = 0
        self.lives = 3
        self.live1.isHidden = false
        self.live2.isHidden = false
        self.live3.isHidden = false
        self.scoreLabel.text = "Score: \(score)"
        self.startEnemyCycle()
    }
    
    /* Restart screen movement between lives */
    func restartGame(){
        self.car.node.position = CGPoint(x: self.frame.size.width/2, y: 100)
        car.node.speed = 1
        self.startEnemyCycle()
    }
    
    /* Pause screen movement between lives */
    func pauseMovement(){
        car.node.speed = 0
        enemys.removeAllChildren()
        enemys.removeAllActions()
    }
    
    /* Stop screen movements when the game ends */
    func stopMovement(){
        enemys.speed = 0
        car.node.speed = 0
        roads.speed = 0
        enemys.removeAllChildren()
        enemys.removeAllActions()
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("he tocado en: \(touches.first!.location(in: self.view))")
        if(self.reset){
            self.reset = false
            self.newGame()
        } else {
        
            if touches.first!.location(in: self.view).x < (self.view?.frame.width)!/2 {
                self.car.turnLeft()
            
            } else {
                self.car.turnRight()
            //self.moveCarTo(position: POSITION_MOVE)
            }
            self.moveCarTo(position: self.car.status)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }

}

//ajustar el angle en que mira el cotxe despres de la colisio
