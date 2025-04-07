//
//  OSCADefect.swift
//  OSCADefect
//
//  Created by Stephan Breidenbach on 24.01.22.
//  reviewed by Stephan Breidenbach on 20.06.22
//

import Combine
import Foundation
import OSCAEssentials
import OSCANetworkService

public struct OSCADefectDependencies {
  let defaultLocation: OSCAGeoPoint?
  let networkService: OSCANetworkService
  let userDefaults: UserDefaults
  let analyticsModule: OSCAAnalyticsModule?

  public init(defaultLocation: OSCAGeoPoint? = nil,
              networkService: OSCANetworkService,
              userDefaults: UserDefaults,
              analyticsModule: OSCAAnalyticsModule? = nil
  ) {
    self.defaultLocation = defaultLocation
    self.networkService = networkService
    self.userDefaults = userDefaults
    self.analyticsModule = analyticsModule
  } // end public init
} // end public struct OSCACoworkingDependencies

/// Defect module
public struct OSCADefect: OSCAModule {
  /// module DI container
  var moduleDIContainer: OSCADefectDIContainer!

  let transformError: (Error) -> OSCADefectError = { error in
    if let networkError = error as? OSCANetworkError {
      switch networkError {
      case OSCANetworkError.invalidResponse:
        return OSCADefectError.networkInvalidResponse
      case OSCANetworkError.invalidRequest:
        return OSCADefectError.networkInvalidRequest
      case let OSCANetworkError.dataLoadingError(statusCode: code, data: data):
        return OSCADefectError.networkDataLoading(statusCode: code, data: data)
      case let OSCANetworkError.jsonDecodingError(error: error):
        return OSCADefectError.networkJSONDecoding(error: error)
      case OSCANetworkError.isInternetConnectionError:
        return OSCADefectError.networkIsInternetConnectionFailure
      } // end switch case
    } else {
      return OSCADefectError.unknownError
    }// end if
  } // end let transformOSCANetworkErrorToOSCADefectError closure

  /// version of the module
  public var version: String = "1.0.4"
  /// bundle prefix of the module
  public var bundlePrefix: String = "de.osca.defect"

  /// module `Bundle`
  ///
  /// **available after module initialization only!!!**
  public internal(set) static var bundle: Bundle!

  ///
  private var networkService: OSCANetworkService
  public private(set) var userDefaults: UserDefaults
  public private(set) var defaultLocation: OSCAGeoPoint?

  /**
   create module and inject module dependencies

   ** This is the only way to initialize the module!!! **
   - Parameter moduleDependencies: module dependencies
   ```
   call: OSCADefect.create(with moduleDependencies)
   ```
   */
  public static func create(with moduleDependencies: OSCADefectDependencies) -> OSCADefect {
    var module: Self = Self(defaultLocation: moduleDependencies.defaultLocation,
                            networkService: moduleDependencies.networkService,
                            userDefaults: moduleDependencies.userDefaults)
    module.moduleDIContainer = OSCADefectDIContainer(dependencies: moduleDependencies)

    return module
  } // end public static func create

  /// initializes the defect module
  ///  - Parameter networkService: Your configured network service
  private init(defaultLocation: OSCAGeoPoint? = nil,
               networkService: OSCANetworkService,
               userDefaults: UserDefaults) {
    self.defaultLocation = defaultLocation
    self.networkService = networkService
    self.userDefaults = userDefaults
    var bundle: Bundle?
    #if SWIFT_PACKAGE
      bundle = Bundle.module
    #else
      bundle = Bundle(identifier: bundlePrefix)
    #endif
    guard let bundle: Bundle = bundle else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
  } // end public init with network service
} // end public struct OSCADefect

extension OSCADefect {
  /// Downloads defect-form's contact data from parse server
  /// - Parameter limit: Limits the amount of defect-form's contacts that gets downloaded from the server
  /// - Parameter query: HTTP query parameter
  /// - Returns: An array of defect-form's contacts
  public func getDefectFormContacts(limit: Int = 1000, query: [String: String] = [:]) -> AnyPublisher<Result<[OSCADefectFormContact], Error>, Never> {
    var parameters = query
    parameters["limit"] = "\(limit)"

    var headers = networkService.config.headers
    if let sessionToken = userDefaults.string(forKey: "SessionToken") {
      headers["X-Parse-Session-Token"] = sessionToken
    }

    return networkService
      .download(OSCAClassRequestResource
        .defectFormContact(baseURL: networkService.config.baseURL,
                           headers: headers,
                           query: parameters))
      .map { .success($0) }
      .catch { error -> AnyPublisher<Result<[OSCADefectFormContact], Error>, Never> in .just(.failure(error)) }
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .receive(on: OSCAScheduler.mainScheduler)
      .eraseToAnyPublisher()
  } // end public func getDefectFormContacts

