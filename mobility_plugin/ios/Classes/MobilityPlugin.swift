import Flutter
import UIKit
import HealthKit

public class SwiftMobilityPlugin: NSObject, FlutterPlugin {
    private let healthStore = HKHealthStore()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mobility_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftMobilityPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getMobilityData":
            fetchMobilityData(result: result)
        case "getPlatformVersion":
            self.getPlatformVersion(result: result)
        case "requestAuthorization":
            requestAuthorization { (success) in
                if success {
                    result(nil) // Indicate success without data
                } else {
                    result(FlutterError(code: "AUTH_ERROR", message: "Authorization failed", details: nil))
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let mobilityTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .walkingSpeed)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            // Add other required mobility data types here
        ]
        healthStore.requestAuthorization(toShare: nil, read: mobilityTypes) { (success, error) in
            completion(success)
        }
    }

    private func fetchMobilityData(result: @escaping FlutterResult) {
        if #available(iOS 14.0, *) {
            let walkingSpeedType = HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!
            
            // Check authorization status
            let authorizationStatus = healthStore.authorizationStatus(for: walkingSpeedType)
            if authorizationStatus != .sharingAuthorized {
                // Request authorization
                requestAuthorization { (success) in
                    if success {
                        // After authorization, fetch data
                        self.queryWalkingSpeedData(result: result)
                    } else {
                        result(FlutterError(code: "AUTH_ERROR", message: "Authorization failed", details: nil))
                    }
                }
            } else {
                // Authorization already granted, fetch data
                queryWalkingSpeedData(result: result)
            }
        } else {
            result(FlutterError(code: "UNAVAILABLE", message: "Walking speed is only available on iOS 14.0 or newer", details: nil))
        }
    }

    // Extracted method to query walking speed data
    @available(iOS 14.0, *)
    private func queryWalkingSpeedData(result: @escaping FlutterResult) {
        let walkingSpeedType = HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!
        let query = HKSampleQuery(sampleType: walkingSpeedType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "FETCH_ERROR", message: error.localizedDescription, details: nil))
                return
            }

            var data = [[String: Any]]()

            // Define the speed unit
            let speedUnit = HKUnit.meter().unitDivided(by: HKUnit.second())

            samples?.forEach { sample in
                if let quantitySample = sample as? HKQuantitySample {
                    let value = quantitySample.quantity.doubleValue(for: speedUnit)
                    let startDate = quantitySample.startDate.timeIntervalSince1970
                    let endDate = quantitySample.endDate.timeIntervalSince1970
                    data.append([
                        "value": value,
                        "startDate": startDate,
                        "endDate": endDate
                    ])
                }
            }
            result(data)
        }
        healthStore.execute(query)
    }

    // New method
    private func getPlatformVersion(result: @escaping FlutterResult) {
        let systemVersion = UIDevice.current.systemVersion
        result("iOS " + systemVersion)
    }
}