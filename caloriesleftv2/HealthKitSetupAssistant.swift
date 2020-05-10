import HealthKit

class HealthKitSetupAssistant {

    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }

    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {

        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }

        guard   let dietaryEnergyConsumed = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed),
            let basalEnergyBurned = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned),
            let activeEnergyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {

                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
        }

        let healthKitTypesToRead: Set<HKObjectType> = [dietaryEnergyConsumed,
                                                       basalEnergyBurned,
                                                       activeEnergyBurned]

        //4. Request Authorization
        HKHealthStore().requestAuthorization(toShare: nil,
                                             read: healthKitTypesToRead) { (success, error) in
                                                completion(success, error)
        }
    }
}
