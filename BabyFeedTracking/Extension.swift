//
//  Extension.swift
//  BabyFeedTracking
//
//  Created by Bhumika Patel on 29/11/24.
//

import Foundation

extension DateFormatter {
    static var shortTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}
