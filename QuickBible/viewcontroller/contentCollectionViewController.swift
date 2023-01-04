//
//  contentCollectionViewController.swift
//  QuickBible
//
//  Created by Joshua Jiang on 28/9/22.
//

import UIKit
import Intents

class BooknameCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
}

private let reuseIdentifier = "bookname"

class contentCollectionViewController: UICollectionViewController {
    let b = DataManager.shareInstance.bible

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        self.title = "读圣经"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
   
    func setLayout() {
       let screenSize = UIScreen.main.bounds
       let screenWidth = screenSize.width
       let screenHeight = screenSize.height
       let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
       layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
       layout.sectionHeadersPinToVisibleBounds = true
       layout.itemSize = CGSize(width: screenWidth/4, height: screenHeight/8)
       layout.minimumInteritemSpacing = 0
       layout.minimumLineSpacing = 5
       collectionView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let c = collectionView.indexPathsForSelectedItems?.first {
            let book = b.sections[c.section][c.row]
            let vc = segue.destination as! readTableViewController
            vc.chapter = book.HistoryChapter
        }
        
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return b.sections.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return b.sections[section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BooknameCell
        let onebook = b.sections[indexPath.section][indexPath.row]
        cell.nameLabel.text = "\(onebook.Name)"
        let c = HistoryVerse.shareInstance.historyVerse[onebook.BookId - 1]
        cell.historyLabel.text = "\(c) of \(onebook.allChapter)"
        // Configure the cell
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath) as?  sectionHeader{
            sectionHeader.sectionLabel.text = "摩西五经"
            return sectionHeader
        }
        return UICollectionReusableView()
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
}
