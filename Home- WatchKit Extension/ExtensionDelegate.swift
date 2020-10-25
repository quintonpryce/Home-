//
// ExtensionDelegate.swift
// Home+ WatchKit Extension
//
// 🖌 by Q on 2020-09-15.
//

import WatchKit


class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() { }

    func applicationDidBecomeActive() { }

    func applicationWillResignActive() { }
    
    func applicationWillEnterForeground() {
        PrimaryHome.shared.updateAccessories()
    }
    
    func applicationDidEnterBackground() {
        scheduleBackgroundRefreshTasks()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                ComplicationHomeProvider.shared = ComplicationHomeProvider()
                ComplicationHomeProvider.shared.completion = {
                    // Schedule the next background update.
                    self.scheduleBackgroundRefreshTasks()
                    
                    // Mark the task as ended, and request an updated snapshot.
                    backgroundTask.setTaskCompletedWithSnapshot(true)
                }
                
//                ComplicationHomeProvider.shared.forceUpdateNumberOfAccessoriesOn()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    // Schedule the next background refresh task.
    func scheduleBackgroundRefreshTasks() {
        
        // Get the shared extension object.
        let watchExtension = WKExtension.shared()
        
        // If there is a complication on the watch face, the app should get at least four
        // updates an hour. So calculate a target date 15 minutes in the future.
        let targetDate = Date().addingTimeInterval(0.5 * 60.0)
        
        // Schedule the background refresh task.
        watchExtension.scheduleBackgroundRefresh(withPreferredDate: targetDate, userInfo: nil) { (error) in
            
            // Check for errors.
            if let error = error {
                Log.i("*** An background refresh error occurred: \(error.localizedDescription) ***")
                return
            }
            
            Log.i("*** Background Task Completed Successfully! ***")
        }
    }

}
