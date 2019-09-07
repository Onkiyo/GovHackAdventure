//
//  DataSource.swift
//  GovHackChoices
//
//  Created by Dayn Goodbrand on 7/9/19.
//  Copyright © 2019 Dayn Goodbrand. All rights reserved.
//

import Foundation

struct Story: Codable, Identifiable {
    let id: Int
    let name: String
    let image: String
    let story: [Card]
}

struct Card: Codable, Identifiable {
    let id: Int
    let question: String
    let image: String
    let left: Choice
    let right: Choice
}

struct Choice: Codable {
    let label: String
    let next: Int?
    let review: Review?
}

struct Review: Codable, Identifiable {
    let title: String
    let label: String
    let image: String
    let infoUrl: String
    
    var id: String {
        return title + label + image
    }
}

enum CardChoice {
    case left, right
}

class DataSource {
    static let sharedInstance = DataSource()
    
    let allCards:[Card]
    
    private init() {
        let stories: [Story] = DataSource.loadJSON("stories.json")
        self.allCards = stories.first?.story ?? []
    }
    
    private static func loadJSON<T: Decodable>(_ filename: String) -> T {
        
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else { fatalError("Couldn't find \(filename) in main bundle.") }
        
        let data: Data
        do { data =  try Data(contentsOf: file) }
        catch { fatalError("Couldn't load \(filename) from main bundle:\n\(error)") }
        
        do { return try JSONDecoder().decode(T.self, from: data) }
        catch { fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)") }
    }
    
    func nextCard(after card: Card, choice: CardChoice) -> Card? {
        guard let id = choice == .left ? card.left.next : card.right.next else { return nil }
        return allCards.first { $0.id == id }
    }
}
