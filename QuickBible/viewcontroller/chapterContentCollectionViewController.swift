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
            spineLayer.frame = CGRect(x: 0, y: 0, width: 4, height: contentView.bounds.height)
        }
    }
    
    private func setupCell() {
        // Base setup
        let baseColor = UIColor.systemBrown.withAlphaComponent(0.8)
        contentView.backgroundColor = baseColor
        contentView.layer.cornerRadius = 6
        
        // Spine effect
        let spineLayer = CALayer()
        spineLayer.frame = CGRect(x: 0, y: 0, width: 4, height: contentView.bounds.height)
        spineLayer.backgroundColor = UIColor.brown.darker(by: 40)?.cgColor
        contentView.layer.addSublayer(spineLayer)
        
        // Shadow
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 2, height: 2)
        contentView.layer.shadowRadius = 2
        contentView.layer.shadowOpacity = 0.2
        
        // Gradient for leather-like texture
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
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        
        // Border
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
    }
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
        let itemWidth = (screenWidth - 50) / 4 // 4 items per row
        let itemHeight = itemWidth * 1.2 // Slightly taller than wide
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        layout.sectionHeadersPinToVisibleBounds = true
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 12
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
    override func collectionView(_ collectionView, shouldHighlightItemAt indexPath: Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView, shouldSelectItemAt indexPath: Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView, shouldShowMenuForItemAt indexPath: Bool {
        return false
    }

    override func collectionView(_ collectionView, canPerformAction action: Selector, forItemAt indexPath: Bool, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView, performAction action: Selector, forItemAt indexPath: Bool, withSender sender: Any?) {
    
    }
    */

}
