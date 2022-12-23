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
    let v = FavoriteVerse.shareInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My favorite"
        verseTableView.delegate = self
        verseTableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateview), name: updateFavoriteView, object: nil)

        // Do any additional setup after loading the view.
    }
    
    @objc func updateview() {
        self.verseTableView.reloadData()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        verseTableView.reloadData()
//    }
    
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
        v.myVerses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "verse", for: indexPath) as! favoriteVerseCell
        let oneverse = Verse(rid: v.myVerses[indexPath.row])
        cell.verseLabel.text = oneverse.fullText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let oneverse = Verse(rid: v.myVerses[indexPath.row])
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "readbible") as! readTableViewController
        vc.chapter = oneverse.getChapter()
        navigationController?.pushViewController(vc, animated: true)
        
    }
}
