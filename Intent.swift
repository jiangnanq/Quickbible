//
//  Intent.swift
//  QuickBible
//
//  Created by Joshua Jiang on 29/12/22.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct Intent: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "IntentIntent"

    static var title: LocalizedStringResource = "圣经"
    static var description = IntentDescription("")

//    static var parameterSummary: some ParameterSummary {
//        Summary
//    }

    func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        return .result()
    }
}


