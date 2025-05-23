//
//  OSCAClassRequestResource+DefectFormContact.swift
//  OSCADefect
//
//  Created by Stephan Breidenbach on 24.01.22.
//

import Foundation
import OSCANetworkService

extension OSCAClassRequestResource {
  /// ClassReqestRessource for defect-form's contact
  ///
  ///```console
  /// curl -vX GET \
  /// -H "X-Parse-Application-Id: ApplicationId" \
  /// -H "X-PARSE-CLIENT-KEY: ClientKey" \
  /// -H 'Content-Type: application/json' \
  /// 'https://parse-dev.solingen.de/classes/DefectFormContact'
  ///  ```
  /// - Parameters:
  ///   - baseURL: The base url of your parse-server
  ///   - headers: The authentication headers for parse-server
  ///   - query: HTTP query parameters for the request
  /// - Returns: A ready to use OSCAClassRequestResource
  static func defectFormContact(baseURL: URL,
                                headers: [String: CustomStringConvertible],
                                query: [String: CustomStringConvertible] = [:]) -> OSCAClassRequestResource {
    let parseClass = OSCADefectFormContact.parseClassName
    return OSCAClassRequestResource(baseURL: baseURL,
                                    parseClass: parseClass,
                                    parameters: query,
                                    headers: headers)
  }// end static func defectFormContact
}// end extension public struct OSCAClassRequestResource

