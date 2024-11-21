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
            requestAuthorization { (success) in
                if success {
                    self.fetchMobilityData(result: result)
                } else {
                    result(FlutterError(code: "AUTH_ERROR", message: "Authorization failed", details: nil))
                }
            }
        case "getPlatformVersion":
            self.getPlatformVersion(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let mobilityTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .walkingSpeed)!,
            // Add other mobility data types you need
        ]
        healthStore.requestAuthorization(toShare: nil, read: mobilityTypes) { (success, error) in
            completion(success)
        }
    }

    private func fetchMobilityData(result: @escaping FlutterResult) {
        let walkingSpeedType = HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!
        let query = HKSampleQuery(sampleType: walkingSpeedType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "FETCH_ERROR", message: error.localizedDescription, details: nil))
                return
            }

            var data = [[String: Any]]()
            samples?.forEach { sample in
                if let quantitySample = sample as? HKQuantitySample {
                    let value = quantitySample.quantity.doubleValue(for: HKUnit.meterPerSecond())
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