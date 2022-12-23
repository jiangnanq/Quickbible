//
//  referenceTableViewController.swift
//  QuickBible
//
//  Created by Joshua Jiang on 20/9/22.
//

import UIKit

class referenceTableViewController: UITableViewController {
    var oneverser:Verse?
    var crossRef: [VerseRange] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        crossRef = [VerseRange(oneverse: oneverser!)] + oneverser!.cross_ref()
        let title = oneverser!.isFavorite() ? "Unfavorite" : " Favorite"
        let barbutton = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(togglefavorite))
        navigationItem.rightBarButtonItem = barbutton

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func togglefavorite() {
        let f = FavoriteVerse.shareInstance
        f.toggleFavorite(oneverse: oneverser!)
        let ac = UIAlertController(title: "Sucessful", message: "Done", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        ac.addAction(action)
        self.present(ac, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return crossRef.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reference", for: indexPath)
        let onet = crossRef[indexPath.row]
        cell.textLabel?.text = "\(onet.title()) \(onet.fullText())"
        if indexPath.row == 0 {
            cell.textLabel?.textColor = UIColor.red
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        } else {
            cell.textLabel?.textColor = UIColor.black
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        }

        // Configure the cell...

        return cell
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
