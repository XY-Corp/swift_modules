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
                    result(nil)
                } else {
                    result(FlutterError(code: "AUTH_ERROR", message: "Authorization failed", details: nil))
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func requestAuthorization(completion: @escaping (Bool) -> Void) {
        var mobilityTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .walkingSpeed)!,
        ]
        
        if #available(iOS 13.0, *) {
            mobilityTypes.insert(HKObjectType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)!)
            mobilityTypes.insert(HKObjectType.quantityType(forIdentifier: .walkingStepLength)!)
            mobilityTypes.insert(HKObjectType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!)
        }
        
        if #available(iOS 15.0, *) {
            mobilityTypes.insert(HKObjectType.quantityType(forIdentifier: .appleWalkingSteadiness)!)
        }
        
        healthStore.requestAuthorization(toShare: nil, read: mobilityTypes) { (success, error) in
            completion(success)
        }
    }

    private func fetchMobilityData(result: @escaping FlutterResult) {
        if #available(iOS 13.0, *) {
            var dataTypes: [String: HKQuantityTypeIdentifier] = [
                "walkingSpeed": .walkingSpeed,
                "doubleSupportPercentage": .walkingDoubleSupportPercentage,
                "stepLength": .walkingStepLength,
                "asymmetryPercentage": .walkingAsymmetryPercentage
            ]

            if #available(iOS 15.0, *) {
                dataTypes["walkingSteadiness"] = .appleWalkingSteadiness
            }

            queryMobilityData(dataTypes: dataTypes, result: result)
        } else {
            result(FlutterError(code: "UNAVAILABLE", message: "Mobility data is only available on iOS 13.0 or newer", details: nil))
        }
    }

    @available(iOS 13.0, *)
    private func queryMobilityData(dataTypes: [String: HKQuantityTypeIdentifier], result: @escaping FlutterResult) {
        let dispatchGroup = DispatchGroup()
        var allData = [String: [[String: Any]]]()
        var queryError: Error?

        for (key, identifier) in dataTypes {
            dispatchGroup.enter()
            guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
                dispatchGroup.leave()
                continue
            }

            let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                if let error = error {
                    queryError = error
                    dispatchGroup.leave()
                    return
                }

                var data = [[String: Any]]()
                
                let unit: HKUnit

                // Properly guard the use of .appleWalkingSteadiness
                if #available(iOS 15.0, *), identifier == .appleWalkingSteadiness {
                    unit = HKUnit.count()
                } else {
                    switch identifier {
                    case .walkingSpeed:
                        unit = HKUnit.meter().unitDivided(by: HKUnit.second())
                    case .walkingDoubleSupportPercentage, .walkingAsymmetryPercentage:
                        unit = HKUnit.percent()
                    case .walkingStepLength:
                        unit = HKUnit.meter()
                    case .stepCount:
                        unit = HKUnit.count()
                    default:
                        dispatchGroup.leave()
                        return
                    }
                }

                samples?.forEach { sample in
                    if let quantitySample = sample as? HKQuantitySample {
                        let value = quantitySample.quantity.doubleValue(for: unit)
                        let startDate = quantitySample.startDate.timeIntervalSince1970
                        let endDate = quantitySample.endDate.timeIntervalSince1970
                        data.append([
                            "value": value,
                            "startDate": startDate,
                            "endDate": endDate
                        ])
                    }
                }
                allData[key] = data
                dispatchGroup.leave()
            }
            healthStore.execute(query)
        }

        dispatchGroup.notify(queue: .main) {
            if let error = queryError {
                result(FlutterError(code: "FETCH_ERROR", message: error.localizedDescription, details: nil))
            } else {
                result(allData)
            }
        }
    }

    private func getPlatformVersion(result: @escaping FlutterResult) {
        let systemVersion = UIDevice.current.systemVersion
        result("iOS " + systemVersion)
    }
}