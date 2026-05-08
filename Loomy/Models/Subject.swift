//
//  Subject.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import Foundation
import SwiftData

@Model
class Subject {
    // MARK: - Stored Properties
    var name: String
    var isUniversity: Bool
    
    // MARK: - Rates (Pricing Logic)
    var offlineSoloRate: Double
    var onlineSoloRate: Double
    var offlineGroupRate: Double
    var onlineGroupRate: Double
    
    // MARK: - Initializer
    init(
        name: String,
        offlineSolo: Double = 0,
        onlineSolo: Double = 0,
        offlineGroup: Double = 0,
        onlineGroup: Double = 0,
        isUniversity: Bool = true
    ) {
        self.name = name
        self.isUniversity = isUniversity
        self.offlineSoloRate = offlineSolo
        self.onlineSoloRate = onlineSolo
        self.offlineGroupRate = offlineGroup
        self.onlineGroupRate = onlineGroup
    }
}
