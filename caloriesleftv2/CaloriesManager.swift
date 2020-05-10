//
//  CaloriesManager.swift
//  caloriesleftv2
//
//  Created by mariano latorre on 10/05/2020.
//  Copyright © 2020 mariano latorre. All rights reserved.
//

import HealthKit


struct CaloriesModel {
    let activeEnergyBurned: Int
    let basalEnergyBurned: Int
    let dietaryEnergyConsumed: Int
}

class CaloriesManager {

    class func loadCumulativeCaloryValues(_ completionModel: @escaping (CaloriesModel) -> Swift.Void) {

        guard let activeEnergyBurnedQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("activeEnergyBurned Sample Type is no longer available in HealthKit")
            return
        }

        guard let basalEnergyBurnedQuantityType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned) else {
            print("basalEnergyBurned Sample Type is no longer available in HealthKit")
            return
        }

        guard let dietaryEnergyConsumedQuantityType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed) else {
            print("dietaryEnergyConsumed Sample Type is no longer available in HealthKit")
            return
        }

        let dispatchGroup = DispatchGroup()

        var activeEnergyBurned = 0.0
        var basalEnergyBurned = 0.0
        var dietaryEnergyConsumed = 0.0

        func calculateCumulative(for quantityType: HKQuantityType,
                             completionCumulative: @escaping (Double) -> Swift.Void ) {
            dispatchGroup.enter()
            CaloriesDataStore.getCumulativeCalories(for: quantityType) { (activeTotal, error) in

                guard let activeTotal = activeTotal else {
                    if let error = error {
                        print(error)
                        completionCumulative(0.0)
                    }

                    return
                }

                print(activeTotal)
                completionCumulative(activeTotal)
            }
        }

        calculateCumulative(for: activeEnergyBurnedQuantityType) { (value) in
            activeEnergyBurned = value
            dispatchGroup.leave()
        }

        calculateCumulative(for: basalEnergyBurnedQuantityType) { (value) in
            basalEnergyBurned = value
            dispatchGroup.leave()
        }
        calculateCumulative(for: dietaryEnergyConsumedQuantityType) { (value) in
            dietaryEnergyConsumed = value
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            let model = CaloriesModel(activeEnergyBurned: Int(activeEnergyBurned),
                          basalEnergyBurned: Int(basalEnergyBurned),
                          dietaryEnergyConsumed: Int(dietaryEnergyConsumed))
            completionModel(model)
        }
    }

    class func loadMostRecentActiveEnergy() {

        //1. Use HealthKit to create the Height Sample Type
        guard let activeEnergyBurnedSampleType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("activeEnergyBurned Sample Type is no longer available in HealthKit")
            return
        }


        CaloriesDataStore.getMostRecentSample(for: activeEnergyBurnedSampleType) { (active, error) in

            guard let active = active else {

                if let error = error {
                    print(error)
                }

                return
            }

            //2. Convert the height sample to meters, save to the profile model,
            //   and update the user interface.
            let activeCal = active.quantity.doubleValue(for: HKUnit.kilocalorie())
            print(activeCal)
        }
    }

}

