//
//  GameScene.swift
//  Joystick
//
//  Created by Alexey Krzywicki on 22.08.2023.
//


import SpriteKit
import GameplayKit

class GameScene: SKScene {

    let moveJoystick = AAKJoystick()
    let shootJoystick = AAKJoystick()
    
    override func didMove(to view: SKView) {
        addChild(moveJoystick)
        moveJoystick.position = CGPoint(x: 90, y: 90)
        moveJoystick.isXAxisLock = false
        
        addChild(shootJoystick)
        shootJoystick.position = CGPoint(x: view.frame.width-90, y: 90)
        shootJoystick.isYAxisLock = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        print("move angularVelocity - \(moveJoystick.angularVelocity)")
        print("move velocity.x - \(moveJoystick.velocity.x)")
        print("move velocity.y - \(moveJoystick.velocity.y)")
        print()
        print("shoot angularVelocity - \(shootJoystick.angularVelocity)")
        print("shoot velocity.x - \(shootJoystick.velocity.x)")
        print("shoot velocity.y - \(shootJoystick.velocity.y)")
    }
}
