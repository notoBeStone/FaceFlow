
import GLMP
import GLTrackingExtension

typealias TrackKey = String

extension TrackKey {
    static var TRACK_KEY_INT1: Self { GLT_PARAM_INT1 }
    static var TRACK_KEY_INT2: Self { GLT_PARAM_INT2 }
    static var TRACK_KEY_INT3: Self { GLT_PARAM_INT3 }
    static var TRACK_KEY_INT4: Self { GLT_PARAM_INT4 }
    static var TRACK_KEY_INT5: Self { GLT_PARAM_INT5 }
    
    static var TRACK_KEY_STRING1: Self { GLT_PARAM_STRING1 }
    static var TRACK_KEY_STRING2: Self { GLT_PARAM_STRING2 }
    static var TRACK_KEY_STRING3: Self { GLT_PARAM_STRING3 }
    static var TRACK_KEY_STRING4: Self { GLT_PARAM_STRING4 }
    static var TRACK_KEY_STRING5: Self { GLT_PARAM_STRING5 }

    static var TRACK_KEY_ID: Self { GLT_PARAM_ID }
    static var TRACK_KEY_FROM: Self { GLT_PARAM_FROM }
    static var TRACK_KEY_VALUE: Self { GLT_PARAM_VALUE }
    static var TRACK_KEY_CONTENT: Self { GLT_PARAM_CONTENT }
    static var TRACK_KEY_TYPE: Self { GLT_PARAM_TYPE }

}

extension TrackingEvent {
    func report(_ params: [TrackKey: Any]? = nil) {
        GLMPTracking.tracking(self.rawValue, parameters: params)
    }
}
