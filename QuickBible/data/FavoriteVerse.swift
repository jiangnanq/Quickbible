//
//  FavoriteVerse.swift
//  QuickBible
//
//  Created by Joshua Jiang on 14/10/22.
//

import Foundation

class FavoriteVerse {
    static let shareInstance = FavoriteVerse()
    var myVerses:[Int] = [] {
        didSet {
            let ud = UserDefaults.standard
            if let o = ud.array(forKey: "myVerses") {
                if myVerses != o as! [Int] {
                    ud.setValue(myVerses, forKey: "myVerses")
                }
            } else {
                ud.setValue(myVerses, forKey: "myVerses")
            }
        }
    }
    
    init() {
        let ud = UserDefaults.standard
        if let o = ud.array(forKey: "myVerses"){
            myVerses = o as! [Int]
        }
    }
    
    func addVerse(oneverse: Verse) {
        if !myVerses.contains(oneverse.id) {
            var m = myVerses
            m.append(oneverse.id)
            myVerses = m.sorted(by: <)
        }
    }
    
    func deleteVerse(oneverse: Verse) {
        if myVerses.contains(oneverse.id) {
            myVerses.remove(at: myVerses.firstIndex(of: oneverse.id)!)
        }
    }
}
