//
//  OSCAClassRequestResource+DefectFormData.swift
//  OSCADefect
//
//  Created by Stephan Breidenbach on 24.01.22.
//

import Foundation
import OSCANetworkService

extension OSCAUploadClassRequestResource {
  /// ClassUploadRessource for defect-form's data
  ///```console
  /// curl -vX GET \
  /// -H "X-Parse-Application-Id: ApplicationId" \
  /// -H "X-PARSE-CLIENT-KEY: ClientKey" \
  /// -H 'Content-Type: application/json' \
  /// 'https://parse-dev.solingen.de/classes/DefectFormData'
  ///  ```
  /// - Parameters:
  ///   - baseURL: The base url of the parse-server
  ///   - headers: The authentication headers for the parse-server
  ///   - uploadParseClassObject: the parse class object requested for upload
  /// - Returns: A ready to use `OSCAUploadClassRequestResource`
  static func defectFormData(baseURL: URL,
                             headers: [String: CustomStringConvertible],
                             uploadParseClassObject: OSCADefectFormData?) -> OSCAUploadClassRequestResource<OSCADefectFormData> {
    let parseClass = OSCADefectFormData.parseClassName
    return OSCAUploadClassRequestResource<OSCADefectFormData>(
      baseURL: baseURL,
      parseClass: parseClass,
      uploadParseClassObject: uploadParseClassObject,
      headers: headers)
  }// end static func defectFormData
}// end extension public struct OSCAClassRequestResource
