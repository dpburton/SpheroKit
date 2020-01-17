//
//  AppDelegate.swift
//  iOS Example
//
//  Created by Daniel Burton on 8/17/19.
//

import UIKit
import MetricKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads
        {
            print(String(data:payload.jsonRepresentation(), encoding: .utf8) ?? "oops")
            // application info
            print("Latest app version: \(payload.latestApplicationVersion)")
            if let metaData = payload.metaData {
                print("\tbuild: \(metaData.applicationBuildVersion) region: \(metaData.regionFormat) device: \(metaData.deviceType) os: \(metaData.osVersion)")
            }
            print("\tfrom: \(payload.timeStampBegin) to: \(payload.timeStampEnd)")
            print("\tincludes multiple versions: \(payload.includesMultipleApplicationVersions)")

            // performance metrics
            print("\nPERFORMANCE METRICS")
            if let appLaunchMetrics = payload.applicationLaunchMetrics {
                print("Time to fist draw:")
                printHistogram(appLaunchMetrics.histogrammedTimeToFirstDraw as! MXHistogram<Unit>)
                print("App resume time:")
                printHistogram(appLaunchMetrics.histogrammedApplicationResumeTime as! MXHistogram<Unit>)
            }
            if let responseMetrics = payload.applicationResponsivenessMetrics {
                print("Hang time:")
                printHistogram(responseMetrics.histogrammedApplicationHangTime as! MXHistogram<Unit>)
            }
            if let runTimeMetric = payload.applicationTimeMetrics {
                print("Cumulative foreground time: \(runTimeMetric.cumulativeForegroundTime.value) \(runTimeMetric.cumulativeForegroundTime.unit.symbol)")
                print("Cumulative background time: \(runTimeMetric.cumulativeBackgroundTime.value) \(runTimeMetric.cumulativeBackgroundTime.unit.symbol)")
                print("Cumulative background audio time: \(runTimeMetric.cumulativeBackgroundAudioTime.value) \(runTimeMetric.cumulativeBackgroundAudioTime.unit.symbol)")
                print("Cumulative background location time: \(runTimeMetric.cumulativeBackgroundLocationTime.value) \(runTimeMetric.cumulativeBackgroundLocationTime.unit.symbol)")
            }
            if let _ = payload.memoryMetrics {
            }

            // battery metrics
            print("\nBATTERY METRICS")
            if let cellConditions = payload.cellularConditionMetrics {
                print("Cellular condition:")
                printHistogram(cellConditions.histogrammedCellularConditionTime as! MXHistogram<Unit>)
            }
            if let cpuMetrics = payload.cpuMetrics {
                print("Cumulative cpu time: \(cpuMetrics.cumulativeCPUTime.value) \(cpuMetrics.cumulativeCPUTime.unit.symbol)")
            }
            if let displayMetrics = payload.displayMetrics?.averagePixelLuminance {
                print("Display pixel luminance: \(displayMetrics.averageMeasurement.value) \(displayMetrics.averageMeasurement.unit.symbol)")
                print("\tSample count: \(displayMetrics.sampleCount) σ: \(displayMetrics.standardDeviation)")
            }
            if let gpuMetrics = payload.gpuMetrics {
                print("Cumulative gpu time: \(gpuMetrics.cumulativeGPUTime.value) \(gpuMetrics.cumulativeGPUTime.unit.symbol)")
            }
            if let locationMetrics = payload.locationActivityMetrics {
                print("Cumulative navigation time: \(locationMetrics.cumulativeBestAccuracyTime.value) \(locationMetrics.cumulativeBestAccuracyTime.unit.symbol)")
                print("Cumulative best location time: \(locationMetrics.cumulativeBestAccuracyTime.value) \(locationMetrics.cumulativeBestAccuracyTime.unit.symbol)")
                print("Cumulative 10 m location time: \(locationMetrics.cumulativeNearestTenMetersAccuracyTime.value) \(locationMetrics.cumulativeNearestTenMetersAccuracyTime.unit.symbol)")
                print("Cumulative 100 m location time: \(locationMetrics.cumulativeHundredMetersAccuracyTime.value) \(locationMetrics.cumulativeHundredMetersAccuracyTime.unit.symbol)")
                print("Cumulative 1 k location time: \(locationMetrics.cumulativeKilometerAccuracyTime.value) \(locationMetrics.cumulativeKilometerAccuracyTime.unit.symbol)")
                print("Cumulative 3 k location time: \(locationMetrics.cumulativeThreeKilometersAccuracyTime.value) \(locationMetrics.cumulativeThreeKilometersAccuracyTime.unit.symbol)")
            }
            if let networkMetrics = payload.networkTransferMetrics {
                print("Cumulative cell download: \(networkMetrics.cumulativeCellularDownload.value) \(networkMetrics.cumulativeCellularDownload.unit.symbol)")
                print("Cumulative cell upload: \(networkMetrics.cumulativeCellularUpload.value) \(networkMetrics.cumulativeCellularUpload.unit.symbol)")
                print("Cumulative WiFi download: \(networkMetrics.cumulativeWifiDownload.value) \(networkMetrics.cumulativeWifiDownload.unit.symbol)")
                print("Cumulative WiFi download: \(networkMetrics.cumulativeWifiUpload.value) \(networkMetrics.cumulativeWifiUpload.unit.symbol)")
            }

            // disk access metrics
            if let diskMetrics = payload.diskIOMetrics {
                print("\nDISK METRICS")
                print("Cumulative logical writes: \(diskMetrics.cumulativeLogicalWrites.value) \(diskMetrics.cumulativeLogicalWrites.unit.symbol)")

            }

            // custom metrics
            print("\nSIGNPOST METRICS")
            if let signpostMetrics = payload.signpostMetrics {
                for signpostMetric in signpostMetrics {
                    print("\(signpostMetric.signpostCategory):\(signpostMetric.signpostName) ")
                    print("\tcount\(signpostMetric.totalCount)")
                    if let intervalData = signpostMetric.signpostIntervalData {
                        print("\tavg mem:\(String(describing: intervalData.averageMemory)) cpu:\(intervalData.cumulativeCPUTime) gpu:\(intervalData.cumulativeCPUTime)")
                        printHistogram(intervalData.histogrammedSignpostDuration as! MXHistogram<Unit>)
                    }

                }


            }

        }
    }

    func printHistogram(_ histogram: MXHistogram<Unit>)
    {
        for item in histogram.bucketEnumerator {
            if let bucket = item as? MXHistogramBucket {
                if bucket.bucketStart == bucket.bucketEnd {
                    print("\t\(bucket.bucketStart.value) \(bucket.bucketStart.unit.symbol):(\(bucket.bucketCount))", terminator:"")

                } else {
                    if bucket.bucketStart.unit.symbol == bucket.bucketEnd.unit.symbol {
                        print("\t\(bucket.bucketStart.value) - \(bucket.bucketEnd.value) \(bucket.bucketStart.unit.symbol):(\(bucket.bucketCount))", terminator:"")
                    } else {
                        print("\t\(bucket.bucketStart.value) \(bucket.bucketStart.unit.symbol) - \(bucket.bucketEnd.value) \(bucket.bucketEnd.unit.symbol):(\(bucket.bucketCount))", terminator:"")
                    }
                }
                var count = bucket.bucketCount
                while count > 100 {
                    count /= 10
                }
                for _ in 1...bucket.bucketCount {
                    print("*", terminator:"")
                }
                print()
            }
        }

    }

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MXMetricManager.shared.add(self)
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

