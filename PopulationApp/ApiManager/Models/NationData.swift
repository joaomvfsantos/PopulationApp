//
//  NationData.swift
//  PopulationApp
//
//  Created by João Santos on 27/08/2024.
//

import Foundation

struct NationData: Codable {
    
    var data: [Nation]
    
}

struct Nation: Codable {
    
    var idNation: String
    var nation: String
    var idYear: Int
    var year: String
    var population: Int
    var slugNation: String
    
    enum CodingKeys: String, CodingKey {
        case idNation = "ID Nation"
        case nation = "Nation"
        case idYear = "ID Year"
        case year = "Year"
        case population = "Population"
        case slugNation = "Slug Nation"
    }
    
}
