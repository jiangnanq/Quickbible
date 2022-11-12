//
//  readTableViewController.swift
//  QuickBible
//
//  Created by Joshua Jiang on 14/9/22.
//

import UIKit

class verseCell: UITableViewCell {
    @IBOutlet weak var verseLabel: UILabel!
    @IBOutlet weak var refNoLabel: UILabel!
}

protocol readBibleDelegate {
    func chapterDidUpdate(verses: [Verse])
}

class readTableViewController: UITableViewController {
    let d = DataManager.shareInstance
    var chapter:[Verse] = [] {
        didSet {
            self.tableView.reloadData()
            title = "\(chapter.first!.bookNameChn) \(chapter.first!.Chapter)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(chapter.first!.bookNameChn) \(chapter.first!.Chapter)"
        let barbutton = UIBarButtonItem(title: "目录", style: .plain, target: self, action: #selector(selectchapter))
        navigationItem.rightBarButtonItem = barbutton
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func selectchapter() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "bookcontent") as! chapterContentCollectionViewController
        vc.oneBook = Book(oneVerse: chapter.first!)
        vc.readbibledelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Table view data source
    @objc func swipeLeft() {
        chapter = d.nextChapter(oneverse: chapter.last!)
    }
    
    @objc func swipeRight() {
        chapter = d.previousChapter(oneverse: chapter.first!)
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chapter.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "verse", for: indexPath) as! verseCell
        let onet = chapter[indexPath.row]
        cell.verseLabel.text = onet.textWithNumber
        cell.refNoLabel.text = onet.isFavorite() ? "❤️ \(onet.referenceNo)" : "\(onet.referenceNo)"
        // Configure the cell...
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let oneverse = chapter[tableView.indexPathForSelectedRow!.row]
        let vc = segue.destination as! referenceTableViewController
        vc.oneverser = oneverse
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let oneverse = chapter[indexPath.row]
//        let title = oneverse.isFavorite() ? "Unfavorite" : "Favorite"
//        let ac = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
//        let aa1 = UIAlertAction(title: title, style: .default) { (_) in
//            let f = FavoriteVerse.shareInstance
//            f.addVerse(oneverse: oneverse)
//            tableView.reloadRows(at: [indexPath], with: .fade)
//        }
//        
//        let aa2 = UIAlertAction(title: "Details", style: .default) { (_) in
//            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "reference") as! referenceTableViewController
//            vc.oneverser = oneverse
//            self.navigationController?.pushViewController(vc, animated:true)
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//        ac.addAction(aa1)
//        ac.addAction(aa2)
//        ac.addAction(cancelAction)
//        present(ac, animated: true)
//        print(chapter[indexPath.row].Text)
//        let onev = chapter[indexPath.row]
//        let oned = d.cross_ref(oneverse:onev)
//        for v in oned{
//            print("\(v.title()) \(v.fullText())")
//        }
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension readTableViewController: readBibleDelegate {
    func chapterDidUpdate(verses: [Verse]) {
        chapter = verses
    }
}
