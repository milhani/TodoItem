import Foundation
import CocoaLumberjackSwift

extension TodoItem__YSHMR_App {
    func initLog() {
        DDLog.add(DDOSLogger.sharedInstance)
        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours.
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
        DDLogDebug("Logger has been activated")
    }
}
