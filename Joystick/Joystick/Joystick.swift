//
//  AAKJoystick.swift
//  Joystick
//
//  Created by Alexey Krzywicki on 22.08.2023.
//

import Foundation
import SpriteKit
import UIKit

// MARK: - AKJoystick
/// Custom joystick control for sprite movement.
class AAKJoystick: SKNode {
    
    // MARK: - Properties
    private let backNode, frontNode: SKSpriteNode
    /// Feedback generator to vibrate on touch
    let generator = UIImpactFeedbackGenerator(style: .soft)
    /// Duration for the thumb to spring back to its original position.
    var frontNodeSpringBackDuration: Double = 0.3
    var isTracking: Bool = false {
        didSet {
            generator.impactOccurred()
        }
    }
    var velocity: CGPoint = CGPoint(x: 0, y: 0)
    var travelLimit: CGPoint = CGPoint(x: 0, y: 0)
    var angularVelocity: CGFloat = 0.0
    var isYAxisLock = false
    var isXAxisLock = false
    
    // MARK: - Initializers
    /// Initialize the joystick with optional thumb and backdrop nodes.
    ///
    /// - Parameters:
    ///   - thumbNode: The thumb node.
    ///   - backdropNode: The backdrop node.
    init(frontNode: SKSpriteNode = SKSpriteNode(imageNamed: "frontNode"), backNode: SKSpriteNode = SKSpriteNode(imageNamed: "backNode")) {
        self.frontNode = frontNode
        self.backNode = backNode
        super.init()
        
        self.addChild(self.backNode)
        self.addChild(self.frontNode)
        self.backNode.zPosition = 100
        self.frontNode.zPosition = 101
        
        resetAlpha()
        
        self.isUserInteractionEnabled = true
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Touch events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint: CGPoint = touch.location(in: self)
            if !isTracking && frontNode.frame.contains(touchPoint) {
                isTracking = true
                // Highlight on touch
                self.backNode.alpha = 0.3
                self.frontNode.alpha = 0.4
            }
        }
    }
    
    /// Handle the movement of the control thumb node in response to touch events.
    ///
    /// - Parameters:
    ///   - touches: A set of UITouch objects representing the touches that have occurred.
    ///   - event: An optional UIEvent object representing the event that triggered the touches.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            
            if isTracking && distanceBetween(touchPoint, frontNode.position) < Float(frontNode.size.width) {
                if distanceBetween(touchPoint, anchorPointInPoints()) <= Float(frontNode.size.width) {
                    // Calculate the difference between the touch point and anchor point in x and y directions
                    let moveDifference = CGPoint(x: touchPoint.x - anchorPointInPoints().x, y: touchPoint.y - anchorPointInPoints().y)
                    
                    if isXAxisLock {
                        frontNode.position = CGPoint(x: 0, y: anchorPointInPoints().y + moveDifference.y)
                    } else if isYAxisLock {
                        frontNode.position = CGPoint(x: anchorPointInPoints().x + moveDifference.x, y: 0)
                    } else {
                        frontNode.position = CGPoint(x: anchorPointInPoints().x + moveDifference.x, y: anchorPointInPoints().y + moveDifference.y)
                    }
                } else {
                    // Calculate vector components and adjust thumb node position based on magnitude
                    /// Horizontal component of the vector from the anchor point to the touch point's x-coordinate.
                    let vX = Double(touchPoint.x) - Double(anchorPointInPoints().x)

                    /// Vertical component of the vector from the anchor point to the touch point's y-coordinate.
                    let vY = Double(touchPoint.y) - Double(anchorPointInPoints().y)

                    /// Magnitude of the vector formed by the components `vX` and `vY`.
                    let magV = sqrt(vX * vX + vY * vY)

                    /// New x-coordinate after adjusting the anchor point by a fraction of `vX` relative to `magV` and thumb node size.
                    let aX = Double(anchorPointInPoints().x) + vX / magV * Double(frontNode.size.width)

                    /// New y-coordinate after adjusting the anchor point by a fraction of `vY` relative to `magV` and thumb node size.
                    let aY = Double(anchorPointInPoints().y) + vY / magV * Double(frontNode.size.width)

                    
                    if isXAxisLock {
                        frontNode.position = CGPoint(x: 0, y: CGFloat(aY))
                    } else if isYAxisLock {
                        frontNode.position = CGPoint(x: CGFloat(aX), y: 0)
                    } else {
                        frontNode.position = CGPoint(x: CGFloat(aX), y: CGFloat(aY))
                    }
                }
            }
            
            // Calculate velocity components and angular velocity based on thumb node position
            if isXAxisLock {
                velocity = CGPoint(x: 0, y: frontNode.position.y - anchorPointInPoints().y)
                angularVelocity = -atan2(0, frontNode.position.y - anchorPointInPoints().y)
            } else if isYAxisLock {
                velocity = CGPoint(x: frontNode.position.x - anchorPointInPoints().x, y: 0)
                angularVelocity = -atan2(frontNode.position.x - anchorPointInPoints().x, 0)
            } else {
                velocity = CGPoint(x: frontNode.position.x - anchorPointInPoints().x, y: frontNode.position.y - anchorPointInPoints().y)
                angularVelocity = -atan2(frontNode.position.x - anchorPointInPoints().x, frontNode.position.y - anchorPointInPoints().y)
            }

        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetVelocity()
        resetAlpha()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetVelocity()
        resetAlpha()
    }

    // MARK: - Private methods
    /// Calculate the Euclidean distance between two CGPoint points.
    ///
    /// - Parameters:
    ///   - point1: The first CGPoint.
    ///   - point2: The second CGPoint.
    /// - Returns: The Euclidean distance between the two points.
    private func distanceBetween(_ point1: CGPoint, _ point2: CGPoint) -> Float {
        let dx = Float(point1.x - point2.x)
        let dy = Float(point1.y - point2.y)
        return sqrtf(dx * dx + dy * dy)
    }
    
    /// Reset the joystick's tracking, velocity, and spring back the thumb.
    private func resetVelocity() {
        isTracking = false
        velocity = CGPoint.zero
        let easeOut: SKAction = SKAction.move(to: anchorPointInPoints(), duration: frontNodeSpringBackDuration)
        easeOut.timingMode = SKActionTimingMode.easeOut
        frontNode.run(easeOut)
    }
    /// Get the anchor point in points.
    ///
    /// - Returns: The anchor point.
    private func anchorPointInPoints() -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    /// Reset alpha to normal state.
    ///
    private func resetAlpha() {
        self.backNode.alpha = 0.1
        self.frontNode.alpha = 0.15
    }
}
