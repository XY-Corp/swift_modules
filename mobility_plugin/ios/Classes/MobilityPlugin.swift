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
        case "getAllMobilityData":
            handleGetAllMobilityData(result: result)
        case "getMobilityData":
            handleGetMobilityData(call: call, result: result)
        case "getRecentMobilityData":
            handleGetRecentMobilityData(call: call, result: result)
        case "getPlatformVersion":
            getPlatformVersion(result: result)
        case "requestAuthorization":
            requestAuthorization { success in
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

        healthStore.requestAuthorization(toShare: nil, read: mobilityTypes) { success, _ in
            completion(success)
        }
    }

    private func handleGetAllMobilityData(result: @escaping FlutterResult) {
        fetchMobilityData(startDate: nil, endDate: nil, limit: HKObjectQueryNoLimit, result: result)
    }

    private func handleGetMobilityData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let startDateMillis = args["startDate"] as? Double,
              let endDateMillis = args["endDate"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing startDate or endDate", details: nil))
            return
        }

        let startDate = Date(timeIntervalSince1970: startDateMillis / 1000)
        let endDate = Date(timeIntervalSince1970: endDateMillis / 1000)

        fetchMobilityData(startDate: startDate, endDate: endDate, limit: HKObjectQueryNoLimit, result: result)
    }

    private func handleGetRecentMobilityData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let limit = args["limit"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing limit", details: nil))
            return
        }

        fetchMobilityData(startDate: nil, endDate: nil, limit: limit, result: result)
    }

    private func fetchMobilityData(startDate: Date?, endDate: Date?, limit: Int, result: @escaping FlutterResult) {
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

            queryMobilityData(dataTypes: dataTypes, startDate: startDate, endDate: endDate, limit: limit, result: result)
        } else {
            result(FlutterError(code: "UNAVAILABLE", message: "Mobility data is only available on iOS 13.0 or newer", details: nil))
        }
    }

    @available(iOS 13.0, *)
    private func queryMobilityData(dataTypes: [String: HKQuantityTypeIdentifier], startDate: Date?, endDate: Date?, limit: Int, result: @escaping FlutterResult) {
        let dispatchGroup = DispatchGroup()
        var allData = [String: [[String: Any]]]()
        var queryError: Error?

    let predicate: NSPredicate? = {
        if let startDate = startDate, let endDate = endDate {
            return HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])
        } else if let startDate = startDate {
            return HKQuery.predicateForSamples(withStart: startDate, end: nil, options: [.strictStartDate])
        } else if let endDate = endDate {
            return HKQuery.predicateForSamples(withStart: nil, end: endDate, options: [.strictEndDate])
        } else {
            return nil
        }
    }()

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        for (key, identifier) in dataTypes {
            dispatchGroup.enter()
            guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
                dispatchGroup.leave()
                continue
            }

            let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { _, samples, error in
                defer { dispatchGroup.leave() }

                if let error = error {
                    queryError = error
                    return
                }

                var data = [[String: Any]]()
                let unit: HKUnit

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
                    default:
                        return
                    }
                }

                samples?.forEach { sample in
                    if let quantitySample = sample as? HKQuantitySample {
                        let value = quantitySample.quantity.doubleValue(for: unit)
                        let startDate = quantitySample.startDate.timeIntervalSince1970 * 1000
                        let endDate = quantitySample.endDate.timeIntervalSince1970 * 1000
                        data.append([
                            "value": value,
                            "startDate": startDate,
                            "endDate": endDate
                        ])
                    }
                }
                allData[key] = data
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