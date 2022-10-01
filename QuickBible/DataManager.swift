//
//  DataManager.swift
//  QuickBible
//
//  Created by Joshua Jiang on 2/9/22.
//

import Foundation

let db = SQLiteDB.shared

struct Book {
    var Name: String
    var BookId: Int
    
    var FirstChapter: [Verse] {
        get {
            let sql = "select * from t_chn where b=\(BookId) and c=1 order by id"
            return db.query(sql: sql).map { oneverse in
                Verse(r: oneverse)
            }
        }
    }
    
    var chapter: Int {
        get {
            let sql = "select count(distinct(c)) from t_chn where b=\(BookId)"
            let d = db.query(sql: sql).first!
            return db.query(sql: sql).first!["count(distinct(c))"] as! Int
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
    
    var referenceNo: Int {
        let sql = "select count(*) from cross_reference where vid=\(id)"
        return db.query(sql: sql).first!["count(*)"] as! Int
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
