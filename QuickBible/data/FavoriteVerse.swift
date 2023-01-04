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
    
    func toggleFavorite(oneverse: Verse) {
        if !myVerses.contains(oneverse.id) {
            var m = myVerses
            m.append(oneverse.id)
            myVerses = m.sorted(by: <)
        } else {
            var m = myVerses
            m.remove(at: m.firstIndex(of: oneverse.id)!)
            myVerses = m.sorted(by: <)
        }
        let userinfo = ["verse": oneverse]
        NotificationCenter.default.post(name: updateVerseView, object: nil, userInfo: userinfo)
        NotificationCenter.default.post(name: updateFavoriteView, object: nil)
    }
    
    func deleteVerse(oneverse: Verse) {
        if myVerses.contains(oneverse.id) {
            myVerses.remove(at: myVerses.firstIndex(of: oneverse.id)!)
        }
    }
    
    func verseInRange() -> [VerseRange]{
        func isSameRange(v1id: Int, v2id: Int) -> Bool{
           if v1id == 66022021 { return false}
           let sql = "select id from t_chn where id>\(v1id) limit 1"
           let r = db.query(sql: sql).first!
           if r["id"] as! Int == v2id { return true}
           return false
        }
        
        var myVerseInRange: [VerseRange] = []
        var ids: [Int] = []
        for (id, oneverse) in myVerses.enumerated() {
            if id == myVerses.endIndex - 1 && !ids.contains(id){
                myVerseInRange.append(VerseRange(startid: oneverse, endid: oneverse))
                break
            }
            if ids.contains(id) {
                continue
            } else {
                var currentidx = id
                for _ in id...myVerses.endIndex - 2 {
                    if isSameRange(v1id: myVerses[currentidx], v2id: myVerses[currentidx + 1]) {
                        currentidx += 1
                        ids.append(currentidx)
                    } else {
                        break
                    }
                }
                myVerseInRange.append(VerseRange(startid: myVerses[id], endid: myVerses[currentidx]))
            }
        }
        return myVerseInRange
    }
}
