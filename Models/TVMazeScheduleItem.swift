//
//  TVMazeScheduleItem.swift
//  Guía TV
//
//  DTOs para mapear respuestas de TVMaze API
//

import Foundation

/// Item de programación desde TVMaze API
struct TVMazeScheduleItem: Codable {
    let id: Int
    let name: String
    let airdate: String
    let airtime: String
    let summary: String?
    let show: ShowDTO
    let type: String?
    let season: Int?
    let number: Int?
    let runtime: Int?
    let rating: RatingDTO?
    let image: ImageDTO?
}

/// DTO para información del show
struct ShowDTO: Codable {
    let name: String
    let image: ImageDTO?
    let network: NetworkDTO?
}

/// DTO para rating
struct RatingDTO: Codable {
    let average: Double?
}

/// DTO para imágenes
struct ImageDTO: Codable {
    let medium: String?
    let original: String?
}

/// DTO para país
struct CountryDTO: Codable {
    let name: String
    let code: String
    let timezone: String
}

/// DTO para red/cadena televisiva
struct NetworkDTO: Codable {
    let id: Int
    let name: String
    let country: CountryDTO?
    let officialSite: String?
}
