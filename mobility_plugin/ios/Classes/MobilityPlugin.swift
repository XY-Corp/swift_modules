import Flutter
import UIKit
import HealthKit

// Flag to enable or disable logging
private let isLoggingEnabled = true

// Logging function with a prefix
private func log(_ message: String) {
    if isLoggingEnabled {
        print("[MobilityPlugin] \(message)")
    }
}

public class SwiftMobilityPlugin: NSObject, FlutterPlugin {
    private let healthStore = HKHealthStore()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mobility_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftMobilityPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        log("Handling method call: \(call.method)")
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
        case "getMobilityDataByType":
            getMobilityDataByType(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

private func getMobilityDataByType(call: FlutterMethodCall, result: @escaping FlutterResult) {
    log("getMobilityDataByType called with arguments: \(String(describing: call.arguments))")
    guard let args = call.arguments as? [String: Any],
          let typeString = args["type"] as? String,
          let startDateMillis = args["startDate"] as? Int,
          let endDateMillis = args["endDate"] as? Int else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for getMobilityDataByType", details: nil))
        return
    }

        guard let quantityType = getQuantityType(from: typeString) else {
            result(FlutterError(code: "INVALID_TYPE", message: "Invalid type: \(typeString)", details: nil))
            return
        }

    let startDate = Date(timeIntervalSince1970: TimeInterval(startDateMillis) / 1000)
    let endDate = Date(timeIntervalSince1970: TimeInterval(endDateMillis) / 1000)

    // Log the converted dates for debugging
    log("Converted startDate: \(startDate), endDate: \(endDate)")

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let error = error {
                log("Error fetching data: \(error.localizedDescription)")
                result(FlutterError(code: "ERROR_FETCHING_DATA", message: error.localizedDescription, details: nil))
                return
            }

            guard let samples = samples as? [HKQuantitySample] else {
                log("No samples found")
                result([:])
                return
            }

            let data = samples.map { sample -> [String: Any] in
                return [
                    "value": sample.quantity.doubleValue(for: self.unit(for: quantityType)),
                    "startDate": Int(sample.startDate.timeIntervalSince1970 * 1000),
                    "endDate": Int(sample.endDate.timeIntervalSince1970 * 1000),
                ]
            }

            log("Fetched data: \(data)")
            result(["data": data])
        }

        healthStore.execute(query)
    }

    private func getQuantityType(from typeString: String) -> HKQuantityType? {
        log("Getting quantity type for: \(typeString)")
        switch typeString {
        case "ASYMMETRY_PERCENTAGE":
            if #available(iOS 15.0, *) {
                return HKQuantityType.quantityType(forIdentifier: .walkingAsymmetryPercentage)
            }
        case "STEP_LENGTH":
            if #available(iOS 15.0, *) {
                return HKQuantityType.quantityType(forIdentifier: .stepLength)
            }
        case "WALKING_SPEED":
            if #available(iOS 15.0, *) {
                return HKQuantityType.quantityType(forIdentifier: .walkingSpeed)
            }
        case "DOUBLE_SUPPORT_PERCENTAGE":
            if #available(iOS 15.0, *) {
                return HKQuantityType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)
            }
        case "WALKING_STEADINESS":
            if #available(iOS 15.0, *) {
                return HKQuantityType.quantityType(forIdentifier: .walkingSteadiness)
            }
        default:
            return nil
        }
        return nil
    }

    private func unit(for quantityType: HKQuantityType) -> HKUnit {
        log("Getting unit for quantity type: \(quantityType.identifier)")
        switch quantityType.identifier {
        case HKQuantityTypeIdentifier.walkingAsymmetryPercentage.rawValue,
             HKQuantityTypeIdentifier.walkingDoubleSupportPercentage.rawValue:
            return HKUnit.percent()

        case HKQuantityTypeIdentifier.stepLength.rawValue:
            return HKUnit.meter()

        case HKQuantityTypeIdentifier.walkingSpeed.rawValue:
            return HKUnit(from: "m/s")

        case HKQuantityTypeIdentifier.walkingSteadiness.rawValue:
            return HKUnit.count()

        default:
            return HKUnit.count()
        }
    }

    private func requestAuthorization(completion: @escaping (Bool) -> Void) {
        log("Requesting authorization")
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
            log("Authorization success: \(success)")
            completion(success)
        }
    }

    private func handleGetAllMobilityData(result: @escaping FlutterResult) {
        log("Handling getAllMobilityData")
        fetchMobilityData(startDate: nil, endDate: nil, limit: HKObjectQueryNoLimit, result: result)
    }

private func handleGetMobilityData(call: FlutterMethodCall, result: @escaping FlutterResult) {
    log("Handling getMobilityData with arguments: \(String(describing: call.arguments))")
    guard let args = call.arguments as? [String: Any],
          let startDateMillis = args["startDate"] as? Int,
          let endDateMillis = args["endDate"] as? Int else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing startDate or endDate", details: nil))
        return
    }

    let startDate = Date(timeIntervalSince1970: TimeInterval(startDateMillis) / 1000)
    let endDate = Date(timeIntervalSince1970: TimeInterval(endDateMillis) / 1000)

    // Log the converted dates for debugging
    log("Converted startDate: \(startDate), endDate: \(endDate)")

    fetchMobilityData(startDate: startDate, endDate: endDate, limit: HKObjectQueryNoLimit, result: result)
}

    private func handleGetRecentMobilityData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        log("Handling getRecentMobilityData with arguments: \(String(describing: call.arguments))")
        guard let args = call.arguments as? [String: Any],
              let limit = args["limit"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing limit", details: nil))
            return
        }

        fetchMobilityData(startDate: nil, endDate: nil, limit: limit, result: result)
    }

    private func fetchMobilityData(startDate: Date?, endDate: Date?, limit: Int, result: @escaping FlutterResult) {
        log("Fetching mobility data with startDate: \(String(describing: startDate)), endDate: \(String(describing: endDate)), limit: \(limit)")
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
        log("Querying mobility data")
        let dispatchGroup = DispatchGroup()
        var allData = [String: [[String: Any]]]()
        var queryError: Error?

let predicate: NSPredicate? = {
    if let startDate = startDate, let endDate = endDate {
        log("Creating predicate with startDate: \(startDate), endDate: \(endDate)")
        return HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
    } else if let startDate = startDate {
        log("Creating predicate with startDate: \(startDate)")
        return HKQuery.predicateForSamples(withStart: startDate, end: nil, options: [])
    } else if let endDate = endDate {
        log("Creating predicate with endDate: \(endDate)")
        return HKQuery.predicateForSamples(withStart: nil, end: endDate, options: [])
    } else {
        log("No startDate or endDate provided; predicate will be nil")
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
                    log("Error querying data for \(key): \(error.localizedDescription)")
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
                log("Data for \(key): \(data)")
            }
            healthStore.execute(query)
        }

        dispatchGroup.notify(queue: .main) {
            if let error = queryError {
                log("Error fetching mobility data: \(error.localizedDescription)")
                result(FlutterError(code: "FETCH_ERROR", message: error.localizedDescription, details: nil))
            } else {
                log("Fetched all mobility data: \(allData)")
                result(allData)
            }
        }
    }

    private func getPlatformVersion(result: @escaping FlutterResult) {
        let systemVersion = UIDevice.current.systemVersion
        log("Getting platform version: iOS \(systemVersion)")
        result("iOS " + systemVersion)
    }
}