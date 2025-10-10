import CioMessagingPushFCM
import FirebaseMessaging

internal class FirebaseImpl: FirebaseService {
    private let firebaseAdapter = FirebaseDelegateAdapter(cioFCMMessagingDelegate: nil)
    
    public var apnsToken: Data? {
        get { return Messaging.messaging().apnsToken }
        set { Messaging.messaging().apnsToken = newValue }
    }

    public var delegate: FirebaseServiceDelegate? {
        get { return firebaseAdapter.cioFCMMessagingDelegate }
        set {
            firebaseAdapter.cioFCMMessagingDelegate = newValue
            Messaging.messaging().delegate = firebaseAdapter
        }
    }

    public func fetchToken(completion: @escaping (String?, Error?) -> Void) {
        Messaging.messaging().token(completion: completion)
    }
}

// Firebase delegate adapter to bridge between CioFCMMessagingDelegate and MessagingDelegate
internal class FirebaseDelegateAdapter: NSObject, MessagingDelegate {
    weak var cioFCMMessagingDelegate: FirebaseServiceDelegate?
    
    public init(cioFCMMessagingDelegate: FirebaseServiceDelegate?) {
        self.cioFCMMessagingDelegate = cioFCMMessagingDelegate
    }
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        cioFCMMessagingDelegate?.didReceiveRegistrationToken(fcmToken)
    }
}
