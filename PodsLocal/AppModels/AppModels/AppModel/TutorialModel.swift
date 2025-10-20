//
//  TutorialModel.swift
//  AppRepository
//
//  Created by Martin on 2024/12/5.
//

import Foundation

public struct TutorialItemAppModel {
    public let id: String
    public let category: String
    public let name: String
    public let abb: String
    public let content: String
    public let videoUrl: String
    public let imageUrl: String
    
    public init(id: String, category: String, name: String, abb: String, content: String, videoUrl: String, imageUrl: String) {
        self.id = id
        self.category = category
        self.name = name
        self.abb = abb
        self.content = content
        self.videoUrl = videoUrl
        self.imageUrl = "https://static.knit-ai.com/app/static/images/\(imageUrl)"
    }
}

public struct TutorialsAppModel {
    public let knittings: [TutorialItemAppModel]
    public let crochets: [TutorialItemAppModel]
    
    public init(knittings: [TutorialItemAppModel], crochets: [TutorialItemAppModel]) {
        self.knittings = knittings
        self.crochets = crochets
    }
}
