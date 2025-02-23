import Foundation
import CoreGraphics

/*
 Note.swift
 
 Core data model for notes in the ScriptO application. This model represents
 a single note with its metadata and content elements.
 
 Key Features:
 - Unique identification
 - Metadata (title, tags, subject)
 - Content elements for drawings/text
 - Timestamps for creation/modification
*/

public struct Note: Identifiable, Codable {
    public var id: UUID
    public var title: String
    public var tags: [String]
    public var subject: String
    public var content: [NoteElement]
    public var createdAt: Date
    public var modifiedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case tags
        case subject
        case content
        case createdAt = "created"
        case modifiedAt = "modified"
    }
    
    public init(
        id: UUID = UUID(),
        title: String = "",
        tags: [String] = [],
        subject: String = "",
        content: [NoteElement] = [],
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.tags = tags
        self.subject = subject
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

public struct NoteElement: Codable {
    public var id: UUID
    public var type: String
    public var content: [StrokePoint]
    public var bounds: CGRect
    public var strokeProperties: StrokeProperties?
    
    public init(
        id: UUID = UUID(),
        type: String,
        content: [StrokePoint],
        bounds: CGRect,
        strokeProperties: StrokeProperties? = nil
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.bounds = bounds
        self.strokeProperties = strokeProperties
    }
    
    func optimizedContent() -> [StrokePoint] {
        // Skip points that are too close together
        return content.enumerated().compactMap { index, point in
            if index == 0 || index == content.count - 1 {
                return point.compressed()
            }
            
            let prev = content[index - 1]
            let distance = sqrt(pow(point.x - prev.x, 2) + pow(point.y - prev.y, 2))
            
            // Only keep points that are at least 2 units apart
            return distance > 2.0 ? point.compressed() : nil
        }
    }
}

public struct StrokePoint: Codable {
    public var x: CGFloat
    public var y: CGFloat
    public var pressure: CGFloat
    
    public init(x: CGFloat, y: CGFloat, pressure: CGFloat = 1.0) {
        self.x = x
        self.y = y
        self.pressure = pressure
    }
    
    // Compress coordinates to reduce precision
    func compressed() -> StrokePoint {
        return StrokePoint(
            x: round(x * 100) / 100, // 2 decimal places
            y: round(y * 100) / 100,
            pressure: round(pressure * 10) / 10  // 1 decimal place for pressure
        )
    }
}

public struct StrokeProperties: Codable {
    public var color: String
    public var width: CGFloat
    
    public init(color: String = "#000000", width: CGFloat = 2.0) {
        self.color = color
        self.width = width
    }
}

extension Note {
    static func empty() -> Note {
        Note(
            id: UUID(),
            title: "",
            tags: [],
            subject: "",
            content: [],
            createdAt: Date(),
            modifiedAt: Date()
        )
    }
} 