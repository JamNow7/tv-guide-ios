//
//  TVServiceTests.swift
//  GuiaTVTests
//

import XCTest
@testable import GuiaTV

/// Tests para el servicio de TV
final class TVServiceTests: XCTestCase {

    var sut: TVService!
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        sut = TVService(session: mockSession)
    }

    override func tearDown() {
        sut = nil
        mockSession = nil
        super.tearDown()
    }

    // MARK: - Success Tests

    func testFetchSchedule_WhenSuccessful_ReturnsPrograms() async throws {
        let mockData = createMockScheduleData()
        mockSession.mockData = mockData
        mockSession.mockStatusCode = 200

        let programs = try await sut.fetchSchedule()

        XCTAssertEqual(programs.count, 2)
        XCTAssertEqual(programs[0].name, "Episode 1")
        XCTAssertEqual(programs[0].showName, "Test Show")
    }

    func testFetchSchedule_WhenSuccessful_ExtractsNetworks() async throws {
        let mockData = createMockScheduleData()
        mockSession.mockData = mockData
        mockSession.mockStatusCode = 200

        let programs = try await sut.fetchSchedule()

        XCTAssertEqual(programs.first?.networkName, "HBO")
    }

    // MARK: - Error Tests

    func testFetchSchedule_WhenInvalidJSON_ThrowsDecodingError() async {
        mockSession.mockData = Data("invalid json".utf8)
        mockSession.mockStatusCode = 200

        do {
            _ = try await sut.fetchSchedule()
            XCTFail("Should throw decoding error")
        } catch {
            XCTAssertTrue(error is TVServiceError || error is DecodingError)
        }
    }

    func testFetchSchedule_WhenNetworkError_ThrowsError() async {
        mockSession.mockError = URLError(.notConnectedToInternet)

        do {
            _ = try await sut.fetchSchedule()
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }

    func testFetchSchedule_WhenServerError_ThrowsServerError() async {
        mockSession.mockData = Data()
        mockSession.mockStatusCode = 500

        do {
            _ = try await sut.fetchSchedule()
            XCTFail("Should throw server error")
        } catch let error as TVServiceError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Expected serverError")
            }
        } catch {
            XCTFail("Expected TVServiceError")
        }
    }

    func testFetchSchedule_When404_ThrowsServerError() async {
        mockSession.mockData = Data()
        mockSession.mockStatusCode = 404

        do {
            _ = try await sut.fetchSchedule()
            XCTFail("Should throw server error")
        } catch let error as TVServiceError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 404)
            } else {
                XCTFail("Expected serverError")
            }
        } catch {
            XCTFail("Expected TVServiceError")
        }
    }

    // MARK: - Performance

    func testFetchSchedule_Performance_Decoding() {
        let mockData = createMockScheduleData()

        measure {
            let decoder = JSONDecoder()
            let _: [TVMazeScheduleItem] = try! decoder.decode([TVMazeScheduleItem].self, from: mockData)
        }
    }

    // MARK: - Helpers

    private func createMockScheduleData() -> Data {
        """
        [
            {
                "id": 1,
                "name": "Episode 1",
                "airdate": "2024-06-20",
                "airtime": "21:00",
                "summary": "<p>Test summary</p>",
                "show": {
                    "name": "Test Show",
                    "image": {"medium": "https://example.com/image.jpg"},
                    "network": {
                        "id": 1,
                        "name": "HBO",
                        "country": {
                            "name": "USA",
                            "code": "US",
                            "timezone": "America/New_York"
                        }
                    }
                },
                "season": 1,
                "number": 1,
                "type": "regular",
                "runtime": 60,
                "rating": {"average": 8.5}
            },
            {
                "id": 2,
                "name": "Episode 2",
                "airdate": "2024-06-21",
                "airtime": "22:00",
                "show": {
                    "name": "Test Show 2",
                    "network": {
                        "id": 2,
                        "name": "Netflix",
                        "country": {
                            "name": "USA",
                            "code": "US",
                            "timezone": "America/Los_Angeles"
                        }
                    }
                },
                "season": 1,
                "number": 2
            }
        ]
        """.data(using: .utf8)!
    }
}

// MARK: - MOCK

final class MockURLSession: URLSessionProtocol {

    var mockData: Data?
    var mockError: Error?
    var mockStatusCode: Int = 200

    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }

        let response = HTTPURLResponse(
            url: url,
            statusCode: mockStatusCode,
            httpVersion: nil,
            headerFields: nil
        )!

        return (mockData ?? Data(), response)
    }
}
