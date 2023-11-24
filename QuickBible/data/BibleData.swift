//
//  BibleData.swift
//  QuickBible
//
//  Created by Joshua Jiang on 8/10/22.
//

import Foundation
import UIKit

struct Book {
    var Name: String
    var BookId: Int
    var color: UIColor {
        DataManager.shareInstance.colors[BookId]
    }
    
    var FirstChapter: [Verse] {
        get {
            let sql = "select * from t_chn where b=\(BookId) and c=1 order by id"
            return db.query(sql: sql).map { oneverse in
                Verse(r: oneverse)
            }
        }
    }
    
    var allChapter: Int {
        get {
            let sql = "select count(distinct(c)) from t_chn where b=\(BookId)"
            let c = db.query(sql: sql)[0]["count(distinct(c))"] as! Int
            return c
        }
    }
    
    var HistoryChapter: [Verse] {
        get {
            let chapter = HistoryVerse.shareInstance.historyVerse[BookId - 1]
            let sql = "select * from t_chn where b=\(BookId) and c=\(chapter) order by id"
            return db.query(sql: sql).map { oneverse in
                Verse(r: oneverse)
            }
        }
    }
    
    var chapterNumber: Int {
        get {
            let sql = "select count(distinct(c)) from t_chn where b=\(BookId)"
            let d = db.query(sql: sql).first!
            return db.query(sql: sql).first!["count(distinct(c))"] as! Int
        }
    }
    
    var favoriteCount: Int {
        get {
            FavoriteVerse.shareInstance.myVerses.map { b in
                Int(b / 1000000)
            }.filter { $0 == BookId}.count
        }
    }
    
    init(oneVerse: Verse) {
        var sql = "select b from t_chn where id=\(oneVerse.id)"
        BookId = db.query(sql: sql).first!["b"] as! Int
        sql = "select FullName from BibleID where SN=\(BookId)"
        Name = db.query(sql: sql).first!["FullName"] as! String
    }
    
    init(name: String, bookid: Int) {
        Name = name
        BookId = bookid
    }
    
    func oneChapter(chapterNumber: Int) -> [Verse] {
        let sql = "select * from t_chn where b=\(BookId) and c=\(chapterNumber) order by id"
        return db.query(sql: sql).map { oneverse in
            Verse(r: oneverse)
        }
    }
}

struct Bible {
    var books:[Book]
    var ot:[Book] {
        get {
            Array(books[0..<39])
        }
    }
    var nt:[Book] {
        get {
            Array(books[39..<66])
        }
    }
    
    var sections:[[Book]]
    
    init() {
        let sql = "select SN, FullName from BibleID"
        let r = db.query(sql: sql)
        books = r.map({ oneB in
            Book(name: oneB["FullName"] as! String,
                 bookid: oneB["SN"] as! Int)
        })
        sections = [Array(books[0..<5]),  // 摩西五经
                    Array(books[5..<17]), // 历史书
                    Array(books[17..<22]), // 诗歌、智慧书
                    Array(books[22..<27]), // 大先知书
                    Array(books[27..<39]), // 小先知书
                    Array(books[39..<43]), // 福音书
                    Array(books[43..<44]), // 教会历史
                    Array(books[44..<57]), // 保罗书信
                    Array(books[57..<65]), // 其它书信
                    Array(books[65..<66])  // 启示录
        ]
    }
}

struct Verse: Equatable {
    var id: Int
    var Book: Int
    var Chapter: Int
    var Verse: Int
    var Text: String
    var color: UIColor {
        let d = DataManager.shareInstance
        return d.colors[Book]
    }
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
    
    var referenceNo: Int {
        let sql = "select count(*) from cross_reference where vid=\(id)"
        return db.query(sql: sql).first!["count(*)"] as! Int
    }
    
    var Text_eng: String {
        let sql = "select t from t_asv where b=\(Book) and c=\(Chapter) and v=\(Verse) limit 1"
        if let t = db.query(sql: sql).first {
            return t["t"] as! String
        }
        return ""
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
    
    func getChapter() -> [Verse] {
        let onebook = QuickBible.Book(oneVerse: self)
        return onebook.oneChapter(chapterNumber: self.Chapter)
    }
    
    
    func isFavorite() -> Bool {
        let f = FavoriteVerse.shareInstance
        return f.myVerses.contains(id)
    }
    
    static func == (lhs: Verse, rhs: Verse) -> Bool {
        lhs.id  == rhs.id
    }
}

class VerseRange {
    var verses:[Verse] = []
    var color: UIColor {
        verses.first!.color
    }
    var titleAndtext: String {
        get {
           title() + ": " + fullText()
        }
    }
    init(startid: Int, endid: Int) {
        let sql = "select * from t_chn where id>=\(startid) and id<=\(endid)"
        verses = db.query(sql: sql).map({ oneverse in
            Verse(r: oneverse)
        })
    }
    
    init(oneverse: Verse) {
        verses = [oneverse]
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
