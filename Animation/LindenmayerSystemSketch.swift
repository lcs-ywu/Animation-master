import Foundation
import CanvasGraphics

// NOTE: This is a completely empty sketch; it can be used as a template.
class LindenmayerSystemSketch: NSObject, Sketchable {
    
    // NOTE: Every sketch must contain an object of type Canvas named 'canvas'
    //       Therefore, the line immediately below must always be present.
    var canvas: Canvas
    
    // This function runs once
    override init() {
        
        // Create canvas object – specify size
        canvas = Canvas(width: 500, height: 500)
        
        // Enable faster rendering
        canvas.highPerformance = true
        
        // Define the L-system
        var system = LindenmayerSystem(axiom: "[F]-[F]--[F]-[F]-[F]--[F]-", rules: [
                       "F": [
                           Successor(odds: 1, text: "XX[-XG][+XXG]XG"),
                           Successor(odds: 1, text: "XG[-XXG][+XG]XXXG"),
                           Successor(odds: 1, text: "XXX[-XXXG][+XXG]XXG"),
                         ],
                       "G": [
                           Successor(odds: 1, text: "XX[-XB][+XXB]XX"),
                           Successor(odds: 1, text: "X[-XXB][+XB]XXX"),
                           Successor(odds: 1, text: "XXX[-XXXB][+XXB]X"),
                         ],
        ], generations: 2)

        // Visualize the system
        var visualizedSystem = Visualizer(for: system, on: canvas, length: 20, reduction: 1.1, angle: 45, initialPosition: Point(x: 250, y: 250), initialHeading: 0)
        
        // Render the system
        visualizedSystem.render()
        
//        visualizedSystem.printJSONRepresentation()
        
    }
    
    // This function runs repeatedly, forever, to create the animated effect
    func draw() {
        
        // Nothing is being animated, so nothing needed here
        
    }
    
}
