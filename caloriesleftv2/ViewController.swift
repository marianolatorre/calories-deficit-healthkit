//
//  ViewController.swift
//  caloriesleftv2
//
//  Created by mariano latorre on 10/05/2020.
//  Copyright © 2020 mariano latorre. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var calories: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(authorizeHealthKit), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func authorizeHealthKit() {
        self.calories.text = "Refreshing..."
        
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in

            guard authorized else {
                let baseMessage = "HealthKit Authorization Failed"

                if let error = error {
                    self.calories.text = "\(baseMessage). Reason: \(error.localizedDescription)"
                } else {
                    self.calories.text = baseMessage
                }

                return
            }

            print("HealthKit Successfully Authorized.")

            CaloriesManager.loadCumulativeCaloryValues { (model) in
                let left = model.activeEnergyBurned  + model.basalEnergyBurned - model.dietaryEnergyConsumed
                self.calories.text = "Active=\(model.activeEnergyBurned) Basal= \(model.basalEnergyBurned) Dietary=\(model.dietaryEnergyConsumed) \n\nCalories in deficit=\(left)"
            }
        }
    }
}

