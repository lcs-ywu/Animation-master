//
//  LindemayerSystemSketch.swift
//  Animation
//
//  Created by Russell Gordon on 2021-05-04.
//

import Foundation
import CanvasGraphics

// NOTE: This is a completely empty sketch; it can be used as a template.
struct Visualizer: Codable {
    
    // Identify what properties should be encoded to JSON
    enum CodingKeys: CodingKey {
        case system, length, reduction, angle, initialX, initialY, initialHeading
    }
    
    // Canvas to draw on
    var canvas: Canvas?
    
    // Tortoise to draw with
    var turtle: Tortoise?
    
    // MARK: L-system state
    var system: LindenmayerSystem
    
    // MARK: L-system rendering instructions
    
    // The length of the line segments used when drawing the system, at generation 0
    var length: Double
    
    // The length of the line segments used when drawing the system, at the latest generation
    var currentLength: Double
    
    // The factor by which to reduce the initial line segment length after each generation / word re-write
    var reduction: Double
    
    // The angle by which the turtle will turn left or right; in degrees.
    var angle: Degrees
    
    // Where the turtle begins drawing on the canvas
    var initialPosition: Point
    
    // The initial direction of the turtle
    var initialHeading: Degrees
    
    // Initializer to use when creating a visualization directly from code
    init(for system: LindenmayerSystem,
         on canvas: Canvas,
         length: Double,
         reduction: Double,
         angle: Degrees,
         initialPosition: Point,
         initialHeading: Degrees) {
        
        // Set the canvas we will draw on
        self.canvas = canvas
        
        // Create turtle to draw with
        turtle = Tortoise(drawingUpon: canvas)
        
        // MARK: Initialize L-system state
        self.system = system
        
        // MARK: Initialize L-system rendering instructions
        
        // The length of the line segments used when drawing the system, at generation 0
        self.length = length
        
        // The length of the line segments used when drawing the system, at the latest generation
        self.currentLength = length
        
        // The factor by which to reduce the initial line segment length after each generation / word re-write
        self.reduction = reduction
        
        // The angle by which the turtle will turn left or right; in degrees.
        self.angle = angle
        
        // Where the turtle begins drawing on the canvas
        self.initialPosition = initialPosition
        
        // The initial direction of the turtle
        self.initialHeading = initialHeading
        
    }
    
    // Create an instance of this type by decoding from JSON
    init(from decoder: Decoder) throws {
        
        // Use enumeration defined at top of structure to identify values to be decoded
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode each property
        system = try container.decode(LindenmayerSystem.self, forKey: .system)
        length = try container.decode(Double.self, forKey: .length)
        currentLength = length
        reduction = try container.decode(Double.self, forKey: .reduction)
        angle = Degrees(try container.decode(Double.self, forKey: .angle))
        let x = try container.decode(Int.self, forKey: .initialX)
        let y = try container.decode(Int.self, forKey: .initialY)
        initialPosition = Point(x: x, y: y)
        initialHeading = Degrees(try container.decode(Double.self, forKey: .initialHeading))
                
    }
    
    // Create an instance of this type, loaded from a specific file
    init(fromJSONFile fileName: String, drawingOn canvas: Canvas) {
        
        // Get a pointer to the file
        let url = Bundle.main.url(forResource: fileName, withExtension: "json")!
        
        // Load the contents of the JSON file
        let data = try! Data(contentsOf: url)
        
        // Convert the data from the JSON file into an instance of this type
        self = try! JSONDecoder().decode(Visualizer.self, from: data)

        // Set the canvas that should be drawn upon
        self.canvas = canvas
        self.turtle = Tortoise(drawingUpon: canvas)

    }
        
    // Encode an instance of this type to JSON
    public func encode(to encoder: Encoder) throws {
        
        // Use the enumeration defined at top of structure to identify values to be encoded
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode each property
        try container.encode(system, forKey: .system)
        try container.encode(length, forKey: .length)
        try container.encode(reduction, forKey: .reduction)
        try container.encode(angle, forKey: .angle)
        try container.encode(initialPosition.x, forKey: .initialX)
        try container.encode(initialPosition.y, forKey: .initialY)
        try container.encode(initialHeading, forKey: .initialHeading)
        
    }
    
    // Get the text of the JSON representation of this type
    func printJSONRepresentation() {
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            print(String(data: data, encoding: .utf8)!)
        } catch {
            print("Unable to encode visualized Lindenmayer system to JSON.")
        }
        
    }
    
    // Visualize the L-system on the canvas
    mutating func render() {
        
        // Regenerate the L-system so this instance is different (rules are re-applied based on random chance)
        system.generate()
        
        // MARK: Prepare for rendering L-system
        self.currentLength = self.length
        // Set the length based on number of generations
        if self.system.generations > 0 {
            for _ in 1...self.system.generations {
                self.currentLength /= self.reduction
            }
        }

        // Move to designated starting position
        canvas?.saveState()
        turtle?.penUp()
        turtle?.setPosition(to: initialPosition)
        turtle?.setHeading(to: initialHeading)
        turtle?.penDown()
        canvas?.restoreState()
        
        // DEBUG:
        print("Now rendering...\n")
        
        // Render the entire system
        for character in system.word {
            
            // Save the state of the canvas (no transformations)
            canvas?.saveState()
            
            // Bring canvas into same orientation and origin position as
            // it was when last character in the word was rendered
            turtle?.restoreStateOnCanvas()
            
            // Render based on this character
            switch character {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                // Placeholder for changing colour
                break
            case "+":
                // Turn to the left
                turtle?.left(by: angle)
            case "-":
                // Turn to the right
                turtle?.right(by: angle)
            case "[":
                // Save position and heading
                turtle?.saveState()
            case "]":
                // Restore position and heading
                turtle?.restoreState()
            case "B":
                // Render a small berry
                canvas?.drawEllipse(at: Point(x: 0, y: 0), width: 5, height: 5)
            default:
                // Any other character means move forward
                turtle?.forward(steps: Int(round(currentLength)))
                break
                
            }
            
            // Restore the state of the canvas (no transformations)
            canvas?.restoreState()
            
        }
        
    }
    
}
