//
//  MockUrlProtocol.swift
//  PopulationAppTests
//
//  Created by João Santos on 27/08/2024.
//

import Foundation

class MockURLProtocol: URLProtocol {
  
  override class func canInit(with request: URLRequest) -> Bool {
    // To check if this protocol can handle the given request.
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    // Here you return the canonical version of the request but most of the time you pass the orignal one.
    return request
  }

  override func startLoading() {
    // This is where you create the mock response as per your test case and send it to the URLProtocolClient.
  }

  override func stopLoading() {
    // This is called if the request gets canceled or completed.
  }
}
