import CioMessagingPush
import CioMessagingPushFCM

import Foundation

public extension MessagingPushFCM {
    /**
     Initialize and configure `MessagingPushFCM`.
     Call this function in your app if you want to initialize and configure the module to
     auto-fetch device token and auto-register device with Customer.io.
     */
    @discardableResult
    @available(iOSApplicationExtension, unavailable)
    static func initialize(
        withConfig config: MessagingPushConfigOptions = MessagingPushConfigBuilder().build()
    ) -> MessagingPushInstance {
        internalSetup(withConfig: config, firebaseService: FirebaseImpl())
    }
}
