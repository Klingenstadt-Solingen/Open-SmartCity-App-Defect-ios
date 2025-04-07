//
//  OSCADefectFormData.swift
//  OSCADefect
//
//  Created by Stephan Breidenbach on 24.01.22.
//

import OSCAEssentials
import Foundation

/**
 DefectFormData schema
 - Parameter objectId: auto generated id
 - Parameter createdAt: UTC date when the object was created
 - Parameter updatedAt: UTC date when the object was changed
 - Parameter name: The full name of the sender
 - Parameter phone: The phone number of the sender
 - Parameter email: The email of the sender
 - Parameter address: The address of the defect
 - Parameter postalCode: The postal code of the defect
 - Parameter city: The city of the defect
 - Parameter images: The photo(s) of the defect as `base64`encoded String(s)
 - Parameter message: The message of the contact form
 - Parameter contactId: The reference to the DefectFormContacts objectId
 - Parameter geopoint: The geopoint of the reported defect
 */
public struct OSCADefectFormData {
  public private(set) var objectId : String?
  public private(set) var createdAt: Date?
  public private(set) var updatedAt: Date?
  public var name      : String?
  public var phone     : String?
  public var email     : String?
  public var address   : String?
  public var postalCode: String?
  public var city      : String?
  public var images    : [String]?
  public var message   : String?
  public var contactId : String?
  public var geopoint  : ParseGeoPoint?
  
  public init(objectId  :        String? = nil,
              createdAt :          Date? = nil,
              updatedAt :          Date? = nil,
              name      :        String? = nil,
              phone     :        String? = nil,
              email     :        String? = nil,
              address   :        String?,
              postalCode:        String?,
              city      :        String?,
              images    :        [String]?,
              message   :        String?,
              contactId :        String?,
              geopoint  : ParseGeoPoint?) {
    self.objectId   = objectId
    self.createdAt  = createdAt
    self.updatedAt  = updatedAt
    self.name       = name
    self.phone      = phone
    self.email      = email
    self.address    = address
    self.postalCode = postalCode
    self.city       = city
    self.images     = images
    self.message    = message
    self.contactId  = contactId
    self.geopoint   = geopoint
  }// end public init
}// end public struct OSCADefectFormData

extension OSCADefectFormData: Equatable {}

extension OSCADefectFormData: OSCAParseClassObject {}

extension OSCADefectFormData {
  /// Parse class name
  public static var parseClassName : String { return "DefectFormData" }
}// end extension OSCADefectFormData
