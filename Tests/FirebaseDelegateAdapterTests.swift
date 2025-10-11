@testable import CioFirebaseWrapper
import CioMessagingPushFCM
import FirebaseMessaging
import XCTest

class FirebaseDelegateAdapterTests: XCTestCase {
    var adapter: FirebaseDelegateAdapter!
    var mockDelegate: MockFirebaseServiceDelegate!

    override func setUp() {
        super.setUp()
        mockDelegate = MockFirebaseServiceDelegate()
        adapter = FirebaseDelegateAdapter(cioFCMMessagingDelegate: mockDelegate)
    }

    override func tearDown() {
        adapter = nil
        mockDelegate = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationWithDelegate() {
        // Given
        let delegate = MockFirebaseServiceDelegate()

        // When
        let adapter = FirebaseDelegateAdapter(cioFCMMessagingDelegate: delegate)

        // Then
        XCTAssertNotNil(adapter)
        XCTAssertTrue(adapter.cioFCMMessagingDelegate === delegate)
    }

    func testInitializationWithNilDelegate() {
        // When
        let adapter = FirebaseDelegateAdapter(cioFCMMessagingDelegate: nil)

        // Then
        XCTAssertNotNil(adapter)
        XCTAssertNil(adapter.cioFCMMessagingDelegate)
    }

    // MARK: - Delegate Forwarding Tests

    func testMessagingDelegateMethodForwardsToMockDelegate() {
        // Given
        let expectedToken = "test_fcm_token_12345"
        let mockMessaging = Messaging.messaging()

        // When
        adapter.messaging(mockMessaging, didReceiveRegistrationToken: expectedToken)

        // Then
        XCTAssertEqual(mockDelegate.receivedToken, expectedToken)
        XCTAssertEqual(mockDelegate.tokenCallCount, 1)
    }

    func testMessagingDelegateMethodWithNilToken() {
        // Given
        let mockMessaging = Messaging.messaging()

        // When
        adapter.messaging(mockMessaging, didReceiveRegistrationToken: nil)

        // Then
        XCTAssertNil(mockDelegate.receivedToken)
        XCTAssertEqual(mockDelegate.tokenCallCount, 1)
    }

    func testMessagingDelegateMethodWithEmptyToken() {
        // Given
        let emptyToken = ""
        let mockMessaging = Messaging.messaging()

        // When
        adapter.messaging(mockMessaging, didReceiveRegistrationToken: emptyToken)

        // Then
        XCTAssertEqual(mockDelegate.receivedToken, emptyToken)
        XCTAssertEqual(mockDelegate.tokenCallCount, 1)
    }

    func testMultipleTokenUpdates() {
        // Given
        let token1 = "token_1"
        let token2 = "token_2"
        let token3 = "token_3"
        let mockMessaging = Messaging.messaging()

        // When
        adapter.messaging(mockMessaging, didReceiveRegistrationToken: token1)
        adapter.messaging(mockMessaging, didReceiveRegistrationToken: token2)
        adapter.messaging(mockMessaging, didReceiveRegistrationToken: token3)

        // Then
        XCTAssertEqual(mockDelegate.receivedToken, token3)
        XCTAssertEqual(mockDelegate.tokenCallCount, 3)
    }

    // MARK: - Delegate Management Tests

    func testDelegateCanBeChanged() {
        // Given
        let newDelegate = MockFirebaseServiceDelegate()
        let token = "test_token"
        let mockMessaging = Messaging.messaging()

        // When
        adapter.cioFCMMessagingDelegate = newDelegate
        adapter.messaging(mockMessaging, didReceiveRegistrationToken: token)

        // Then
        XCTAssertTrue(adapter.cioFCMMessagingDelegate === newDelegate)
        XCTAssertEqual(newDelegate.receivedToken, token)
        XCTAssertEqual(newDelegate.tokenCallCount, 1)
        XCTAssertEqual(mockDelegate.tokenCallCount, 0)
    }

    func testDelegateCanBeSetToNil() {
        // Given
        let token = "test_token"
        let mockMessaging = Messaging.messaging()

        // When
        adapter.cioFCMMessagingDelegate = nil
        adapter.messaging(mockMessaging, didReceiveRegistrationToken: token)

        // Then
        XCTAssertNil(adapter.cioFCMMessagingDelegate)
        XCTAssertEqual(mockDelegate.tokenCallCount, 0)
    }
}

// MARK: - Mock FirebaseServiceDelegate

class MockFirebaseServiceDelegate: FirebaseServiceDelegate {
    var receivedToken: String?
    var tokenCallCount = 0

    func didReceiveRegistrationToken(_ token: String?) {
        receivedToken = token
        tokenCallCount += 1
    }

    func reset() {
        receivedToken = nil
        tokenCallCount = 0
    }
}
