// Reviewed by Stephan Breidenbach on 21.06.22
#if canImport(XCTest) && canImport(OSCATestCaseExtension)
import XCTest
import OSCAEssentials
import Combine
import OSCANetworkService
import OSCATestCaseExtension
@testable import OSCADefect

final class OSCADefectTests: XCTestCase {
  static let moduleVersion = "1.0.4"
  private var module: OSCADefect!
  private var cancellables: Set<AnyCancellable>!
  private var defectFormContact  : OSCADefectFormContact?
  private var defectImageTests = OSCADefectImageTests()
  
  override func setUpWithError() throws -> Void {
    try super.setUpWithError()
    try self.defectImageTests.setUpWithError()
    self.cancellables = []
    self.module = try makeDevModule()
    XCTAssertNotNil(self.module)
    module.userDefaults.setValue("r:6df7e90b7f84cdddc71d6a330636d93b",
                                 forKey: "SessionToken")
  }// end override fun setUp
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
    try self.defectImageTests.tearDownWithError()
  }// end override func tear down
  
  func testModuleInit() throws -> Void {
    let module = self.module!
    XCTAssertEqual(module.version, OSCADefectTests.moduleVersion)
    XCTAssertEqual(module.bundlePrefix, "de.osca.defect")
    let bundle = OSCADefect.bundle
    XCTAssertNotNil(bundle)
    XCTAssertNotNil(self.devPlistDict)
    XCTAssertNotNil(self.productionPlistDict)
    XCTAssertNotNil(self.devPlistDict)
    XCTAssertNotNil(self.productionPlistDict)
  }// end func testModuleInit
  
  func testDownloadDefectFormContact() throws -> Void {
    var defectFormContacts: [OSCADefectFormContact] = []
    var error: Error?
    
    let expectation = self.expectation(description: "GetDefectFormContacts")
    let module = try makeDevModule()
    XCTAssertNotNil(module)
    module.getDefectFormContacts(limit: 1)
      .sink { completion in
        switch completion {
        case .finished:
          expectation.fulfill()
        case let .failure(encounteredError):
          error = encounteredError
          expectation.fulfill()
        }// end switch completion
      } receiveValue: { result in
        switch result {
        case let .success(objects):
          defectFormContacts = objects
        case let .failure(encounteredError):
          error = encounteredError
        }// end switch result
      }// end sink
      .store(in: &self.cancellables)
    
    wait(for: [expectation], timeout: 10)
    
    XCTAssertNil(error)
    XCTAssertTrue(defectFormContacts.count == 1)
    self.defectFormContact = defectFormContacts.first
  }// end func testDownloadDefectFormContact
  
  func testUploadDefectFormData() throws -> Void {
    var response: ParseUploadResponse?
    var error: Error?
    let expectation = self.expectation(description: "test send defect form data to network")
    
    try testDownloadDefectFormContact()
    guard let defectFormContact = self.defectFormContact,
          let contactId = defectFormContact.objectId else {XCTFail("No valid defect form contact found!"); return}
    try self.defectImageTests.testCreateLargeImage()
    guard let base64String = defectImageTests.base64String else { XCTFail("Wrong base64 String"); return }
    let defectFormData = OSCADefectFormData(
      name         : "Stephan. Breidenbach",
      phone        : "+49 160 694 58 76",
      email        : "stephan.breidenbach@solingen.de",
      address      : "Grünewalder Str 29 - 31",
      postalCode   : "42657",
      city         : "Solingen",
      images       : [base64String],
      message      : "This is a test",
      contactId    : contactId,
      geopoint     : ParseGeoPoint(latitude: 51.1619640, longitude: 7.0790820)
    )// end defectFormData
    
    self.module!
      .putDefect(formData: defectFormData)
      .sink { completion in
        switch completion {
        case .finished:
          expectation.fulfill()
        case let .failure(err):
          error = err
          expectation.fulfill()
        }
      } receiveValue: { result in
        response = result
      }
      .store(in: &self.cancellables)
    //waitForExpectations(timeout: 10)
    wait(for: [expectation], timeout: 90)
    XCTAssertNil(error)
    XCTAssertNotNil(response)
  }// end func testUploadDefectFormData
}// end final class OSCADefectTests

// MARK: - factory methods
extension OSCADefectTests {
  public func makeDevModuleDependencies() throws -> OSCADefectDependencies {
    let networkService = try makeDevNetworkService()
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.defect")
    let dependencies = OSCADefectDependencies(
      networkService: networkService,
      userDefaults: userDefaults)
    return dependencies
  }// end public func makeDevModuleDependencies
  
  public func makeDevModule() throws -> OSCADefect {
    let devDependencies = try makeDevModuleDependencies()
    // initialize module
    let module = OSCADefect.create(with: devDependencies)
    return module
  }// end public func makeDevModule
  
  public func makeProductionModuleDependencies() throws -> OSCADefectDependencies {
    let networkService = try makeProductionNetworkService()
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.defect")
    let dependencies = OSCADefectDependencies(
      networkService: networkService,
      userDefaults: userDefaults)
    return dependencies
  }// end public func makeProductionModuleDependencies
  
  public func makeProductionModule() throws -> OSCADefect {
    let productionDependencies = try makeProductionModuleDependencies()
    // initialize module
    let module = OSCADefect.create(with: productionDependencies)
    return module
  }// end public func makeProductionModule
}// end extension final class OSCAEventsTests
#endif
