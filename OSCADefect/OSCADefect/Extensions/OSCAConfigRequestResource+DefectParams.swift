//
//  OSCAConfigRequestResource+DefectParams.swift
//  OSCADefect
//
//  Created by Ömer Kurutay on 30.03.22.
//

import Foundation
import OSCANetworkService

extension OSCAConfigRequestResource {
  /// ConfigReqestRessource for defect-form's config params
  /// - Parameters:
  ///   - baseURL: The base url of your parse-server
  ///   - headers: The authentication headers for parse-server
  /// - Returns: A ready to use OSCAConfigRequestResource
  static func defectFormParseConfig(baseURL: URL,
                                    headers: [String: CustomStringConvertible]) -> OSCAConfigRequestResource {
    return OSCAConfigRequestResource(
      baseURL: baseURL,
      headers: headers)
  }// end static func
}// end extension public struct OSCAConfigRequestResource
