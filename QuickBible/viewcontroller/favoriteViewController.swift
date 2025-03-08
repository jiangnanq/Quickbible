//
//  favoriteViewController.swift
//  QuickBible
//
//  Created by Joshua Jiang on 8/10/22.
//

import UIKit

class favoriteVerseCell: UITableViewCell {
    @IBOutlet weak var verseLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure label
        verseLabel.numberOfLines = 0
        verseLabel.font = .systemFont(ofSize: 16)
        verseLabel.lineBreakMode = .byWordWrapping
        
        // Setup constraints
        verseLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        
        NSLayoutConstraint.activate([
            verseLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            verseLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            verseLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            verseLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
        
        // Cell styling
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }
}

class favoriteViewController: UIViewController {
    @IBOutlet weak var verseTableView: UITableView!
    var v = FavoriteVerse.shareInstance.verseInRange()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的收藏"
        verseTableView.delegate = self
        verseTableView.dataSource = self
        
        // Configure table view for automatic sizing
        verseTableView.rowHeight = UITableView.automaticDimension
        verseTableView.estimatedRowHeight = 150 // Increased estimated height
        verseTableView.separatorStyle = .none
        verseTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        verseTableView.cellLayoutMarginsFollowReadableWidth = true
        
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
        let onev = v[indexPath.row]
        
        // Configure cell
        cell.verseLabel.text = "\(onev.title()): \(onev.fullText())"
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = onev.color.withAlphaComponent(0.3)
        cell.selectionStyle = .none
        
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    // Add cell spacing
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let verticalPadding: CGFloat = 10
        
        let maskLayer = CALayer()
        maskLayer.cornerRadius = 8
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x,
                               y: cell.bounds.origin.y,
                               width: cell.bounds.width,
                               height: cell.bounds.height).insetBy(dx: 8, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
}
