import Foundation
import XCTest
// Do not use `@testable` so we can test functions are made public and not `internal`.
import CioFirebaseWrapper
import CioMessagingPushFCM

class CioFirebaseWrapperAPITest: XCTestCase {
    
    func test_allPublicFunctions() throws {
        // Test that MessagingPushFCM.initialize() is accessible through the CioFirebaseWrapper extension
        // This is the main public API that consumers will use
        let _ = MessagingPushFCM.initialize()
        let _ = MessagingPushFCM.initialize(withConfig: MessagingPushConfigBuilder().build())
    }
}
