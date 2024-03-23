//
//  HealthManager.swift
//  DemoHealth
//
//  Created by Vick on 2024/3/17.
//
// 使用 ⌃ + 6 來快速找到你要看的資料

import Foundation
import HealthKit

class HealthManager {
    static let shared = HealthManager()
    static let store = HKHealthStore()
    
//    func writeFakeStepData() {
//        let fakeDataKey = "FakeDataForDemo"
//        
//        var datas: [HKQuantitySample] = []
//        for i in 1...10 {
//            let type = HKObjectType.quantityType(forIdentifier: .stepCount)!
//            let quantity = HKQuantity(unit: .count(), doubleValue: Double(i))
//            let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
//            let endDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 1, of: Date())!
//            let metadatas: [String: Any] = [
//                HKMetadataKeyWasUserEntered: true,
//                fakeDataKey: true
//            ]
//            
//            let object = HKQuantitySample(type: type, quantity: quantity, start: startDate, end: endDate, metadata: metadatas)
//            datas.append(object)
//        }
//        
//        for i in 11...15 {
//            let type = HKObjectType.quantityType(forIdentifier: .stepCount)!
//            let quantity = HKQuantity(unit: .count(), doubleValue: Double(i))
//            let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
//            let endDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 1, of: Date())!
//            let metadatas: [String: Any] = [
//                fakeDataKey: true
//            ]
//            
//            let object = HKQuantitySample(type: type, quantity: quantity, start: startDate, end: endDate, metadata: metadatas)
//            datas.append(object)
//        }
//        
//        HealthManager.store.save(datas) { success, error in
//            print("儲存資料成功狀態：\(success)")
//            print(error?.localizedDescription ?? "")
//        }
//    }
}

// MARK: - 寫入資料
extension HealthManager {
    
    // MARK: 寫入資料「水下深度(underwaterDepth)」，屬於 QuantityType 的資料
    func writeUnderwaterDepth() {
        // Type
        let type = HKObjectType.quantityType(forIdentifier: .underwaterDepth)!
        
        // Value
        let quantity = HKQuantity(unit: .meter(), doubleValue: 9999.9)
        
        // Time
        let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let endDate = Calendar.current.date(bySettingHour: 1, minute: 1, second: 1, of: Date())!
        
        // Metadata
        let metadatas: [String: Any] = [
            HKMetadataKeyWasUserEntered: true,
            "測試的自訂Metadata Key": "測試的自訂Metadata Value"
        ]
        
        // Object
        let object = HKQuantitySample(type: type, quantity: quantity, start: startDate, end: endDate, metadata: metadatas)
        
        HealthManager.store.save(object) { success, error in
            print("儲存資料成功狀態：\(success)")
            print(error?.localizedDescription ?? "")
        }
    }
    
    // MARK: 寫入資料「睡眠分析(sleepAnalysis)」，屬於 CategoryType 的資料
    func writeSleepAnalysis() {
        // Type
        let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        
        // Value
        let value = HKCategoryValueSleepAnalysis.asleepDeep.rawValue
        
        // Time
        let startDate = Calendar.current.date(bySettingHour: 2, minute: 10, second: 10, of: Date())!
        let endDate = Calendar.current.date(bySettingHour: 2, minute: 20, second: 20, of: Date())!
        
        // Metadata
        let metadatas = [
            HKMetadataKeyWasUserEntered: true
        ]
        
        // Sample
        let object = HKCategorySample(type: type, value: value, start: startDate, end: endDate, metadata: metadatas)
        
        HealthManager.store.save(object) { success, error in
            
        }
    }
    
    func writeWorkout() {
        let energyBurned = HKQuantity(unit: .largeCalorie(), doubleValue: 213)
        let distanceRunning = HKQuantity(unit: .meter(), doubleValue: 3120)
        
        let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let endDate = Calendar.current.date(bySettingHour: 1, minute: 0, second: 0, of: Date())!

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.lapLength = HKQuantity(unit: .meterUnit(with: .kilo), doubleValue: 3.1)
        let workoutBuilder = HKWorkoutBuilder(healthStore: HealthManager.store, configuration: configuration, device: nil)
        
        var samples: [HKSample] = []
        
        let distanceType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        let distancePerInterval = HKQuantity(unit: HKUnit.meter(), doubleValue: 1300)
        let distanceSample = HKQuantitySample(type: distanceType, quantity: distancePerInterval, start: startDate, end: endDate)
        samples.append(distanceSample)
        
        workoutBuilder.add(samples) { success, error in
        }
        
        let energyBurnedType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
        let energyBurnedPerInterval = HKQuantity(unit: HKUnit.largeCalorie(), doubleValue: 233)
        let energyBurnedSample = HKQuantitySample(type: energyBurnedType, quantity: energyBurnedPerInterval, start: startDate, end: endDate)
        samples.append(energyBurnedSample)
        
        workoutBuilder.add(samples) { success, error in
        }
        
        workoutBuilder.beginCollection(withStart: startDate) { success, error in
            
        }
        
        workoutBuilder.endCollection(withEnd: endDate) { success, error in
            
        }
        
        workoutBuilder.finishWorkout { workout, error in
            HealthManager.store.save(workout!) { success, err in
                print("Success")
            }
        }
    }
    
}

// MARK: - 讀取資料
extension HealthManager {
    
    // MARK: 讀取血型
    func readBloodType(successHandler: (String) -> Void, failureHandler: () -> Void) {
        do {
            let bloodType = try HealthManager.store.bloodType().bloodType.rawValue
            successHandler("\(bloodType)")
        } catch {
            failureHandler()
        }
    }
    
    // MARK: 讀取步數（排除手動輸入）
    func readStepCountWithoutUserEntered(completion: @escaping (String) -> Void) {
        let type = HKObjectType.quantityType(forIdentifier: .stepCount)!
        
        let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        // let predicateWasUserEntered = NSPredicate(format: "metadata.%K != YES", HKMetadataKeyWasUserEntered)
        let predicateWasUserEntered = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyWasUserEntered, operatorType: .notEqualTo, value: true)
        
        var predicates = [NSPredicate]()
        predicates.append(predicate)
        predicates.append(predicateWasUserEntered)
        let compoundsPredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: compoundsPredicate) { query, statistics, error in
            if let value = statistics?.sumQuantity()?.doubleValue(for: .count()) {
                completion("\(value)")
            }
        }
        
        HealthManager.store.execute(query)
    }
    
    // MARK: 讀取步數
    func readStepCount(completion: @escaping (String) -> Void) {
        let type = HKObjectType.quantityType(forIdentifier: .stepCount)!
        
        let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate) { query, statistics, error in
            if let value = statistics?.sumQuantity()?.doubleValue(for: .count()) {
                completion("\(value)")
            }
        }
        
        HealthManager.store.execute(query)
    }
    
    // MARK: 讀取動態能量（卡路里）
    func readEnergyBurned(completion: @escaping (String) -> Void) {
        let type = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate) { query, statistics, error in
            if let value = statistics?.sumQuantity()?.doubleValue(for: .largeCalorie()) {
                completion("\(value)")
            }
        }
        
        HealthManager.store.execute(query)
    }
    
    // MARK: 讀取睡眠
    func readSleepAnalysis() {
        let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 0, sortDescriptors: nil) { query, samples, error in
        }
        
        HealthManager.store.execute(query)
    }

}
