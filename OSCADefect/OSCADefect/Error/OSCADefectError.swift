//
//  OSCADefectError.swift
//  OSCADefect
//
//  Created by Stephan Breidenbach on 21.06.22.
//


import Foundation

public enum OSCADefectError: Swift.Error, CustomStringConvertible {
  case networkInvalidRequest
  case networkInvalidResponse
  case networkDataLoading(statusCode: Int, data: Data)
  case networkJSONDecoding(error: Error)
  case networkIsInternetConnectionFailure
  case networkError
  case unknownError
  
    public var description: String {
      switch self {
      case .networkInvalidRequest:
        return "There is a network Problem: invalid request!"
      case .networkInvalidResponse:
        return "There is a network Problem: invalid response!"
      case let .networkDataLoading(statusCode, data):
        return "There is a network Problem: data loading failed with status code \(statusCode): \(data)"
      case let .networkJSONDecoding(error):
  #if DEBUG
        return "There is a network Problem: JSON decoding: \(error.localizedDescription)"
  #endif
        return "There is a network Problem with JSON decoding"
      case .networkIsInternetConnectionFailure:
        return "There is a network Problem: Internet connection failure!"
      case .networkError:
        return "There is an unspecified network Problem!"
      case .unknownError:
        return "Unknown error!"
      }// end switch case
    }// end var description
  }// end public enum OSCADefectError

extension OSCADefectError: Equatable{
  public static func == (lhs: OSCADefectError, rhs: OSCADefectError) -> Bool {
    switch (lhs, rhs) {
    case (.networkInvalidRequest, .networkInvalidRequest):
      return true
    case (.networkInvalidResponse,.networkInvalidResponse):
      return true
    case (.networkDataLoading(let statusCodeLhs, let dataLhs),.networkDataLoading(let statusCodeRhs, let dataRhs)):
      let statusCode = statusCodeLhs == statusCodeRhs
      let data = dataLhs == dataRhs
      return statusCode && data
    case (networkJSONDecoding(_),networkJSONDecoding(_)):
      return true
    case (.networkIsInternetConnectionFailure,.networkIsInternetConnectionFailure):
      return true
    case (.networkError,.networkError):
      return true
    case (.unknownError, .unknownError):
      return true
    default:
      return false
    }// switch case
  }// public static func ==
}// end extension public enum OSCADefectError
