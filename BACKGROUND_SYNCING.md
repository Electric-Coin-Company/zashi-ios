# Background Syncing

## Sources
We encourage you to watch WWDC videos:
 - [Advances in App Background Execution]: https://developer.apple.com/videos/play/wwdc2019/707
 - [Background execution demystified]: https://developer.apple.com/videos/play/wwdc2020/10063
 
## Implementation details
There are 4 different APIs and types of background tasks. Each one is specific and can be used for different scenarios. Synchronization of the blockchain data is time and memory consuming operation. Therefore the `BGProcessingTask` has been used. This type of task is designed to run for a longer time when certain conditions are met (watch Background execution demystified).

### Steps to make it work
1. Add a capability of `background modes` in the settings of the xcode project.
2. Turn the `Background Processing` mode on in the new capability.
3. Add `Permitted background task scheduler identifiers` to the info.plist.
4. Create the ID for the background task in the newly created array. 
5. Register the BGTask in `application.didFinishLaunchingWithOptions`
```Swift
BGTaskScheduler.shared.register(
    forTaskWithIdentifier: <ID>,
    using: DispatchQueue.main
) { task in
    // see the next steps
}
```
Note: The queue is an optional and most tutorials leave the parameter `nil` but Zashi requires main thread processing due to UI layer - therefore we pass `DispatchQueue.main`.
6. Call a method that schedules the task execution.
7. Start the synchronizer.
8. Set the expiration closure and stop the synchronizer inside it
```swift
task.expirationHandler = { 
    synchronizer.stop()
}
```
9. The body of the registered task summarized:
```swift
BGTaskScheduler.shared.register(...) { task in
    scheduleTask() // 6
    
    synchronizer.start() // 7
    
    task.expirationHandler = { 
        synchronizer.stop() // 8
    }
}
```
10. Call `scheduleTask()` when app goes to the background so there is the initial scheduling done, the next one will be handled by the closure of the registered task. The method usually consists of:
```Swift
let request = BGProcessingTaskRequest(identifier: <ID>)

request.earliestBeginDate = <scheduledTime>
request.requiresExternalPower = true            // optional, we require the iPhone to be connected to the power
request.requiresNetworkConnectivity = true      // required

do {
    try BGTaskScheduler.shared.submit(request)
} catch { // handle error }
```
11. Last step is to call `.setTaskCompleted(success: <bool>)` on the BGTask when the work is done. This is required by the system no matter what. We call it with `true` when the synchronizer finishes the work (up-to-date state) and with `false` for other or failed reasons (stopped state, error state, etc.).

You can see specific details of the Zashi implementation in:
- Xcode project settings, steps 1-4.
- AppDelegate.swift file, steps 5-9.
- SecantApp.swift file, step 10.
- RootInitialization.swift, step 11.

## Gotchas
- The `requiresNetworkConnectivity` flag doesn't specify or deal with the type of connectivity. It simply allows scheduling when the iPhone is connected to the internet. We deal with it when the task is triggered. The custom check whether the wifi is or is not connected preceds the start of the synchronizer.
- When the app is killed by a user in the app switcher, the scheduled BGTask is deleted. So the BGTask is triggered at the scheduled time only when the app is suspended or killed by the system. Explicit termination of the app by a user leads to termination of any background processing.