//
//  chapterContentCollectionViewController.swift
//  QuickBible
//
//  Created by Joshua Jiang on 30/9/22.
//

import UIKit

private let reuseIdentifier = "chapter"

class chapterTitleCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}

class chapterContentCollectionViewController: UICollectionViewController {
    var oneBook: Book?
    var readbibledelegate: readBibleDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
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
       layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
       layout.sectionHeadersPinToVisibleBounds = true
       layout.itemSize = CGSize(width: screenWidth/8, height: screenHeight/12)
       layout.minimumInteritemSpacing = 0
       layout.minimumLineSpacing = 5
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
        return oneBook!.chapterNumber
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! chapterTitleCell
        cell.titleLabel.text = "\(String(indexPath.row + 1))"
        cell.titleLabel.layer.cornerRadius = cell.titleLabel.frame.size.height / 2.0
        cell.titleLabel.layer.masksToBounds = true
        // Configure the cell
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row + 1
        let v = oneBook?.oneChapter(chapterNumber: index)
        readbibledelegate?.chapterDidUpdate(verses: v!)
        navigationController?.popViewController(animated: true)
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