  /// Downloads all config parameters declared in `OSCADefectParseConfigParams` from parse-server
  public func getParseConfigParams() -> AnyPublisher<Result<OSCADefectParseConfig, Error>, Never> {
    var headers = networkService.config.headers
    if let sessionToken = userDefaults.string(forKey: "SessionToken") {
      headers["X-Parse-Session-Token"] = sessionToken
    }

    return networkService
      .download(OSCAConfigRequestResource
        .defectFormParseConfig(baseURL: networkService.config.baseURL,
                               headers: headers))
      .map { .success($0) }
      .catch { error -> AnyPublisher<Result<OSCADefectParseConfig, Error>, Never> in .just(.failure(error)) }
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .receive(on: OSCAScheduler.mainScheduler)
      .eraseToAnyPublisher()
  }

  /// Uploads defect-form's  data to parse server
  /// - Parameter defectFormData: defect-form's data object
  /// - Returns: `ParseUploadResponse`
  public func send(defectFormData: OSCADefectFormData) -> AnyPublisher<Result<ParseUploadResponse, Error>, Never> {
    var headers = networkService.config.headers
    if let sessionToken = userDefaults.string(forKey: "SessionToken") {
      headers["X-Parse-Session-Token"] = sessionToken
    }

    let anyPublisher: AnyPublisher<Result<ParseUploadResponse, Error>, Never> =
      networkService
        .upload(OSCAUploadClassRequestResource<OSCADefectFormData>
          .defectFormData(baseURL: networkService.config.baseURL,
                          headers: headers,
                          uploadParseClassObject: defectFormData))
        .map { .success($0) }
        .catch { error -> AnyPublisher<Result<ParseUploadResponse, Error>, Never> in
          .just(.failure(error))
        }
        .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
        .receive(on: OSCAScheduler.mainScheduler)
        .eraseToAnyPublisher()
    return anyPublisher
  }

  /// Uploads defect-form's  image file to parse server
  /// - Parameter defectFormFile: defect-form's file data
  /// - Returns: `ParseUploadFileResponse`
  public func sendFile(defectFormFile: Data) -> AnyPublisher<Result<ParseUploadFileResponse, Error>, Never> {
    var headers = networkService.config.headers
    if let sessionToken = userDefaults.string(forKey: "SessionToken") {
      headers["X-Parse-Session-Token"] = sessionToken
    }

    let anyPublisher: AnyPublisher<Result<ParseUploadFileResponse, Error>, Never> =
      networkService
        .upload(OSCAUploadFileRequestResource
          .defectFormFile(
            baseURL: networkService.config.baseURL,
            headers: headers,
            uploadFile: defectFormFile))
        .map { .success($0) }
        .catch { error -> AnyPublisher<Result<ParseUploadFileResponse, Error>, Never> in
          .just(.failure(error))
        }
        .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
        .receive(on: OSCAScheduler.mainScheduler)
        .eraseToAnyPublisher()
    return anyPublisher
  }
} // end extension OSCADefect

extension OSCADefect {
  public typealias UploadClassResponse = OSCAUploadClassRequestResource<OSCADefectFormData>.Response
  public typealias PutPublisher = AnyPublisher<UploadClassResponse, OSCADefectError>
  /// put defect to parse backend in background
  /// - Parameter maxCount: maximum amount of events downloaded from Parse
  /// - Parameter with query: query string separated by blanks
  /// - Returns: Publisher with a list of  events matchin the query string on the `Output`and possible `OSCAEventError`s on the `Fail`channel
  public func putDefect(formData: OSCADefectFormData) -> OSCADefect.PutPublisher {
    var headers = networkService.config.headers
    if let sessionToken = userDefaults.string(forKey: "SessionToken") {
      headers["X-Parse-Session-Token"] = sessionToken
    }
    let resource: OSCAUploadClassRequestResource<OSCADefectFormData> = .defectFormData(
      baseURL: networkService.config.baseURL,
      headers: headers,
      uploadParseClassObject: formData)
    let anyPublisher: OSCADefect.PutPublisher =
    networkService
      .upload(resource)
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .receive(on: OSCAScheduler.mainScheduler)
      .mapError(self.transformError)
      .eraseToAnyPublisher()
    return anyPublisher
  } // end public func fetch events with query
}// end extension OSCADefect
