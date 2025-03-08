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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update gradient and spine layers when layout changes
        if let gradientLayer = contentView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = contentView.bounds
        }
        if let spineLayer = contentView.layer.sublayers?.last {
            spineLayer.frame = CGRect(x: 0, y: 0, width: 8, height: contentView.bounds.height)
        }
    }
    
    private func setupCell() {
        // Base color adjustments
        let baseColor = nameLabel.backgroundColor?.withAlphaComponent(0.85) ?? .systemBrown.withAlphaComponent(0.85)
        contentView.backgroundColor = baseColor
        contentView.layer.cornerRadius = 6
        
        // Enhanced spine effect
        let spineLayer = CALayer()
        spineLayer.frame = CGRect(x: 0, y: 0, width: 8, height: contentView.bounds.height)
        spineLayer.backgroundColor = baseColor.darker(by: 40)?.cgColor
        contentView.layer.addSublayer(spineLayer)
        
        // Refined shadow for elegant depth
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 2, height: 2)
        contentView.layer.shadowRadius = 3
        contentView.layer.shadowOpacity = 0.25
        
        // Sophisticated gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = contentView.bounds
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.15).cgColor,
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.1).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        contentView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Text styling
        nameLabel.textAlignment = .center
        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.backgroundColor = .clear
        nameLabel.textColor = .white
        
        historyLabel.textAlignment = .center
        historyLabel.font = .systemFont(ofSize: 12, weight: .medium)
        historyLabel.textColor = .white.withAlphaComponent(0.9)
        
        // Add subtle border
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
    }
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
        let itemWidth = (screenWidth - 40) / 3 // 3 items per row with margins
        let itemHeight = itemWidth * 1.3 // Golden ratio-ish
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        layout.sectionHeadersPinToVisibleBounds = true
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 15
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
        
        // Adjust the color to be more formal
        let formalColor = onebook.color.withAlphaComponent(0.85)
        cell.nameLabel.backgroundColor = .clear
        cell.contentView.backgroundColor = formalColor
        cell.backgroundColor = .clear
        
        let c = HistoryVerse.shareInstance.historyVerse[onebook.BookId - 1]
        cell.historyLabel.text = onebook.favoriteCount == 0 ? "\(c)/\(onebook.allChapter)":"\(onebook.favoriteCount)❤️"
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
    override func collectionView(_ collectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
}
