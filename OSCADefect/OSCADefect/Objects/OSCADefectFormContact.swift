//
//  OSCADefectFormContact.swift
//  OSCADefect
//
//  Created by Stephan Breidenbach on 24.01.22.
//  Reviewed by Stephan Breidenbach on 23.01.23
//

import Foundation
import OSCAEssentials

/**
 A contact object of the defect form
 - Parameter objectId: auto generated id
 - Parameter createdAt: UTC date when the object was created
 - Parameter updatedAt: UTC date when the object was changed
 - Parameter email: The email recipient of the contact form
 - Parameter emailSubject: The subject of the email that gets generated
 - Parameter title: Title of the contact. Will be displayed in the dropdown menu of the contact form.
 */
public struct OSCADefectFormContact: Codable, Equatable, Hashable {
  public private(set) var objectId : String?
  public private(set) var createdAt: Date?
  public private(set) var updatedAt: Date?
  public var email       : String?
  public var emailSubject: String?
  public var title       : String?
  public var position    : Int?
}

extension OSCADefectFormContact: OSCAParseClassObject {
  /// Parse class name
  public static var parseClassName : String { return "DefectFormContact" }
}// end extension OSCADefectFormContact
