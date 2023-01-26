//
//  ViewController.swift
//  Anti-app
//
//  Created by Jiyun Bae on 2023/01/25.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    let healthStore = HKHealthStore()
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizeHealthKit()
    }
    
    func authorizeHealthKit(){
        let read = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
        let share = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
        let sleepread = Set([HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
        let sleepshare = Set([HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
        healthStore.requestAuthorization(toShare: share, read: read) {(chk,error) in
            if (chk){
                print("permission granted")
                self.latesHeartRate()
            }
        }
        healthStore.requestAuthorization(toShare: sleepshare, read: sleepread) {(chk,error) in
            if (chk){
                print("permission granted for sleep analysis")
            }
        }
    }
    
    //latest heart rate 알아내기
    func latesHeartRate(){
        
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else{
            return
        }
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) {(sample, result,error) in
            guard error == nil else{
                return
            }
            let data = result![0] as! HKQuantitySample
            let unit = HKUnit(from: "count/min")
            let latesHr = data.quantity.doubleValue(for: unit)
            print("Latest Hr\(latestHr) BPM")
            
            let dateFormator = DateFormatter()
            dateFormator.dateFormat = "dd/MM/yyyy hh:mm s"
            let StartDate = dateFormator.string(from: data.startDate)
            let EndDate = dateFormator.string(from: data.endDate)
            print("StarDate \(StartDate) : EndDate \(EndDate)")
        }
        
        healthStore.execute(query)
    }
}
    
