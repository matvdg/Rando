//
//  WorkoutManager.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import HealthKit
import SwiftUI

enum WorkoutActivity: String, CaseIterable, Equatable {
    case all, hiking, walking, running, cycling
    var localized: String { self.rawValue.localized }
    var icon: Image {
        switch self {
        case .all: return Image(systemName: "infinity")
        case .hiking: return Image(systemName: "figure.hiking")
        case .walking: return Image(systemName: "figure.walk")
        case .running: return Image(systemName: "figure.run")
        case .cycling: return Image(systemName: "figure.outdoor.cycle")
        }
    }
    
    var activity: HKWorkoutActivityType? {
        switch self {
        case .all: return nil
        case .hiking: return .hiking
        case .walking: return .walking
        case .running: return .running
        case .cycling: return .cycling
        }
    }
    
    static func activity(from: HKWorkoutActivityType) -> WorkoutActivity {
        switch from {
        case .hiking: return .hiking
        case .walking: return .walking
        case .running: return .running
        case .cycling: return .cycling
        default: return .all
        }
    }
}

class WorkoutManager {
    
    static let shared = WorkoutManager()
    
    private let store = HKHealthStore()
    private let workoutType = HKObjectType.workoutType()
    private let workoutRouteType = HKSeriesType.workoutRoute()
    private var typesToRead: Set<HKObjectType> { [workoutType, workoutRouteType] }
    
    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable()}
    
    func getWorkouts() async throws -> [HKWorkout] {
        
        // Check if workout type is supported
        guard isAvailable else {
            // Handle HealthKit not available on the device
            print("HealthKit not available on the device")
            return []
        }
        
        // Request permissions
        try await store.requestAuthorization(toShare: [], read: typesToRead)
        
        return try await executeWorkoutsSampleQuery()
    }
    
    func getLocations(for workout: HKWorkout) async throws -> [Location] {
        if let route = try await executeWorkoutQuery(workout: workout) {
            return try await executeWorkoutRouteQuery(route: route)
        } else {
            return []
        }
    }
    
    private func executeWorkoutsSampleQuery() async throws -> [HKWorkout] {
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [HKQuery.predicateForWorkouts(with: .hiking), HKQuery.predicateForWorkouts(with: .walking), HKQuery.predicateForWorkouts(with: .running), HKQuery.predicateForWorkouts(with: .cycling)])
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

            let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, results, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let workouts = results as? [HKWorkout] {
                    continuation.resume(returning: workouts)
                } else {
                    continuation.resume(returning: [])
                }
            }
            store.execute(query)
        }
    }
    
    private func executeWorkoutQuery(workout: HKWorkout) async throws -> HKWorkoutRoute? {
        return try await withCheckedThrowingContinuation { continuation in
            
            let predicate = HKQuery.predicateForObjects(from: workout)
            
            let query = HKSampleQuery(sampleType: workoutRouteType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let route = results?.first as? HKWorkoutRoute {
                    continuation.resume(returning: route)
                } else {
                    continuation.resume(returning: nil)
                }
            }
            store.execute(query)
        }
    }
    
    private func executeWorkoutRouteQuery(route: HKWorkoutRoute) async throws -> [Location] {
        return try await withCheckedThrowingContinuation { continuation in
            var collectedLocations = [Location]()
            let query = HKWorkoutRouteQuery(route: route) { (query, locations, done, error) in
                
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let locs = locations {
                    collectedLocations.append(contentsOf: locs.map { Location(location: $0)})
                } else {
                    continuation.resume(returning: []) // Don't use continuation, it's an async batch process, and continuation must be called just once
                }
                if done { // This is the true end
                    continuation.resume(returning: collectedLocations)
                }
            }
            store.execute(query)
            
        }
    }
}
