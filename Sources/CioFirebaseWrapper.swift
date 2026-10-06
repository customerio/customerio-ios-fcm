import CioMessagingPushFCM
import FirebaseInstallations
import FirebaseMessaging

// FID registration APIs, added in FirebaseMessaging 12.16.0.
// Called at runtime so the wrapper still builds with older Firebase versions.
@objc private protocol FIDRegistration {
    var isInstallationIdEnabled: Bool { get }
    func register(completion: @escaping (Error?) -> Void)
}

class FirebaseImpl: FirebaseService {
    private let firebaseAdapter = FirebaseDelegateAdapter(cioFCMMessagingDelegate: nil)

    public var apnsToken: Data? {
        get { Messaging.messaging().apnsToken }
        set { Messaging.messaging().apnsToken = newValue }
    }

    public var delegate: FirebaseServiceDelegate? {
        get { firebaseAdapter.cioFCMMessagingDelegate }
        set {
            firebaseAdapter.cioFCMMessagingDelegate = newValue
            Messaging.messaging().delegate = firebaseAdapter
        }
    }

    public func fetchToken(completion: @escaping (String?, Error?) -> Void) {
        Messaging.messaging().token(completion: completion)
    }

    public var isInstallationIdEnabled: Bool {
        fidRegistration?.isInstallationIdEnabled ?? false
    }

    public func fetchInstallationId(completion: @escaping (String?, Error?) -> Void) {
        guard let fidRegistration = fidRegistration else {
            completion(nil, nil)
            return
        }
        fidRegistration.register { error in
            if let error = error {
                completion(nil, error)
                return
            }
            // The FID Firebase registered with FCM
            Installations.installations().installationID(completion: completion)
        }
    }

    // nil when the app's Firebase version has no FID registration
    private var fidRegistration: FIDRegistration? {
        let messaging = Messaging.messaging()
        guard messaging.responds(to: #selector(FIDRegistration.register(completion:))),
              messaging.responds(to: #selector(getter: FIDRegistration.isInstallationIdEnabled))
        else {
            return nil
        }
        return unsafeBitCast(messaging, to: FIDRegistration.self)
    }
}

// Firebase delegate adapter to bridge between CioFCMMessagingDelegate and MessagingDelegate
class FirebaseDelegateAdapter: NSObject, MessagingDelegate {
    weak var cioFCMMessagingDelegate: FirebaseServiceDelegate?

    public init(cioFCMMessagingDelegate: FirebaseServiceDelegate?) {
        self.cioFCMMessagingDelegate = cioFCMMessagingDelegate
    }

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        cioFCMMessagingDelegate?.didReceiveRegistrationToken(fcmToken)
    }
}
