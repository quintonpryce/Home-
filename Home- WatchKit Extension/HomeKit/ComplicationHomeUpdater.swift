//
// ComplicationHomeUpdater.swift
// Home- WatchKit Extension
//
// 🖌 by Q on 2020-10-23.
//

import HomeKit
import ClockKit

protocol ComplicationHomeProviderDelegate: AnyObject {
    func didUpdateNumberOfAccessoriesOn(_ numberOfAccessoriesOn: Int)
}

class ComplicationHomeProvider: NSObject, HMHomeManagerDelegate {
    static let shared = ComplicationHomeProvider()
    
    private let homeManager = HMHomeManager()
    
    private var numberOfKickedRequests = 0
    
    var numberOfAccessoriesOn = 0
    
    override init() {
        super.init()
        homeManager.delegate = self
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
//        updateNumberOfAccessoriesOn()
    }
    
    func updateNumberOfAccessoriesOn(with value: Int) {
        numberOfAccessoriesOn = value
    }
    
    func forcefullyUpdateNumberOfAccessoriesOn() {
        Log.i("[\(Date())] Started updating accessories for complications.")
        guard numberOfKickedRequests == 0 else { return }
        
        numberOfAccessoriesOn = 0
        
        guard let primaryServices = homeManager.primaryHome?.primaryServices else { return }
        
        let toggleableCharacterstics = primaryServices.flatMap { service -> [HMCharacteristic] in
            service.characteristics.filter { $0.isBool && $0.isWriteable && $0.isReachable }
        }
        
        numberOfKickedRequests = toggleableCharacterstics.count
        
        Log.i("[\(Date())] Started requesting characterstics update their values for complications.")
        toggleableCharacterstics.forEach { characteristic in
            characteristic.readValue { [weak self] error in
                guard error == nil else { return }
                self?.didReadCharactisticValue(characteristic)
            }
        }
    }
    
    private func didReadCharactisticValue(_ characteristic: HMCharacteristic) {
        numberOfKickedRequests -= 1
        
        if let isOn = characteristic.value as? Bool, isOn {
            numberOfAccessoriesOn += 1
        }
        
        if numberOfKickedRequests <= 0 {
            forceReloadComplications()
        }
    }
    
    func forceReloadComplications() {
        let server = CLKComplicationServer.sharedInstance()
        Log.i("[\(Date())] Started reloading \(server.activeComplications?.count ?? 0) complications.")
        for complication in server.activeComplications ?? [] {
            server.reloadTimeline(for: complication)
            Log.i("[\(Date())] Reloading complication: \(complication.identifier)")
        }
    }
}
