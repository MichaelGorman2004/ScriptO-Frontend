import SwiftUI
import PencilKit

/*
 DrawingCanvas.swift
 
 A SwiftUI view providing drawing functionality for the ScriptO application.
 This canvas handles touch input, stroke rendering, and maintains the state
 of drawing elements within a note.
 
 Key Features:
 - Touch gesture handling
 - Real-time drawing rendering
 - Stroke property management
 - Drawing element state management
*/

struct DrawingCanvas: View {
    @Binding var noteElements: [NoteElement]
    @State private var currentStroke: [StrokePoint] = []
    
    var body: some View {
        Canvas { context, size in
            for element in noteElements {
                if element.type == "drawing" {
                    var path = Path()
                    if let firstPoint = element.content.first {
                        path.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
                        for point in element.content.dropFirst() {
                            path.addLine(to: CGPoint(x: point.x, y: point.y))
                        }
                    }
                    context.stroke(path, with: .color(.black), lineWidth: element.strokeProperties?.width ?? 2.0)
                }
            }
        }
        .background(Color.white)
        .border(Color.gray, width: 1)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let point = StrokePoint(
                        x: value.location.x,
                        y: value.location.y,
                        pressure: 1.0
                    )
                    
                    if currentStroke.isEmpty {
                        // Start new stroke
                        currentStroke = [point]
                        let element = NoteElement(
                            type: "drawing",
                            content: currentStroke,
                            bounds: CGRect(x: point.x, y: point.y, width: 1, height: 1),
                            strokeProperties: StrokeProperties(color: "black", width: 2.0)
                        )
                        noteElements.append(element)
                    } else {
                        // Add point to current stroke
                        currentStroke.append(point)
                        
                        // Update the current stroke in noteElements
                        if var lastElement = noteElements.last {
                            lastElement.content = currentStroke
                            
                            // Update bounds
                            let minX = currentStroke.map { $0.x }.min() ?? point.x
                            let maxX = currentStroke.map { $0.x }.max() ?? point.x
                            let minY = currentStroke.map { $0.y }.min() ?? point.y
                            let maxY = currentStroke.map { $0.y }.max() ?? point.y
                            
                            lastElement.bounds = CGRect(
                                x: minX,
                                y: minY,
                                width: maxX - minX,
                                height: maxY - minY
                            )
                            
                            noteElements[noteElements.count - 1] = lastElement
                        }
                    }
                }
                .onEnded { _ in
                    // Clear current stroke when gesture ends
                    currentStroke = []
                }
        )
    }
}

#Preview {
    DrawingCanvas(noteElements: .constant([]))
        .frame(width: 300, height: 400)
        .environment(\.isPreview, true)
}

// Add a preview-specific environment key
private struct PreviewEnvironmentKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isPreview: Bool {
        get { self[PreviewEnvironmentKey.self] }
        set { self[PreviewEnvironmentKey.self] = newValue }
    }
} 
