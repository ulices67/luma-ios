import WidgetKit
import SwiftUI


struct LumaWidgetsBundle: WidgetBundle {
    var body: some Widget {
        LumaHomeWidget()
        LumaLyricsLiveActivity()
        #if os(iOS)
        if #available(iOS 18.0, *) {
            LumaControlCenterWidget()
        }
        #endif
    }
}
