//
//  CaloriesDataStore.swift
//  caloriesleft
//
//  Created by mariano latorre on 10/05/2020.
//  Copyright © 2020 mariano latorre. All rights reserved.
//

import HealthKit

class CaloriesDataStore {
    class func getCumulativeCalories(for quantityType: HKQuantityType,
                                     completion: @escaping (Double?, Error?) -> Swift.Void) {

        let myDate = Date()
//        print(myDate.startOfDay)
//        print(myDate.endOfDay)


        let todayPredicate = HKQuery.predicateForSamples(withStart: myDate.startOfDay,
                                                         end: myDate.endOfDay,
                                                         options: .strictEndDate)


        let query = HKStatisticsQuery.init(quantityType: quantityType,
                                           quantitySamplePredicate: todayPredicate,
                                           options: [HKStatisticsOptions.cumulativeSum, HKStatisticsOptions.separateBySource]) { (query, results, error) in

                                            let total = results?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie())

                                            DispatchQueue.main.async {
                                                guard let totalDayCal = total else {
                                                    completion(nil, error)
                                                    return
                                                }
                                                completion(totalDayCal, nil)
                                            }
        }
        HKHealthStore().execute(query)
    }

    class func getMostRecentSample(for sampleType: HKSampleType,
                                   completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {

        let myDate = Date()
        print(myDate.startOfDay)
        print(myDate.endOfDay)


        //1. Use HKQuery to load the most recent samples.
        let todayPredicate = HKQuery.predicateForSamples(withStart: myDate.startOfDay,
                                                         end: myDate.endOfDay,
                                                         options: .strictEndDate)

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        let limit = 10000
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: todayPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                                            //2. Always dispatch to the main thread when complete.
                                            DispatchQueue.main.async {
                                                guard let samples = samples,
                                                    let mostRecentSample = samples.first as? HKQuantitySample else {
                                                        completion(nil, error)
                                                        return
                                                }
                                                completion(mostRecentSample, nil)
                                            }
        }
        HKHealthStore().execute(sampleQuery)
    }
}


extension Date {

    var startOfDay : Date {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let components = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: components)!
    }

    var endOfDay : Date {
        var components = DateComponents()
        components.day = 1
        let date = Calendar.current.date(byAdding: components, to: self.startOfDay)
        return (date?.addingTimeInterval(-1))!
    }
}
