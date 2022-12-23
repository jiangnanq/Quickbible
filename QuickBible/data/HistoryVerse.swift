//
//  HistoryVerse.swift
//  QuickBible
//
//  Created by Joshua Jiang on 22/12/22.
//

import Foundation

class HistoryVerse {
    static let shareInstance = HistoryVerse()
    var historyVerse:[Int] = [] {
        didSet {
            let ud = UserDefaults.standard
            if let o = ud.array(forKey: "history") {
               if historyVerse != o as! [Int]{
                    ud.setValue(historyVerse, forKey: "history")
                }
            } else {
                ud.setValue(historyVerse, forKey: "history")
            }
        }
    }
    
    init() {
        let ud = UserDefaults.standard
        if let o = ud.array(forKey: "history") {
            historyVerse = o as! [Int]
        } else {
            historyVerse = Array(repeating: 1, count: 66)
        }
    }
    
    func saveVerse(v: Verse) {
        historyVerse[v.Book - 1] = v.Chapter
    }
}
