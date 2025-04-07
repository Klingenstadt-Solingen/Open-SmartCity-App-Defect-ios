//
//  +DefectFormData.swift
//  OSCADefect
//
//  Created by Stephan Breidenbach on 01.02.23.
//

import Foundation
import OSCANetworkService
extension OSCAUploadFileRequestResource {
  /// ClassUploadFileRessource for defect-form's file
  /// - Parameters:
  ///   - baseURL: The base url of the parse-server
  ///   - headers: The authentication headers for the parse-server
  ///   - uploadFile: the file requested for upload
  /// - Returns: A ready to use `OSCAUploadFileRequestResource`
  static func defectFormFile(baseURL: URL,
                             headers: [String: CustomStringConvertible],
                             uploadFile: Data?) -> OSCAUploadFileRequestResource {
    return OSCAUploadFileRequestResource(
      baseURL: baseURL,
      uploadFile: uploadFile,
      headers: headers)
  }// end static func defectFormFile
}// end extenson public struct OSCAUploadFileRequestResource
