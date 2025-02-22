import Foundation
import CoreGraphics

struct Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var tags: [String]
    var subject: String
    var content: [NoteElement]
    var createdAt: Date
    var modifiedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case tags
        case subject
        case content
        case createdAt = "created"
        case modifiedAt = "modified"
    }
}

struct NoteElement: Codable, Identifiable {
    let id: UUID
    var type: String
    var content: [StrokePoint]
    var bounds: CGRect
    var strokeProperties: StrokeProperties
    
    init(id: UUID = UUID(), type: String, content: [StrokePoint], bounds: CGRect, strokeProperties: StrokeProperties) {
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

struct StrokePoint: Codable {
    var x: CGFloat
    var y: CGFloat
    var pressure: CGFloat
}

struct StrokeProperties: Codable {
    var color: String
    var width: CGFloat
} 