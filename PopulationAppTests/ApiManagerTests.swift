//
//  ApiManagerTests.swift
//  PopulationAppTests
//
//  Created by João Santos on 27/08/2024.
//

import XCTest
@testable import PopulationApp

final class ApiManagerTests: XCTestCase {

    var apiManager: ApiManager!
    
    override func setUpWithError() throws {
        // Setup before each test
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        apiManager = ApiManager(session: urlSession)
    }
    
    override func tearDownWithError() throws {
        // Cleanup after each test
        apiManager = nil
    }
    
    func testFetchStateDataSuccess() async throws {
        // Given
        let data = """
        {
            "data": [
                {
                    "ID State": "04000US02",
                    "State": "Alaska",
                    "ID Year": 2022,
                    "Year": "2022",
                    "Population": 734821,
                    "Slug State": "alaska"
                }
            ]
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let expectedUrl = URL(string: "https://datausa.io/api/data?drilldowns=State&measures=Population&year=latest")!
            guard let url = request.url, url == expectedUrl else {
                throw ApiError.request
            }
            
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        // When
        let stateData = try await apiManager.fetchStateData()
        
        // Then
        XCTAssertEqual(stateData.data.first?.idState, "04000US02")
        XCTAssertEqual(stateData.data.first?.state, "Alaska")
        XCTAssertEqual(stateData.data.first?.idYear, 2022)
        XCTAssertEqual(stateData.data.first?.year, "2022")
        XCTAssertEqual(stateData.data.first?.population, 734821)
        XCTAssertEqual(stateData.data.first?.slugState, "alaska")
    }
    
    func testFetchNationDataSuccess() async throws {
        // Given
        let data = """
        {
            "data": [
                {
                    "ID Nation": "01000US",
                    "Nation": "United States",
                    "ID Year": 2021,
                    "Year": "2021",
                    "Population": 329725481,
                    "Slug Nation": "united-states"
                }
            ]
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let expectedUrl = URL(string: "https://datausa.io/api/data?drilldowns=Nation&measures=Population")!
            guard let url = request.url, url == expectedUrl else {
                throw ApiError.request
            }
            
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        let nationData = try await apiManager.fetchNationData()
        
        XCTAssertEqual(nationData.data.first?.idNation, "01000US")
        XCTAssertEqual(nationData.data.first?.nation, "United States")
        XCTAssertEqual(nationData.data.first?.idYear, 2021)
        XCTAssertEqual(nationData.data.first?.year, "2021")
        XCTAssertEqual(nationData.data.first?.population, 329725481)
        XCTAssertEqual(nationData.data.first?.slugNation, "united-states")
    }
    
    func testFetchStateDataError() async throws {
        // Given
        let data = """
        {
            "data": []
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let expectedUrl = URL(string: "https://datausa.io/api/data?drilldowns=State&measures=Population&year=latest")!
            guard let url = request.url, url == expectedUrl else {
                throw ApiError.request
            }
            
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        await self.XCTAssertThrowsError(try await apiManager.fetchStateData()) { error in
            XCTAssertEqual(error as? ApiError, ApiError.invalidResponse)
        }
    }
    
    func testFetchNationDataError() async throws {
        // Given
        let data = """
        {
            "data": []
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let expectedUrl = URL(string: "https://datausa.io/api/data?drilldowns=Nation&measures=Population")!
            guard let url = request.url, url == expectedUrl else {
                throw ApiError.request
            }
            
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        await self.XCTAssertThrowsError(try await apiManager.fetchNationData()) { error in
            XCTAssertEqual(error as? ApiError, ApiError.invalidResponse)
        }
    }
    
    
    func XCTAssertThrowsError<T>(_ expression: @autoclosure () async throws -> T, _ complete: (_ error: Error) -> Void) async {
        do {
            _ = try await expression()
            XCTFail("No error was thrown.")
        } catch {
            complete(error)
        }
    }

}
