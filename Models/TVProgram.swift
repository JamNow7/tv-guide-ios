//
//  TVProgram.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 19-06-26.
//

import Foundation

struct TVProgram: Identifiable, Codable {
    let id: UUID = UUID()
    let name: String
    let airdate: String
    let airtime: String
    let summary: String?
    let showName: String
    let imageURL: String?
    let runtime: Int?
    let rating: Double?
    let type: String?
    let season: Int?
    let number: Int?
    let networkName: String?
    let countryCode: String?
    let countryName: String?

    enum CodingKeys: String, CodingKey {
        case name, airdate, airtime, summary, showName, imageURL, runtime, rating, type, season, number, networkName, countryCode, countryName
    }

    // Inicializador para crear desde TVMazeScheduleItem
    init(from item: TVMazeScheduleItem) {
        self.name = item.name
        self.airdate = item.airdate
        self.airtime = item.airtime
        self.summary = item.summary
        self.showName = item.show.name
        self.imageURL = item.show.image?.medium ?? item.show.image?.original
        self.runtime = item.runtime
        self.rating = item.rating?.average
        self.type = item.type
        self.season = item.season
        self.number = item.number
        self.networkName = item.show.network?.name
        self.countryCode = item.show.network?.country?.code
        self.countryName = item.show.network?.country?.name
    }
}
