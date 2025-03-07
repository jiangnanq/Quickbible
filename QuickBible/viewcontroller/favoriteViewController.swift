//
//  favoriteViewController.swift
//  QuickBible
//
//  Created by Joshua Jiang on 8/10/22.
//

import UIKit

class favoriteVerseCell: UITableViewCell {
    @IBOutlet weak var verseLabel: UILabel!
}

class favoriteViewController: UIViewController {
    @IBOutlet weak var verseTableView: UITableView!
    var v = FavoriteVerse.shareInstance.verseInRange()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的收藏"
        verseTableView.delegate = self
        verseTableView.dataSource = self
        
        // Add observer for both updateFavoriteView and didSaveFavorite notifications
        NotificationCenter.default.addObserver(self, 
            selector: #selector(updateview), 
            name: updateFavoriteView, 
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(updateview),
            name: NSNotification.Name("didSaveFavorite"),
            object: nil)
    }

    deinit {
        // Remove observers when view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.verseTableView.reloadData()
    }
    
    @objc func updateview() {
        print("update favorite view")
        v = FavoriteVerse.shareInstance.verseInRange()
        DispatchQueue.main.async {
            self.verseTableView.reloadData()
        }
    }
    
    @IBAction func selectType() {
        print("Select segment")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension favoriteViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        v.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "verse", for: indexPath) as! favoriteVerseCell
//        let oneverse = Verse(rid: v.myVerses[indexPath.row])
        let onev = v[indexPath.row]
        cell.verseLabel.text = "\(onev.title()): \(onev.fullText())"
        cell.verseLabel.backgroundColor = onev.color
        cell.backgroundColor = onev.color
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
        let alertcontroller = UIAlertController(title: "查看", message: "动作", preferredStyle: .actionSheet)
        let viewAction = UIAlertAction(title: "查看经文", style: .default) { (_) -> Void in
            let oneverse =  self.v[indexPath.row].verses.first!
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "readbible") as! readTableViewController
            vc.chapter = oneverse.getChapter()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let shareAction = UIAlertAction(title: "分享", style: .default) { (_) -> Void in
            let item = [self.v[indexPath.row].titleAndtext]
            let ac = UIActivityViewController(activityItems: item, applicationActivities: nil)
            ac.popoverPresentationController?.sourceView = self.view
            ac.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0,
                                                                           y: self.view.bounds.size.height / 2.0,
                                                                           width: 1.0, height: 1.0)

            self.present(ac, animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertcontroller.addAction(viewAction)
        alertcontroller.addAction(shareAction)
        alertcontroller.addAction(cancelAction)
        alertcontroller.popoverPresentationController?.sourceView = self.view
        alertcontroller.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0,
                                                                           y: self.view.bounds.size.height / 2.0,
                                                                           width: 1.0, height: 1.0)
        present(alertcontroller, animated: true)
    }
}
