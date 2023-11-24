//
//  DataManager.swift
//  QuickBible
//
//  Created by Joshua Jiang on 2/9/22.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

let updateBibleView = Notification.Name("updateBibleview")
let updateVerseView = Notification.Name("updateVerse")
let updateFavoriteView = Notification.Name("updateFavorite")

let db = SQLiteDB.shared

class DataManager {
    static let shareInstance = DataManager()
    var bible: Bible
    var colors: [UIColor] = []
    var english: Bool = false
    var player: AVQueuePlayer?
    var playerItemsTitle: [String] = []
    var currentPlayerItem: Int = 0
    
    init() {
        let path = Bundle.main.path(forResource: "bible_chn", ofType: "db")
        db.open(dbPath: path!, copyFile: true)
        bible = Bible()
        for r: CGFloat in [0.2, 0.4, 0.6, 0.8, 1.0] {
            for g: CGFloat in [0.6, 0.7, 0.8, 1.0] {
                for b: CGFloat in [0.6, 0.7, 0.8, 1.0] {
                    let color = UIColor(red: r, green: g, blue: b, alpha: 1)
                    colors.append(color)
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemReachEnd( _ :)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
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
        if oneverse.Book == 66 && oneverse.Chapter == 22 {
            return currentChapter(oneverse: oneverse)
        }
        let sql = "select * from t_chn where id>\(oneverse.id) order by id asc limit 1"
        let t = Verse(r: db.query(sql: sql).first!)
        return currentChapter(oneverse: Verse(r: db.query(sql: sql).first!))
    }
    
    func previousChapter(oneverse: Verse) -> [Verse] {
        if oneverse.Book == 1 && oneverse.Chapter == 1 {
            return currentChapter(oneverse: oneverse)
        }
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
        
    func generatePlayList(oneverse: Verse) -> [URL]{
        var playlist: [String] = []
        self.playerItemsTitle = []
        for i in 1...66 {
            var sql = "select distinct(c), bi.FullName from t_chn t left join BibleID bi on t.b=bi.SN where b=\(i) order by c"
            let r = db.query(sql: sql)
            let r1 = r.map { "\(i)_\($0["c"] as! Int)"}
            playlist += r1
            let r2 = r.map {"\($0["FullName"] as! String) \($0["c"] as! Int)"}
            self.playerItemsTitle += r2
        }
        let idx = playlist.firstIndex(of: "\(oneverse.Book)_\(oneverse.Chapter)")
        var playlisturl:[URL] = Array(playlist[idx!...]).map{ URL(string:"https://carmelbible.sgp1.digitaloceanspaces.com/Bible/\($0).mp3")!}
        self.playerItemsTitle = Array(self.playerItemsTitle[idx!...])
        self.currentPlayerItem = 0
        if playlisturl.count > 10 {
            playlisturl = Array(playlisturl[0...9])
        }
        return playlisturl
    }

    func playChapter(chapter: [Verse]) {
        let playlisturls = generatePlayList(oneverse: chapter.first!)
        let playitems = playlisturls.map{AVPlayerItem(url: $0)}
        self.player = AVQueuePlayer(items: playitems)
        self.setupAudioSession()
        self.setupRemoteTransportControl()
        self.player!.play()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: "\(self.playerItemsTitle[self.currentPlayerItem])"
        ]
    }
    
    func setupAudioSession() {
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        }catch {
            print("error when set player! \(error)" )
        }
    }
    
    func setupRemoteTransportControl() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { event in
            print("receive remote event.")
            self.player!.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { event in
            print("receive pause command.")
            self.player!.pause()
            return .success
        }
    }

    @objc func playerItemReachEnd(_ notification: Notification) {
        print("update chapter title")
        self.currentPlayerItem += 1
        if self.currentPlayerItem < self.playerItemsTitle.count{
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: "\(self.playerItemsTitle[self.currentPlayerItem])"
            ]
        }
    }

}
