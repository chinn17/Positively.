//
//  MessagesController.swift
//  Positively
//
//  Created by Chintan Puri on 08/10/17.
//  Copyright © 2017 Chintan Puri. All rights reserved.
//


import UIKit
import Firebase
import Crashlytics


class MessagesController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let internet = Reachability()!
    var isInternetConnected = true
    var activityIndicatorView = UIActivityIndicatorView()
    
    let cellId = "cellId"
    
    let settingsView : UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        return view
        
    }()
    
    let tableHeader : UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.white
        
        return view
        
    }()
    
    let tableTitle : UILabel = {
        
        let label = UILabel()
        label.text = "Messages"
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }()
    
    
    let saveChangesButton : UIButton = {
        
        let add = UIButton()
        add.setTitle("SAVE CHANGES", for: UIControlState())
        add.setTitleColor(UIColor.white, for: UIControlState())
        add.layer.cornerRadius = 16
        add.backgroundColor = UIColor(displayP3Red: 178/255, green: 57/255, blue: 67/255, alpha: 1)
        let fontSize = add.titleLabel?.font.pointSize;
        add.titleLabel?.font = UIFont(name: "Futura", size: fontSize!)
        add.translatesAutoresizingMaskIntoConstraints = false
        add.addTarget(self, action: #selector(changeProfilePicture), for: .touchUpInside)
        return add
        
    }()
    
    let cancelButton : UIButton = {
        
        let cancel = UIButton()
        
        cancel.setTitle("Close", for: UIControlState())
        cancel.setTitleColor(UIColor.darkGray, for: UIControlState())
        cancel.backgroundColor = UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        let fontSize = cancel.titleLabel?.font.pointSize;
        cancel.titleLabel?.font = UIFont(name: "Futura", size: fontSize!)
        cancel.layer.cornerRadius = 16
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.addTarget(self, action: #selector(dismissSettingsView), for: .touchUpInside)
        return cancel
        
    }()
    
    let changeProfileImageView : UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "dp")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    
    let logoutButton : UIButton = {
        
        let logoutBtn = UIButton()
        logoutBtn.setTitle("Logout", for: UIControlState())
        logoutBtn.setTitleColor(UIColor.darkGray, for: UIControlState())
        logoutBtn.backgroundColor = UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        let fontSize = logoutBtn.titleLabel?.font.pointSize;
        logoutBtn.titleLabel?.font = UIFont(name: "Futura", size: fontSize!)
        logoutBtn.layer.cornerRadius = 16
        logoutBtn.translatesAutoresizingMaskIntoConstraints = false
        logoutBtn.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return logoutBtn
        
    }()
    
    
    let colorsButton : UIButton = {
        
        let button = UIButton()
        button.setTitle("COLORS", for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.backgroundColor = UIColor(displayP3Red: 253/255, green: 231/255, blue: 155/255, alpha: 1)
        let fontSize = button.titleLabel?.font.pointSize;
        button.titleLabel?.font = UIFont(name: "Futura", size: fontSize!)
        button.layer.cornerRadius = 10
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showColorsController), for: .touchUpInside)
        return button
        
    }()
    
    
    let editImage : UIButton = {
        
        let editBtn = UIButton()
        editBtn.setTitle("Change Image", for: UIControlState())
        editBtn.setTitleColor(UIColor.darkGray, for: UIControlState())
        editBtn.layer.cornerRadius = 16
        editBtn.backgroundColor =  UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        let fontSize = editBtn.titleLabel?.font.pointSize;
        editBtn.titleLabel?.font = UIFont(name: "Futura", size: fontSize!)
        editBtn.translatesAutoresizingMaskIntoConstraints = false
        editBtn.addTarget(self, action: #selector(openPicker), for: .touchUpInside)
        return editBtn
        
        
        
    }()
    
    
    let profileImageChangedView : UIView = {
        let view = UIView()
        
        //        view.backgroundColor = UIColor(displayP3Red: 250, green: 250, blue: 250, alpha: 0.9)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let imageChangedMessage : UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.text = "Changed Successfully"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        return label
        
    }()
    
    
    let customView : UIView = {
        let view = UIView()
        view.contentMode = .scaleAspectFit
        view.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        return view
        
    }()
    
    
    let customLabel : UILabel = {
        let view = UILabel()
        view.text = "Waiting for network"
        view.contentMode = .scaleAspectFit
        view.adjustsFontSizeToFitWidth = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
        
    }()
    
    let noConnectionImage : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "oops")
        imageView.contentMode = .scaleAspectFit
        return imageView
        
    }()
    
    let noMessagesImage : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "start")
        imageView.contentMode = .scaleAspectFit
        return imageView
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        setupTitleView()
        checkIfInternetIsReachable()
        setupInternetChangedNotifier()
        checkIfUserIsLoggedIn()
        setupTableHeader()
        
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(showSettingsViewController))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(displayP3Red: 253/255, green: 231/255, blue: 155/255, alpha: 1)
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "add"), style: .plain, target: self, action: #selector(handleNewMessage))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(displayP3Red: 255/255, green: 25/255, blue: 90/255, alpha: 1)
        
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        
        
        tableView.allowsMultipleSelectionDuringEditing = true
        if (!isInternetConnected) {
            self.noConnectionImage.frame = self.view.bounds
            self.view.addSubview(self.noConnectionImage)
            self.tableHeader.isHidden = true
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if(isInternetConnected) {
            self.navigationItem.titleView?.isHidden = true
            
        }
        self.customLabel.text = "Waiting for network..."
        
    }
    
    
    func setupTitleView() {
        
        self.activityIndicatorView.hidesWhenStopped = true
        
        
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        customView.addSubview(activityIndicatorView)
        customView.addSubview(customLabel)
        
        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.activityIndicatorView.leftAnchor.constraint(equalTo: self.customView.leftAnchor).isActive = true
        
        
        self.activityIndicatorView.rightAnchor.constraint(equalTo: self.customLabel.leftAnchor).isActive = true
        
        self.activityIndicatorView.topAnchor.constraint(equalTo: self.customView.topAnchor).isActive = true
        
        self.activityIndicatorView.widthAnchor.constraint(equalTo: self.customView.widthAnchor ,multiplier:1/4 ).isActive = true
        
        self.activityIndicatorView.heightAnchor.constraint(equalTo: self.customView.heightAnchor).isActive = true
        
        self.customLabel.leftAnchor.constraint(equalTo: self.activityIndicatorView.rightAnchor).isActive = true
        
        
        self.customLabel.rightAnchor.constraint(equalTo: self.customView.rightAnchor).isActive = true
        self.customLabel.topAnchor.constraint(equalTo: self.customView.topAnchor).isActive = true
        
        self.customLabel.widthAnchor.constraint(equalTo: self.customView.widthAnchor, multiplier: 3/4).isActive = true
        
        self.customLabel.heightAnchor.constraint(equalTo: self.customView.heightAnchor).isActive = true
        
        self.navigationItem.titleView = customView
        self.navigationItem.titleView?.isHidden = true
        
    }
    
    func checkIfInternetIsReachable() {
        
        internet.whenReachable = { _ in
            
            self.dismissNoConnMessage()
        }
        
        internet.whenUnreachable = { _ in
            self.showNoConnMessage()
        }
    }
    
    
    
    
    
    
    func setupInternetChangedNotifier() {
        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: ReachabilityChangedNotification, object: internet)
        do {
            
            try internet.startNotifier()
            
        }catch {
            
            print("Could not start notifier")
            
        }
    }
    
    
    @objc func internetChanged(notification: Notification) {
        
        let internetConn = notification.object as! Reachability
        
        if internetConn.isReachable {
            self.isInternetConnected = true
            
            self.dismissNoConnMessage()
            
        }
        else {
            self.isInternetConnected = false
            DispatchQueue.main.async {
                self.showNoConnMessage()
            }
        }
    }
    
    
    
    func showNoConnMessage() {
        
        self.navigationItem.titleView?.isHidden = false
        self.activityIndicatorView.startAnimating()
        
    }
    
    
    @objc func dismissNoConnMessage(){
        self.tableHeader.isHidden = false
        self.noConnectionImage.removeFromSuperview()
        self.navigationItem.titleView?.isHidden = true
        self.activityIndicatorView.stopAnimating()
        
    }
    
    
    
    
    func setupTableHeader() {
        self.view.addSubview(self.tableHeader)
        tableHeader.frame.size.height = 50
        self.tableView.tableHeaderView = self.tableHeader
        
        tableHeader.addSubview(tableTitle)
        
        tableTitle.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        tableTitle.centerYAnchor.constraint(equalTo: tableHeader.centerYAnchor).isActive = true
        
        tableTitle.heightAnchor.constraint(equalTo: tableHeader.heightAnchor).isActive = true
        tableTitle.widthAnchor.constraint(equalTo: tableHeader.widthAnchor, multiplier: 1/2).isActive = true
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }
                
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
                
                
            })
        }
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var localStorageDictionary = [String : [Message]]()
    
    
    func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        
        self.noMessagesImage.frame = self.tableView.bounds
        self.noMessagesImage.center = CGPoint(x: self.tableView.center.x, y: self.tableView.center.y - self.tableHeader.center.y)
        self.view.addSubview(self.noMessagesImage)
        self.tableHeader.isHidden = true
        
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            self.noMessagesImage.removeFromSuperview()
            self.tableHeader.isHidden = false
            
            let userId = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                guard let messageId = snapshot.key as String? else {
                    return
                }
                
                if (messageId == "isTyping") {
                    
                    return
                }
                
                self.fetchMessageWithMessageId(messageId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            if(self.messagesDictionary.isEmpty) {
                self.noMessagesImage.frame = self.tableView.bounds
                self.noMessagesImage.center = CGPoint(x: self.tableView.center.x, y: self.tableView.center.y - self.tableHeader.center.y)
                self.view.addSubview(self.noMessagesImage)
                self.tableHeader.isHidden = true
            }
            
            
            self.attemptReloadOfTable()
            
        }, withCancel: nil)
    }
    
    
    
    
    fileprivate func fetchMessageWithMessageId(_ messageId: String) {
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                    if (self.localStorageDictionary.keys.contains(chatPartnerId)) {
                        self.localStorageDictionary[chatPartnerId]?.append(message)
                        
                    } else {
                        var mssArray = [Message]()
                        mssArray.append(message)
                        self.localStorageDictionary[chatPartnerId] = mssArray
                        
                    }
                }
                self.attemptReloadOfTable()
            }
            
        }, withCancel: nil)
        
        
    }
    
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return message1.timestamp?.int32Value > message2.timestamp?.int32Value
        })
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        cell.detailTextLabel?.preferredMaxLayoutWidth = 100
        cell.detailTextLabel?.lineBreakMode = .byTruncatingTail
        cell.selectionStyle = UITableViewCellSelectionStyle.default
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        if (isInternetConnected)  {
            
            self.activityIndicatorView.startAnimating()
            self.navigationItem.titleView?.isHidden = false
            self.customLabel.text = "Connecting..."
            
            
            let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            
            chatLogController.chatPartner = chatPartnerId
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.pushViewController(chatLogController, animated: true)
            
            
            
        } else {
            
            print("NOT CONNECTED AND SHOWING")
            
            let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            
            chatLogController.isInternetConnected = false
            chatLogController.existingMessages = self.localStorageDictionary[chatPartnerId]!
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.pushViewController(chatLogController, animated: true)
        }
        
    }
    
    
    
    func showChatControllerForUser(_ user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.chatPartner = user.id
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.black
        navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    
    @objc func handleNewMessage() {
        let newMessageController = FriendsController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        navController.navigationItem.backBarButtonItem?.tintColor = UIColor(displayP3Red: 255/255, green: 25/255, blue: 90/255, alpha: 1)
        present(navController, animated: true, completion: nil)
        
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
         
                if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                    self.changeProfileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                }
                let user = User(dictionary: dictionary)
                self.setupNavBarWithUser(user)
            }
            
        }, withCancel: nil)
    }
    
    
    
    func setupNavBarWithUser(_ user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
    }
    
    
    @objc func showSettingsViewController() {
        self.view.addSubview(self.settingsView)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = settingsView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        settingsView.addSubview(blurEffectView)
        
        self.settingsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.settingsView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.settingsView.widthAnchor.constraint(equalTo: self.tableView.widthAnchor, constant: -20).isActive = true
        self.settingsView.heightAnchor.constraint(equalTo: self.tableView.heightAnchor, multiplier: 0.7).isActive = true
        self.settingsView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        
        
        settingsView.addSubview(self.saveChangesButton)
        settingsView.addSubview(self.editImage)
        settingsView.addSubview(self.logoutButton)
        settingsView.addSubview(self.cancelButton)
        settingsView.addSubview(self.changeProfileImageView)
        settingsView.addSubview(self.colorsButton)
        
        saveChangesButton.centerXAnchor.constraint(equalTo: settingsView.centerXAnchor).isActive = true
        saveChangesButton.bottomAnchor.constraint(equalTo: settingsView.bottomAnchor, constant: -10).isActive = true
        saveChangesButton.widthAnchor.constraint(equalTo: settingsView.widthAnchor, multiplier : 0.8).isActive = true
        saveChangesButton.heightAnchor.constraint(equalTo: settingsView.heightAnchor, multiplier: 1/8).isActive = true
        
        
        
        cancelButton.rightAnchor.constraint(equalTo: settingsView.rightAnchor, constant : -10).isActive = true
        cancelButton.topAnchor.constraint(equalTo: settingsView.topAnchor, constant : 10).isActive = true
        
        cancelButton.widthAnchor.constraint(equalTo: settingsView.widthAnchor, multiplier: 1/4 ).isActive = true
        cancelButton.heightAnchor.constraint(equalTo: settingsView.heightAnchor, multiplier: 1/8).isActive = true
        
        
        
        changeProfileImageView.centerXAnchor.constraint(equalTo: self.settingsView.centerXAnchor).isActive = true
        changeProfileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        changeProfileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        changeProfileImageView.layer.cornerRadius = 50
        changeProfileImageView.clipsToBounds = true
        
        logoutButton.leftAnchor.constraint(equalTo: self.settingsView.leftAnchor, constant: 10).isActive = true
        logoutButton.topAnchor.constraint(equalTo: self.settingsView.topAnchor, constant: 10).isActive = true
        logoutButton.widthAnchor.constraint(equalTo: settingsView.widthAnchor, multiplier: 1/4 ).isActive = true
        logoutButton.heightAnchor.constraint(equalTo: settingsView.heightAnchor, multiplier: 1/8).isActive = true
        
        
        colorsButton.centerXAnchor.constraint(equalTo: self.settingsView.centerXAnchor).isActive = true
        colorsButton.topAnchor.constraint(equalTo: self.settingsView.topAnchor, constant: 10).isActive = true
        colorsButton.widthAnchor.constraint(equalTo: settingsView.widthAnchor, multiplier: 1/4 ).isActive = true
        colorsButton.heightAnchor.constraint(equalTo: settingsView.heightAnchor, multiplier: 1/8).isActive = true
        colorsButton.bottomAnchor.constraint(equalTo: self.changeProfileImageView.topAnchor, constant : -10).isActive = true
        
        editImage.centerXAnchor.constraint(equalTo: settingsView.centerXAnchor).isActive = true
        editImage.bottomAnchor.constraint(equalTo: saveChangesButton.topAnchor, constant: -20).isActive = true
        editImage.widthAnchor.constraint(equalTo: settingsView.widthAnchor,multiplier: 1/2).isActive = true
        editImage.heightAnchor.constraint(equalTo: settingsView.heightAnchor,multiplier : 1/8).isActive = true
        
        self.settingsView.addSubview(self.profileImageChangedView)
        
        profileImageChangedView.topAnchor.constraint(equalTo: self.settingsView.topAnchor).isActive = true
        profileImageChangedView.leftAnchor.constraint(equalTo: self.settingsView.leftAnchor).isActive = true
        profileImageChangedView.rightAnchor.constraint(equalTo: self.settingsView.rightAnchor).isActive = true
        profileImageChangedView.bottomAnchor.constraint(equalTo: self.settingsView.bottomAnchor).isActive = true
        profileImageChangedView.widthAnchor.constraint(equalTo: self.settingsView.widthAnchor).isActive = true
        profileImageChangedView.heightAnchor.constraint(equalTo: self.settingsView.heightAnchor).isActive = true
        profileImageChangedView.isHidden = true
        profileImageChangedView.addSubview(imageChangedMessage)
        
        
        imageChangedMessage.centerXAnchor.constraint(equalTo: self.settingsView.centerXAnchor).isActive = true
        imageChangedMessage.centerYAnchor.constraint(equalTo: self.settingsView.centerYAnchor).isActive = true
        imageChangedMessage.topAnchor.constraint(equalTo: self.settingsView.topAnchor, constant: 30).isActive = true
        imageChangedMessage.widthAnchor.constraint(equalTo: profileImageChangedView.widthAnchor, multiplier: 0.8).isActive = true
        imageChangedMessage.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
    }
    
    
    @objc func changeProfilePicture() {
        
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
        
        if let profileImage = self.changeProfileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
            
            let uid = Auth.auth().currentUser?.uid
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    let ref = Database.database().reference().child("users").child(uid!)
                    ref.updateChildValues(["profileImageUrl":profileImageUrl])
                }
            })
            
        }
        
        let gradientLayer = CAGradientLayer()
        let startingColorGradient = UIColor(red: 255/255, green: 195/255, blue: 113/255, alpha: 1).cgColor
        let endingColorGradient = UIColor(red: 255/255, green: 95/255, blue: 109/255, alpha: 1).cgColor
        gradientLayer.frame = self.profileImageChangedView.bounds
        gradientLayer.colors = [startingColorGradient,endingColorGradient]
        self.profileImageChangedView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.profileImageChangedView.isHidden = false
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.dismissSettingsView), userInfo: nil, repeats: false)
    }
    
   
    
    @objc func dismissSettingsView () {
        imageChangedMessage.removeFromSuperview()
        self.profileImageChangedView.isHidden = true
        self.settingsView.removeFromSuperview()
        
    }
    
    
    @objc func openPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc func showColorsController() {
        let colorsController = ColorsController()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor(displayP3Red: 255/255, green: 25/255, blue: 90/255, alpha: 1)
        navigationController?.pushViewController(colorsController, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            self.changeProfileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func handleLogout() {
        let userId = Auth.auth().currentUser?.uid
        
        if userId != nil {
            if (Messaging.messaging().fcmToken != nil) {
                Messaging.messaging().unsubscribe(fromTopic: userId!)
            }
        }
        
        self.settingsView.removeFromSuperview()
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        
        
        let loginSignUpViewController = InitialController()
        loginSignUpViewController.messagesController = self
        
        present(loginSignUpViewController, animated: true, completion: nil)
    }
    
    
    
    
}


fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


