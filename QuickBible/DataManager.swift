//
//  DataManager.swift
//  QuickBible
//
//  Created by Joshua Jiang on 2/9/22.
//

import Foundation

let db = SQLiteDB.shared

struct Verse {
    var id: Int
    var Book: Int
    var Chapter: Int
    var Verse: Int
    var Text: String
    var bookNameChn: String {
        let sql = "select FullName from BibleID where SN=\(Book)"
        let r = db.query(sql: sql).first!
        return r["FullName"] as! String
    }
    var textWithNumber: String {
        "\(Verse) \(Text)"
    }
    var fullText: String {
        "\(bookNameChn) \(Chapter):\(Verse) \(Text)"
    }
    
    func cross_ref() -> [VerseRange] {
        let sql = "select sv,ev from cross_reference where vid=\(self.id) order by r desc"
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
    
    init(r: [String: Any]) {
        self.id = r["id"] as! Int
        self.Book = r["b"] as! Int
        self.Chapter = r["c"] as! Int
        self.Verse = r["v"] as! Int
        self.Text = r["t"] as! String
    }
    
    init(rid: Int) {
        let sql = "select * from t_chn where id=\(rid) limit 1"
        let r = db.query(sql: sql).first!
        self.id = rid
        self.Book = r["b"] as! Int
        self.Chapter = r["c"] as! Int
        self.Verse = r["v"] as! Int
        self.Text = r["t"] as! String
    }
}

class VerseRange {
    var verses:[Verse] = []
    init(startid: Int, endid: Int) {
        let sql = "select * from t_chn where id>=\(startid) and id<=\(endid)"
        verses = db.query(sql: sql).map({ oneverse in
            Verse(r: oneverse)
        })
    }
    
    func title() -> String {
        guard !verses.isEmpty else {return ""}
        let v1 = verses.first!
        let v2 = verses.last!
        if v1.Book == v2.Book && v1.Chapter == v2.Chapter {
            if verses.count == 1 {
                return "\(v1.bookNameChn)\(v1.Chapter):\(v1.Verse)"
            }
            return "\(v1.bookNameChn)\(v1.Chapter):\(v1.Verse) - \(v2.Verse)"
        } else if v1.Book == v2.Book {
            return "\(v1.bookNameChn)\(v1.Chapter):\(v1.Verse) - \(v2.Chapter):\(v2.Verse)"
        }
        return "\(v1.bookNameChn)\(v1.Chapter):\(v1.Verse) - \(v2.bookNameChn)\(v2.Chapter):\(v2.Verse)"
    }
    
    func fullText() -> String {
        guard !verses.isEmpty else { return ""}
        return verses.reduce("") { partialResult, v in
            "\(partialResult) \(v.Text)"
        }
    }
}

class DataManager {
    static let shareInstance = DataManager()
    
    init() {
        let path = Bundle.main.path(forResource: "bible_chn", ofType: "db")
        db.open(dbPath: path!, copyFile: true)
    }
    
    func randomVerse() -> Verse {
        let sql = "select * from t_chn order by random() limit 1"
        let r = db.query(sql: sql).first!
        return Verse(r: r)
    }
    
    func currentChapter(oneverse: Verse) -> [Verse] {
        var chapter:[Verse] = []
        var sql = "select * from t_chn order by random() limit 1"
        let r = db.query(sql: sql).first!
        let b = r["b"] as! Int
        let c = r["c"] as! Int
        sql = "select * from t_chn where b=\(b) and c=\(c) order by id"
        let r1 = db.query(sql: sql)
        chapter = r1.map({ oner in
            Verse(r: oner)
        })
        return chapter
    }
    
    func nextChapter(oneverse: Verse) -> [Verse] {
        let sql = "select * from t_chn where id>\(oneverse.id) limit 1"
        return currentChapter(oneverse: Verse(r: db.query(sql: sql).first!))
    }
    
    func previousChapter(oneverse: Verse) -> [Verse] {
        let sql = "select * from t_chn where id<\(oneverse.id) limit 1"
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
