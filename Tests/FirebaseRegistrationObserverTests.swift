@testable import CioFirebaseWrapper
import FirebaseMessaging
import XCTest

class FirebaseRegistrationObserverTests: XCTestCase {
    private var notificationCenter: NotificationCenter!
    private var observer: FirebaseRegistrationObserver!
    private var mockDelegate: MockFirebaseServiceDelegate!

    override func setUp() {
        super.setUp()

        notificationCenter = NotificationCenter()
        mockDelegate = MockFirebaseServiceDelegate()
        observer = FirebaseRegistrationObserver(notificationCenter: notificationCenter)
        observer.delegate = mockDelegate
    }

    override func tearDown() {
        observer = nil
        mockDelegate = nil
        notificationCenter = nil

        super.tearDown()
    }

    func testRegistrationRefreshed_givenTokenMode_expectToken() {
        notificationCenter.post(name: .MessagingRegistrationTokenRefreshed, object: "fcm_token")

        XCTAssertEqual(mockDelegate.receivedToken, "fcm_token")
        XCTAssertEqual(mockDelegate.tokenCallCount, 1)
        XCTAssertTrue(mockDelegate.receivedRegistrations.isEmpty)
    }

    func testRegistrationRefreshed_givenFidMode_expectRegistration() {
        observer.isInstallationIdEnabled = { true }

        notificationCenter.post(name: .MessagingRegistrationTokenRefreshed, object: "fid")

        XCTAssertEqual(mockDelegate.receivedRegistrations, ["fid"])
        XCTAssertEqual(mockDelegate.tokenCallCount, 0)
    }

    func testRegistrationRefreshed_givenNoValue_expectNilForwarded() {
        notificationCenter.post(name: .MessagingRegistrationTokenRefreshed, object: nil)

        XCTAssertNil(mockDelegate.receivedToken)
        XCTAssertEqual(mockDelegate.tokenCallCount, 1)
    }

    func testInstallationIdUnregistered_expectUnregister() {
        notificationCenter.post(name: FirebaseRegistrationObserver.installationIdUnregistered, object: "fid")

        XCTAssertEqual(mockDelegate.receivedUnregistrations, ["fid"])
    }

    func testInstallationIdUnregistered_givenFirebaseWithFidRegistration_expectFirebaseNotificationName() throws {
        guard Messaging.instancesRespond(to: NSSelectorFromString("registerWithCompletion:")) else {
            throw XCTSkip("FirebaseMessaging before 12.16.0")
        }
        // Firebase's constant, looked up at runtime because older Firebase versions don't have it.
        // Needs Firebase's exported symbols, as in the SwiftPM source build.
        let rtldDefault = UnsafeMutableRawPointer(bitPattern: -2)
        let symbol = try XCTUnwrap(dlsym(rtldDefault, "FIRMessagingInstallationIdUnregisteredNotification"))
        let firebaseName = symbol.assumingMemoryBound(to: NSString.self).pointee

        XCTAssertEqual(FirebaseRegistrationObserver.installationIdUnregistered.rawValue, firebaseName as String)
    }

    func testNotifications_givenNoDelegate_expectNothingForwarded() {
        observer.delegate = nil

        notificationCenter.post(name: .MessagingRegistrationTokenRefreshed, object: "fcm_token")
        notificationCenter.post(name: FirebaseRegistrationObserver.installationIdUnregistered, object: "fid")

        XCTAssertEqual(mockDelegate.tokenCallCount, 0)
        XCTAssertTrue(mockDelegate.receivedUnregistrations.isEmpty)
    }
}
