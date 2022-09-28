//
//  contentCollectionViewController.swift
//  QuickBible
//
//  Created by Joshua Jiang on 28/9/22.
//

import UIKit

class BooknameCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}

private let reuseIdentifier = "bookname"

class contentCollectionViewController: UICollectionViewController {
    let d = DataManager.shareInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Content"
        setLayout()

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
       layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
       layout.itemSize = CGSize(width: screenWidth/4, height: screenHeight/10)
       layout.minimumInteritemSpacing = 0
       layout.minimumLineSpacing = 0
       collectionView.collectionViewLayout = layout
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return d.Books.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BooknameCell
        let onebook = d.Books[indexPath.row]
        cell.nameLabel.text = "\(onebook.Name)"
    
        // Configure the cell
    
        return cell
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
