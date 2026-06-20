//
//  TVService.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 19-06-26.
//

import Foundation

final class TVService {
    func fetchSchedule() async throws -> [TVProgram] {
        let url = URL(string: "https://api.tvmaze.com/schedule")!

        let (data, _) = try await URLSession.shared.data(from: url)

        let decoder = JSONDecoder()

        let raw = try decoder.decode([TVMazeScheduleItem].self, from: data)

        return raw.map { TVProgram(from: $0) }
    }
}

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

struct ShowDTO: Codable {
    let name: String
    let image: ImageDTO?
    let network: NetworkDTO?
}
struct RatingDTO: Codable {
      let average: Double?
  }

  struct ImageDTO: Codable {
      let medium: String?
      let original: String?
  }

struct CountryDTO: Codable {
      let name: String
      let code: String
      let timezone: String
  }

  struct NetworkDTO: Codable {
      let id: Int
      let name: String
      let country: CountryDTO?
      let officialSite: String?
  }

