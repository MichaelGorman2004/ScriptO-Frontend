import Foundation
import CoreGraphics

/*
 Note.swift
 
 Core data model definitions for the ScriptO application's note-taking functionality.
 This file defines the structure for notes, including their content, metadata, and
 drawing elements.
 
 Key Structures:
 - Note: Main note container with metadata
 - NoteElement: Individual elements within a note (e.g., drawings)
 - StrokePoint: Points making up a drawing stroke
 - StrokeProperties: Drawing stroke styling properties
*/

public struct Note: Identifiable, Codable {
    public let id: UUID
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
    
    public init(id: UUID = UUID(), title: String = "", tags: [String] = [], subject: String = "", content: [NoteElement] = [], createdAt: Date = Date(), modifiedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.tags = tags
        self.subject = subject
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

public struct NoteElement: Codable, Identifiable {
    public let id: UUID
    public var type: String
    public var content: [StrokePoint]
    public var bounds: CGRect
    public var strokeProperties: StrokeProperties
    
    public init(id: UUID = UUID(), type: String, content: [StrokePoint], bounds: CGRect, strokeProperties: StrokeProperties) {
        self.id = id
        self.type = type
        self.content = content
        self.bounds = bounds
        self.strokeProperties = strokeProperties
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case content
        case bounds
        case strokeProperties = "stroke_properties"
    }
}

public struct StrokePoint: Codable {
    public var x: CGFloat
    public var y: CGFloat
    public var pressure: CGFloat
    
    public init(x: CGFloat, y: CGFloat, pressure: CGFloat) {
        self.x = x
        self.y = y
        self.pressure = pressure
    }
}

public struct StrokeProperties: Codable {
    public var color: String
    public var width: CGFloat
    
    public init(color: String, width: CGFloat) {
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