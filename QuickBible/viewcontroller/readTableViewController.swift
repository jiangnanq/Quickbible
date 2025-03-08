//
//  readTableViewController.swift
//  QuickBible
//
//  Created by Joshua Jiang on 14/9/22.
//

import UIKit
import AVFoundation
import MediaPlayer

protocol verseCellDelegate: AnyObject  {
    func likeButtonPressed(at indexPath: IndexPath)
}

class verseCell: UITableViewCell {
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let numberView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let refNoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let verseLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    weak var delegate: verseCellDelegate?
    var indexPath: IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(verseLabel)
        containerView.addSubview(bottomStack)
        
        bottomStack.addArrangedSubview(numberView)
        numberView.addSubview(refNoLabel)
        bottomStack.addArrangedSubview(likeButton)
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            verseLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            verseLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            verseLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            verseLabel.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -8),
            
            bottomStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            bottomStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            numberView.widthAnchor.constraint(equalToConstant: 30),
            numberView.heightAnchor.constraint(equalToConstant: 24),
            
            refNoLabel.centerXAnchor.constraint(equalTo: numberView.centerXAnchor),
            refNoLabel.centerYAnchor.constraint(equalTo: numberView.centerYAnchor),
            
            likeButton.widthAnchor.constraint(equalToConstant: 24),
            likeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    @objc private func likeButtonTapped() {
        if let indexPath = indexPath {
            delegate?.likeButtonPressed(at: indexPath)
        }
    }
}

protocol readBibleDelegate {
    func chapterDidUpdate(verses: [Verse])
}

class readTableViewController: UITableViewController, verseCellDelegate{
    var player: AVQueuePlayer?
    let d = DataManager.shareInstance
    var chapter:[Verse] = [] {
        didSet {
            self.tableView.reloadData()
            title = "\(chapter.first!.bookNameChn) \(chapter.first!.Chapter)"
            HistoryVerse.shareInstance.saveVerse(v: chapter.first!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(chapter.first!.bookNameChn) \(chapter.first!.Chapter)"
        let barbutton = UIBarButtonItem(title: "...", style: .plain, target: self, action: #selector(showPopupMenu))
        navigationItem.rightBarButtonItem = barbutton
        
        // Register cell class programmatically
        tableView.register(verseCell.self, forCellReuseIdentifier: "verse")
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        NotificationCenter.default.addObserver(self, selector: #selector(updateVerse), name: updateVerseView, object: nil)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func showPopupMenu(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "目录", style: .default) { _ in
            self.selectchapter()
        }
        let action2 = UIAlertAction(title: "中英对照", style: .default) { _ in
            DataManager.shareInstance.english.toggle()
            self.tableView.reloadData()
        }
        let action3 = UIAlertAction(title: "朗读", style: .default) { _ in
            self.d.playChapter(chapter: self.chapter)
        }
        let action4 = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        alertController.addAction(action4)
        present(alertController, animated: true, completion: nil)
       }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    
    @objc func updateVerse(notification: NSNotification) {
        if let v = notification.userInfo?["verse"] as? Verse {
            if let i = chapter.firstIndex(of: v) {
                self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
            }
        }
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
        let verse = chapter[indexPath.row]
        let eng = DataManager.shareInstance.english
        
        cell.verseLabel.text = eng ? "\(verse.textWithNumber)\n\(verse.Text_eng)" : verse.textWithNumber
        cell.refNoLabel.text = "\(verse.referenceNo)"
        cell.likeButton.setTitle(verse.isFavorite() ? "❤️" : "🤍", for: .normal)
        cell.delegate = self
        cell.indexPath = indexPath
        
        return cell
    }
    
    func likeButtonPressed(at indexPath: IndexPath) {
        let onet = chapter[indexPath.row]
        let f = FavoriteVerse.shareInstance
        f.toggleFavorite(oneverse: onet)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oneverse = chapter[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "reference") as! referenceTableViewController
        vc.oneverser = oneverse
        navigationController?.pushViewController(vc, animated: true)
    }
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
    override func tableView(_ tableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    override func tableView(_ tableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView, canMoveRowAt indexPath: IndexPath) -> Bool {
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

extension readTableViewController: readBibleDelegate {
    func chapterDidUpdate(verses: [Verse]) {
        chapter = verses
    }
}
