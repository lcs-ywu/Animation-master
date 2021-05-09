import Foundation
import CanvasGraphics
// Make code in the L-System more readable...
typealias Predecessor = Character
// What replaces a predecessor in an L-system
struct Successor {
    // The likelihood of this successor being applied, when combined with other successors assigned to a given predecessor
    let odds: Int
    // The text that replaces the predecessor in the L-system's word
    let text: String
}
// NOTE: This is a completely empty sketch; it can be used as a template.
class LindenmayerSystemSketch: NSObject, Sketchable {
    // NOTE: Every sketch must contain an object of type Canvas named 'canvas'
    //       Therefore, the line immediately below must always be present.
    var canvas: Canvas
    // Tortoise to draw with
    let turtle: Tortoise
    // MARK: L-system state
    
    // What the system will draw, without any re-writes based upon production rules
    let axiom: String
    // What the system will draw, after re-writes based upon production rules
    var word: String
    // How many times to re-write the word, based upon production rules
    let generations: Int
    // The rules the define how the word is re-written with each new generation
    let rules: [Predecessor: [Successor]]
    // MARK: L-system rendering instructions
    
    // The length of the line segments used when drawing the system, at generation 0
    var length: Double
    // The factor by which to reduce the initial line segment length after each generation / word re-write
    let reduction: Double
    // The angle by which the turtle will turn left or right; in degrees.
    let angle: Degrees
    // Where the turtle begins drawing on the canvas
    let initialPosition: Point
    // The initial direction of the turtle
    let initialHeading: Degrees
    // This function runs once
    override init() {
        // MARK: Canvas and turtle setup
        
        // Create canvas object – specify size
        canvas = Canvas(width: 500, height: 500)
        // Draw slowly
        canvas.framesPerSecond = 15
        // Create turtle to draw with
        turtle = Tortoise(drawingUpon: canvas)
        // MARK: Initialize L-system state
        
        // What the system will draw, without any re-writes based upon production rules
        axiom = "EEF"
        // DEBUG: What's the word?
        print("Axiom is:")
        print("\(axiom)")
        // Generation 0 – we begin with the word the same as the axiom
        word = axiom
        // How many times to re-write the word, based upon production rules
        generations = 5
        // The rules the define how the word is re-written with each new generation
        rules = [
            "F": [
                Successor(odds: 3, text: "XXG[-G][+G]"),
                Successor(odds: 3, text: "XG[--G][+G]"),
                Successor(odds: 3, text: "XXXG[-G][++G]"),
            ],
            "G": [
                Successor(odds: 3, text: "XXH[-H][+H]"),
                Successor(odds: 3, text: "XH[--H][+H]"),
                Successor(odds: 3, text: "XXXH[-H][++H]"),
            ],
            "H": [
                Successor(odds: 3, text: "XXI[-I][+I]"),
                Successor(odds: 3, text: "XI[--I][+I]"),
                Successor(odds: 3, text: "XXXI[-I][++I]"),
            ],
            "I": [
                Successor(odds: 3, text: "XXJ[-J][+J]"),
                Successor(odds: 3, text: "XJ[--J][+J]"),
                Successor(odds: 3, text: "XXXJ[-J][++J]"),
            ],
            "J": [
                Successor(odds: 3, text: "XXX[-XXB][+XB]"),
                Successor(odds: 3, text: "XX[--XXB][+XXX]"),
                Successor(odds: 3, text: "XXXX[-XB][++XXB]"),
            ],
        ]
        // Only write a new word if there are more than 0 generations
        if generations > 0 {
            // Re-write the word
            for generation in 1...generations {
                // Create an empty new word
                var newWord = ""
                // Replace each character in the word, based on the production rules
                for character in word {
                    // When successor rule(s) exist for a predecessor character, use them...
                    if let ruleSet = rules[character] {
                        // When there is only one possible sucessor for the predecessor, just do the straight replacement
                        if ruleSet.count == 1 {
                            newWord.append(ruleSet.first!.text)
                        } else {
                            // There are multiple possible rules that could be applied
                            // Use odds...
                            var total = 0
                            for rule in ruleSet {
                                total += rule.odds
                            }
                            // Get a random integer between 1 and the total odds for this rule set
                            let randomValue = Int.random(in: 1...total)
                            // Find the correct successor rule to apply
                            var runningTotal = 0
                            for rule in ruleSet {
                                runningTotal += rule.odds
                                // See if this current rule is the one to be applied
                                if randomValue <= runningTotal {
                                    newWord.append(rule.text)
                                    break // Stop searching for a successor rule
                                }
                            }
                        }
                    } else {
                        // No successor rules exist for the current predecessor character
                        // So, just copy the predecessor character, as is, to the new word
                        newWord.append(String(character))
                    }
                }
                // Replace the old word with the new word
                word = newWord
                print("After generation \(generation) the word is:")
                print(word)
            }
        }
        // MARK: Initialize L-system rendering instructions
        
        // The length of the line segments used when drawing the system, at generation 0
        length = 27
        // The factor by which to reduce the initial line segment length after each generation / word re-write
        reduction = 1.25
        // The angle by which the turtle will turn left or right; in degrees.
        angle = 20
        // Where the turtle begins drawing on the canvas
        initialPosition = Point(x: 250, y: 100)
        // The initial direction of the turtle
        initialHeading = 90
        // MARK: Prepare for rendering L-system
        
        // Set the length based on number of generations
        if generations > 0 {
            for _ in 1...generations {
                length /= reduction
            }
        }
        // Move to designated starting position
        canvas.saveState()
        turtle.penUp()
        turtle.setPosition(to: initialPosition)
        turtle.setHeading(to: initialHeading)
        turtle.penDown()
        canvas.restoreState()
        // DEBUG:
        print("\nNow rendering...\n")
        // Render the entire system
        for character in word {
            // Save the state of the canvas (no transformations)
            canvas.saveState()
            // Bring canvas into same orientation and origin position as
            // it was when last character in the word was rendered
            turtle.restoreStateOnCanvas()
            // Render based on this character
            switch character {
            case "+":
                // Turn to the left
                turtle.left(by: angle)
            case "-":
                // Turn to the right
                turtle.right(by: angle)
            case "[":
                // Save position and heading
                turtle.saveState()
            case "]":
                // Restore position and heading
                turtle.restoreState()
            case "B":
                // Render a small berry
                canvas.drawEllipse(at: Point(x: 0, y: 0), width: 5, height: 5)
            default:
                // Any other character means move forward
                turtle.forward(steps: Int(round(length)))
                break
            }
            // Restore the state of the canvas (no transformations)
            canvas.restoreState()
        }
    }
    // This function runs repeatedly, forever, to create the animated effect
    func draw() {
        // Nothing is being animated, so nothing needed here
        
    }
}
//Test pushing functionality
