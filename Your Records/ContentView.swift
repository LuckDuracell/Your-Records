//
//  ContentView.swift
//  Your Records
//
//  Created by Luke Drushell on 8/23/21.
//

import SwiftUI
import HealthKit
import HealthKitUI

func authorize() {
    let healthStore = HKHealthStore()
    let allTypes = Set([HKObjectType.workoutType(),
                        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                        HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                        HKObjectType.quantityType(forIdentifier: .heartRate)!])
    healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
        if !success {
            // Handle the error here.
            print("authorizationError")
        }
    }
}


func loadDistanceWorkouts(completion:  @escaping ([HKWorkout]?, Error?) -> Void) {
    guard let distanceType =
        HKObjectType.quantityType(forIdentifier:
                                    HKQuantityTypeIdentifier.heartRate) else {
                fatalError("*** Unable to create a Heart rate type ***")
    }
        // Get all workouts that only came from this app.
    let workoutPredicate = HKQuery.predicateForObjects(from: .default())

    let startDateSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

    let query = HKSampleQuery(sampleType: distanceType,
                              predicate: workoutPredicate,
                              limit: 0,
                              sortDescriptors: [startDateSort]) { (sampleQuery, results, error) -> Void in
                                guard let distanceSamples = results as? [HKQuantitySample] else {
                                    // Perform proper error handling here.
                                    return
                                }
                                // Use the workout's distance samples here.
                                print("\(distanceSamples)")
    }

    HKHealthStore().execute(query)
    
    }

struct ContentView: View {
    
    @State var distanceOutput = ""
    
    
    var body: some View {
        if distanceOutput != "" {
            Text(distanceOutput)
        }
        Button {
            authorize()
            let healthStore = HKHealthStore()
            if healthStore.authorizationStatus(for: HKObjectType.workoutType()) == HKAuthorizationStatus.sharingAuthorized {
                print("success BABY")
                loadDistanceWorkouts(completion: { (success, error) in
                    if (success == nil) {
                        print("completionError")
                    }
                })
            }
        } label: {
            Text("Fetch Data")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
