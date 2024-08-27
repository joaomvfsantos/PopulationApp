//
//  StateData.swift
//  PopulationApp
//
//  Created by João Santos on 27/08/2024.
//

import Foundation

struct StateData: Codable {
    
    var data: [CountyState]
    
}

struct CountyState: Codable {
    
    var idState: String
    var state: String
    var idYear: Int
    var year: String
    var population: Int
    var slugState: String
    
    enum CodingKeys: String, CodingKey {
        case idState = "ID State"
        case state = "State"
        case idYear = "ID Year"
        case year = "Year"
        case population = "Population"
        case slugState = "Slug State"
    }
    
}
