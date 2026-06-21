//
//  TVGuideViewModelTests.swift
//  TVGuideTests
//
//  Created by Claudio Cataldo on 19-06-26.
//  Tests para TVGuideViewModel con mocks
//

import XCTest
@testable import GuiaTV

/// Tests para el ViewModel principal
@MainActor
final class TVGuideViewModelTests: XCTestCase {

    var sut: TVGuideViewModel!
    var mockService: MockTVService!

    override func setUp() {
        super.setUp()
        mockService = MockTVService()
        sut = TVGuideViewModel(service: mockService, cacheService: nil)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Load Success Tests

    func testLoad_WhenSuccessful_PopulatesPrograms() async {
        // Given
        let mockPrograms = createMockPrograms()
        mockService.programsToReturn = mockPrograms

        // When
        await sut.load()

        // Then
        XCTAssertEqual(sut.programs.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.isUsingCache)
    }

    func testLoad_WhenSuccessful_ExtractsAvailableNetworks() async {
        // Given
        let mockPrograms = createMockPrograms()
        mockService.programsToReturn = mockPrograms

        // When
        await sut.load()

        // Then
        XCTAssertEqual(sut.availableNetworks.count, 2)
        XCTAssertTrue(sut.availableNetworks.contains("HBO"))
        XCTAssertTrue(sut.availableNetworks.contains("Netflix"))
    }

    // MARK: - Load Error Tests

    func testLoad_WhenError_SetsErrorState() async {
        // Given
        mockService.errorToThrow = TVServiceError.noConnection

        // When
        await sut.load()

        // Then
        XCTAssertNotNil(sut.error)
        XCTAssertTrue(sut.programs.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Filter Tests

    func testFilteredPrograms_WithSearchText_FiltersCorrectly() {
        // Given
        sut.programs = createMockPrograms()
        sut.searchText = "Episode 1"

        // When
        let filtered = sut.filteredPrograms

        // Then
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.name, "Episode 1")
    }

    func testFilteredPrograms_WithShowNameSearch_FiltersCorrectly() {
        // Given
        sut.programs = createMockPrograms()
        sut.searchText = "Game of Thrones"

        // When
        let filtered = sut.filteredPrograms

        // Then
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.showName, "Game of Thrones")
    }

    func testFilteredPrograms_WithNetworkFilter_FiltersCorrectly() {
        // Given
        sut.programs = createMockPrograms()
        sut.selectedNetwork = "HBO"

        // When
        let filtered = sut.filteredPrograms

        // Then
        XCTAssertTrue(filtered.allSatisfy { $0.networkName == "HBO" })
        XCTAssertEqual(filtered.count, 1)
    }

    func testFilteredPrograms_WithCombinedFilters_FiltersCorrectly() {
        // Given
        sut.programs = createMockPrograms()
        sut.searchText = "Episode"
        sut.selectedNetwork = "HBO"

        // When
        let filtered = sut.filteredPrograms

        // Then
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.name, "Episode 1")
        XCTAssertEqual(filtered.first?.networkName, "HBO")
    }

    // MARK: - State Tests

    func testLoad_WhenLoading_StartsAndStopsLoading() async {
        // Given
        mockService.programsToReturn = []

        // When
        await sut.load()

        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.programs.count, 0)
    }

    // MARK: - Clear Filters Tests

    func testClearFilters_ClearsAllFilters() {
        // Given
        sut.searchText = "test"
        sut.selectedNetwork = "HBO"

        // When
        sut.clearFilters()

        // Then
        XCTAssertTrue(sut.searchText.isEmpty)
        XCTAssertNil(sut.selectedNetwork)
    }

    func testClearSearch_ClearsOnlySearch() {
        // Given
        sut.searchText = "test"
        sut.selectedNetwork = "HBO"

        // When
        sut.clearSearch()

        // Then
        XCTAssertTrue(sut.searchText.isEmpty)
        XCTAssertEqual(sut.selectedNetwork, "HBO")
    }

    // MARK: - Retry Tests

    func testRetry_WhenCalled_ReloadsData() async {
        // Given
        mockService.errorToThrow = TVServiceError.noConnection

        await sut.load()
        XCTAssertNotNil(sut.error)

        // When
        mockService.errorToThrow = nil
        mockService.programsToReturn = createMockPrograms()
        sut.retry()

        // Wait for async
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNil(sut.error)
        XCTAssertEqual(sut.programs.count, 2)
    }

    // MARK: - Helpers

    private func createMockPrograms() -> [TVProgram] {
        return [
            TVProgram(
                name: "Episode 1",
                airdate: "2024-06-20",
                airtime: "21:00",
                summary: nil,
                showName: "Game of Thrones",
                imageURL: nil,
                runtime: nil,
                rating: nil,
                type: nil,
                season: 1,
                number: 1,
                networkName: "HBO",
                countryCode: nil,
                countryName: nil
            ),
            TVProgram(
                name: "Episode 2",
                airdate: "2024-06-21",
                airtime: "22:00",
                summary: nil,
                showName: "Stranger Things",
                imageURL: nil,
                runtime: nil,
                rating: nil,
                type: nil,
                season: 1,
                number: 2,
                networkName: "Netflix",
                countryCode: nil,
                countryName: nil
            )
        ]
    }
}

// MARK: - Mock TVService

class MockTVService: TVServiceProtocol {
    var programsToReturn: [TVProgram] = []
    var errorToThrow: Error?

    func fetchSchedule() async throws -> [TVProgram] {
        if let error = errorToThrow {
            throw error
        }
        return programsToReturn
    }
}
