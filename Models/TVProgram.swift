//
//  TVProgram.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 19-06-26.
//  Modelo de datos con SwiftData para persistencia local
//

import Foundation
import SwiftData

/// Modelo de programa de TV con persistencia SwiftData
/// @Model permite guardar automáticamente en base de datos local
@Model
final class TVProgram {

    // MARK: - Properties

    var id: UUID
    var name: String
    var airdate: String
    var airtime: String
    var summary: String?
    var showName: String
    var imageURL: String?
    var runtime: Int?
    var rating: Double?
    var type: String?
    var season: Int?
    var number: Int?
    var networkName: String?
    var countryCode: String?
    var countryName: String?

    // MARK: - Initialization

    /// Inicializador completo (usado por SwiftData)
    init(
        id: UUID = UUID(),
        name: String,
        airdate: String,
        airtime: String,
        summary: String? = nil,
        showName: String,
        imageURL: String? = nil,
        runtime: Int? = nil,
        rating: Double? = nil,
        type: String? = nil,
        season: Int? = nil,
        number: Int? = nil,
        networkName: String? = nil,
        countryCode: String? = nil,
        countryName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.airdate = airdate
        self.airtime = airtime
        self.summary = summary
        self.showName = showName
        self.imageURL = imageURL
        self.runtime = runtime
        self.rating = rating
        self.type = type
        self.season = season
        self.number = number
        self.networkName = networkName
        self.countryCode = countryCode
        self.countryName = countryName
    }

    /// Inicializador conveniencia desde TVMazeScheduleItem
    convenience init(from item: TVMazeScheduleItem) {
        self.init(
            id: UUID(),
            name: item.name,
            airdate: item.airdate,
            airtime: item.airtime,
            summary: item.summary,
            showName: item.show.name,
            imageURL: item.show.image?.medium ?? item.show.image?.original,
            runtime: item.runtime,
            rating: item.rating?.average,
            type: item.type,
            season: item.season,
            number: item.number,
            networkName: item.show.network?.name,
            countryCode: item.show.network?.country?.code,
            countryName: item.show.network?.country?.name
        )
    }
}

// MARK: - Identifiable

extension TVProgram: Identifiable {
    // SwiftData @Model ya proporciona id, pero confirmamos protocolo
}

// MARK: - Sendable

extension TVProgram: @unchecked Sendable {
    // SwiftData @Model es thread-safe, marcamos como Sendable para Swift 6
}

// MARK: - Comparable

extension TVProgram: Comparable {
    static func < (lhs: TVProgram, rhs: TVProgram) -> Bool {
        // Comparar por fecha y hora
        let lhsDateTime = "\(lhs.airdate) \(lhs.airtime)"
        let rhsDateTime = "\(rhs.airdate) \(rhs.airtime)"
        return lhsDateTime < rhsDateTime
    }
}
