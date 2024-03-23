//
//  ViewController.swift
//  DemoHealth
//
//  Created by Vick on 2024/3/16.
//
// 使用 ⌃ + 6 來快速找到你要看的資料
// HealthKit 核心操作都在 HealthManager.swift 裡。

import UIKit
import HealthKit

class ViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - 健康資料讀取權限
    let toRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.characteristicType(forIdentifier: .bloodType)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.categoryType(forIdentifier: .menstrualFlow)!
    ]
    
    // MARK: - 健康資料寫入權限
    let toShare: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .underwaterDepth)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.workoutType()
    ]
    
    var datas = [HealthData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.title = "Demo"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(readHealthDatas))
        
        // MARK: 檢查裝置是否支援 HealthKit
        if HKHealthStore.isHealthDataAvailable() {
            // MARK: 向使用者要求`讀取`與`寫入`健康數據的權限
            HealthManager.store.requestAuthorization(toShare: toShare, read: toRead) { [weak self] success, error in
                guard success == true else {
                    DispatchQueue.main.async {
                        self?.showAlert(message: "權限請求失敗!\nError:\(error?.localizedDescription)")
                    }
                    return
                }
                
                // MARK: 寫入資料
                HealthManager.shared.writeWorkout()
                // HealthManager.shared.writeFakeStepData()
                // HealthManager.shared.writeUnderwaterDepth()
                // HealthManager.shared.writeSleepAnalysis()
                
                // MARK: 讀取資料
                self?.readHealthDatas()
            }
        } else {
            showAlert(message: "此裝置不支援 HealthKit!")
        }
    }
    
    // MARK: 讀取資料
    @objc func readHealthDatas() {
        datas.removeAll()
        
        HealthManager.shared.readBloodType { [weak self] result in
            self?.datas.append(HealthData(name: "血型", value: result))
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        } failureHandler: { [weak self] in
            self?.showAlert(message: "讀取血型失敗。")
        }

        HealthManager.shared.readStepCountWithoutUserEntered { [weak self] value in
            self?.datas.append(HealthData(name: "步數(排除手動輸入)", value: value))
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        HealthManager.shared.readStepCount { [weak self] value in
            self?.datas.append(HealthData(name: "步數", value: value))
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        HealthManager.shared.readEnergyBurned { [weak self] value in
            self?.datas.append(HealthData(name: "卡路里", value: value))
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func showAlert(message: String) {
        let alertViewController = UIAlertController(title: "提醒", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確定", style: .default)
        alertViewController.addAction(confirmAction)
        present(alertViewController, animated: true)
    }

}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        
        let data = datas[indexPath.row]
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = data.name
        contentConfiguration.secondaryText = data.value
        cell.contentConfiguration = contentConfiguration
        
        return cell
    }
}

struct HealthData {
    let name: String
    let value: String
}
