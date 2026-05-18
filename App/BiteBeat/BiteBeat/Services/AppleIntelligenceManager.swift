//
//  AppleIntelligenceManager.swift
//  BiteBeat
//

import Foundation
import UIKit
import Observation

@Observable
public final class AppleIntelligenceManager: @unchecked Sendable {
    public static let shared = AppleIntelligenceManager()
    
    private init() {}
    
    // Mengidentifikasi kode model perangkat fisik (misal: iPhone18,1)
    public var deviceModelCode: String {
        #if targetEnvironment(simulator)
        if let simulatorDevice = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatorDevice
        }
        return "iPhone18,1" // Default ke iPhone 17 Pro di simulator agar mudah ditest
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
        #endif
    }
    
    // Apple Intelligence secara penuh membutuhkan iPhone 17 keatas (iPhone18,1+)
    public var isHardwareSupported: Bool {
        let code = deviceModelCode
        if code.hasPrefix("iPhone") {
            let modelParts = code.dropFirst(6).split(separator: ",")
            if let numberString = modelParts.first,
               let modelNumber = Int(numberString) {
                // iPhone15 Pro: 16
                // iPhone16 series: 17
                // iPhone17 series: 18+
                return modelNumber >= 18
            }
        }
        return false
    }
    
    // Aktif jika perangkat mendukung secara hardware
    public var isAppleIntelligenceActive: Bool {
        return isHardwareSupported
    }
    
    public var activeModeName: String {
        if isHardwareSupported {
            return "Apple Intelligence (Local ANE Model)"
        } else {
            return "Heuristic Standard Mode"
        }
    }
}
