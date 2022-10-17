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
    @IBOutlet weak var selectSeg: UISegmentedControl!
    @IBOutlet weak var verseTableView: UITableView!
    let v = FavoriteVerse.shareInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        verseTableView.delegate = self
        verseTableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        verseTableView.reloadData()
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
        v.myVerses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "verse", for: indexPath) as! favoriteVerseCell
        let oneverse = Verse(rid: v.myVerses[indexPath.row])
        cell.verseLabel.text = oneverse.fullText
        return cell
    }
}
