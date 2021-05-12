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
        
        var system = Visualizer(fromJSONFile: "scott-berry-tree", drawingOn: canvas)
        var system1 = Visualizer(fromJSONFile: "james-devil-fingers", drawingOn: canvas)
        var system2 = Visualizer(fromJSONFile: "aidan-berry-bush", drawingOn: canvas)
        var system3 = Visualizer(fromJSONFile: "scott-berry-tree", drawingOn: canvas)
        var system4 = Visualizer(fromJSONFile: "victoria-bush", drawingOn: canvas)
        var system5 = Visualizer(fromJSONFile: "sihan-tree", drawingOn: canvas)
        
        system.render()
        system1.render()
        system2.render()
        system3.render()
        system4.render()
        system5.render()
    }
    
    // This function runs repeatedly, forever, to create the animated effect
    func draw() {
        
        // Nothing is being animated, so nothing needed here
        
    }
    
}
