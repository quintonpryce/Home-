//
// ComplicationHomeUpdater.swift
// Home- WatchKit Extension
//
// 🖌 by Q on 2020-10-23.
//

import HomeKit
import ClockKit

class ComplicationHomeProvider: NSObject, HMHomeManagerDelegate {
    static var shared = ComplicationHomeProvider()
    
    private let homeManager = HMHomeManager()
    
    private var numberOfKickedRequests = 0
    
    var numberOfAccessoriesOn = 0
    
    var completion: (() -> Void)?
    
    override init() {
        super.init()
        homeManager.delegate = self
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        forceUpdateNumberOfAccessoriesOn()
        Log.i("Complication Home Updater did update homes.")
    }
    
    func forceUpdateNumberOfAccessoriesOn() {
        Log.i("Started updating accessories for complications.")
        guard numberOfKickedRequests == 0 else { return }
        
        numberOfAccessoriesOn = 0
        
        guard let primaryServices = homeManager.primaryHome?.primaryServices else { return }
        
        let toggleableCharacterstics = primaryServices.flatMap { service -> [HMCharacteristic] in
            service.characteristics.filter { $0.isBool && $0.isWriteable && $0.isReachable }
        }
        
        numberOfKickedRequests = toggleableCharacterstics.count
        
        Log.i("Started requesting \(toggleableCharacterstics.count) characterstic(s) to update their values for complications.")
        toggleableCharacterstics.forEach { characteristic in
            if let value = characteristic.value as? Bool, value {
                numberOfAccessoriesOn += 1
            }
            characteristic.readValue { error in
                Log.e(error?.localizedDescription ?? "No error")
                
            }
        }
        Log.i("Number of accessories on: \(numberOfAccessoriesOn).")
        
        completion?()
    }
    
    private func didReadCharactisticValue(_ characteristic: HMCharacteristic) {
        numberOfKickedRequests -= 1
        Log.i("Did read value from characteristic for complication. Waiting for \(numberOfKickedRequests) additional requests.")
        
        if let isOn = characteristic.value as? Bool, isOn {
            numberOfAccessoriesOn += 1
        }
        
        if numberOfKickedRequests <= 0 {
            completion?()
        }
    }
    
    func forceReloadComplications() {
        let server = CLKComplicationServer.sharedInstance()
        Log.i("Started reloading \(server.activeComplications?.count ?? 0) complication(s).")
        for complication in server.activeComplications ?? [] {
            server.reloadTimeline(for: complication)
            Log.i("Reloading complication: \(complication.debugDescription)")
        }
    }
}
