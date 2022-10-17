//
//  DataManager.swift
//  QuickBible
//
//  Created by Joshua Jiang on 2/9/22.
//

import Foundation

let db = SQLiteDB.shared

class DataManager {
    static let shareInstance = DataManager()
    var bible: Bible
    
    init() {
        let path = Bundle.main.path(forResource: "bible_chn", ofType: "db")
        db.open(dbPath: path!, copyFile: true)
        bible = Bible()
    }
    
    func randomVerse() -> Verse {
        let sql = "select * from t_chn order by random() limit 1"
        let r = db.query(sql: sql).first!
        return Verse(r: r)
    }
    
    func currentChapter(oneverse: Verse) -> [Verse] {
        var chapter:[Verse] = []
        let sql = "select * from t_chn where b=\(oneverse.Book) and c=\(oneverse.Chapter) order by id"
        let r1 = db.query(sql: sql)
        chapter = r1.map({ oner in
            Verse(r: oner)
        })
        return chapter
    }
    
    func nextChapter(oneverse: Verse) -> [Verse] {
        let sql = "select * from t_chn where id>\(oneverse.id) order by id asc limit 1"
        let t = Verse(r: db.query(sql: sql).first!)
        return currentChapter(oneverse: Verse(r: db.query(sql: sql).first!))
    }
    
    func previousChapter(oneverse: Verse) -> [Verse] {
        let sql = "select * from t_chn where id<\(oneverse.id) order by id desc limit 1"
        return currentChapter(oneverse: Verse(r: db.query(sql: sql).first!))
    }
    
    func cross_ref(oneverse: Verse) -> [VerseRange] {
        let sql = "select sv,ev from cross_reference where vid=\(oneverse.id) order by r desc"
        return db.query(sql: sql).map { oner in
            let sv = oner["sv"] as! Int
            let ev = oner["ev"] as! Int
            if ev != 0 {
                return VerseRange(startid: sv, endid: ev)
            } else {
                return VerseRange(startid: sv, endid: sv)
            }
        }
    }
}
