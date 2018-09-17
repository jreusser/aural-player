import Cocoa

class RegularAppModeController: AppModeController {
    
    var mode: AppMode {return .regular}
    private lazy var layoutManager: WindowLayoutManager = WindowLayoutManager()
    private var constituentViews: [ConstituentView] = []
    
    func presentMode() {
        NSApp.setActivationPolicy(.regular)
        layoutManager.initialWindowLayout()
//        print("After presenting, views=" + String(describing: constituentViews.count))
    }
    
    func dismissMode() {
        layoutManager.closeWindows()
        constituentViews.forEach({$0.deactivate()})
    }
    
    func registerConstituentView(_ view: ConstituentView) {
        constituentViews.append(view)
    }
}
