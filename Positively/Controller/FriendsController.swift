//
//  NewMessageController.swift
//  Positively
//
//  Created by Chintan Puri on 08/10/17.
//  Copyright © 2017 Chintan Puri. All rights reserved.
//


import UIKit
import Firebase


class FriendsController: UITableViewController,UINavigationControllerDelegate {
    
    let internet = Reachability()!
    var activityIndicatorView = UIActivityIndicatorView()
    var isInternetConnected = true
    let backgroundConnectionImage : UIImageView = {
        
        let imageView = UIImageView()
        
        return imageView
        
        
    }()
    
    let cellId = "cellId"
    
    var users = [User]()
    
    
    let newChatContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    
    
    let emailTextField : UITextField = {
        
        let tf = UITextField()
        tf.placeholder = "enter your friend's email"
        tf.backgroundColor = UIColor.white
        tf.layer.cornerRadius = 10
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.layer.masksToBounds = true
        
        return tf
        
    }()
    
    let addButton : UIButton = {
        
        let add = UIButton()
        add.setTitle("Add Friend", for: UIControlState())
        add.titleLabel?.textColor = UIColor.white
        add.layer.cornerRadius = 5
        add.backgroundColor = UIColor(displayP3Red: 178/255, green: 57/255, blue: 67/255, alpha: 1)
        add.translatesAutoresizingMaskIntoConstraints = false
        add.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
        return add
        
    }()
    
    let cancelButton : UIButton = {
        
        let cancel = UIButton()
        
        cancel.setTitle("close", for: UIControlState())
        cancel.titleLabel?.textColor = UIColor.white
        
        cancel.backgroundColor = UIColor(displayP3Red: 178/255, green: 57/255, blue: 67/255, alpha: 1)
        
        cancel.layer.cornerRadius = 5
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.addTarget(self, action: #selector(dismissAddFriend), for: .touchUpInside)
        return cancel
        
    }()
    
    let friendAddedView : UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor(displayP3Red: 250, green: 250, blue: 250, alpha: 0.5)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        
        return view
    }()
    
    
    
    let friendAddedMessage : UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.text = "Friend Added"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        return label
        
    }()
    
    let label = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInternetActivityIndicator()
        checkIfInternetIsReachable()
        setupInternetChangedNotifier()
        
        navigationItem.title = "Friends"
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "backbtn"), style: .plain, target: self, action: #selector(dismissController))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(displayP3Red: 255/255, green: 25/255, blue: 90/255, alpha: 1)
        
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "add", style: .plain, target: self, action: #selector(newChat))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(displayP3Red: 255/255, green: 25/255, blue: 90/255, alpha: 1)
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        
        
        fetchUser()
    }
    
    func setupInternetActivityIndicator() {
        
        self.activityIndicatorView.hidesWhenStopped = true
        self.activityIndicatorView.center = CGPoint(x: (self.navigationController?.navigationBar.center.x)! - 98, y : (self.navigationController?.navigationBar.center.y)!)
        
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.navigationController?.navigationBar.addSubview(activityIndicatorView)
        
        
    }
    
    func checkIfInternetIsReachable() {
        
        internet.whenReachable = { _ in
            
            if (self.isInternetConnected == false) {
                self.isInternetConnected = true
                
            }
            self.isInternetConnected = true
            self.dismissNoConnMessage()
        }
        
        internet.whenUnreachable = { _ in
            self.isInternetConnected = false
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
            DispatchQueue.main.async {
                
                self.dismissNoConnMessage()
            }
        }
        else {
            
            DispatchQueue.main.async {
                self.showNoConnMessage()
            }
        }
    }
    
    
    
    func showNoConnMessage() {
        isInternetConnected = false
        self.navigationItem.title = "Waiting for network..."
        self.activityIndicatorView.startAnimating()
        self.users.removeAll()
        self.tableView.reloadData()
        
    }
    
    
    func dismissNoConnMessage(){
        isInternetConnected = true
        self.navigationItem.title = "Friends"
        self.activityIndicatorView.stopAnimating()
        
        
    }
    
    
    
    
    
    func fetchUser() {
        
        if(isInternetConnected) {
            
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).child("friends").observe(.childAdded, with: { (snapshot) in
                
                guard let friendId = snapshot.key as String? else {
                    
                    return
                }
                
                
                
                if (friendId != "No Friends") {
                    
                    Database.database().reference().child("users").child(friendId).observe(.value, with: { (snap) in
                        
                        
                        if let dictionary = snap.value as? [String: AnyObject] {
                            
                            
                            
                            let user = User(dictionary: dictionary)
                            user.id = snapshot.key
                            self.users.append(user)
                            
                            
                            DispatchQueue.main.async(execute: {
                                self.tableView.reloadData()
                            })
                        }
                        
                    }, withCancel: nil)
                    
                }else {
                    
                    
                    print("NO FRIENDS TABLE EMPTY")
                }
                
            }, withCancel: nil)
        }
    }
    
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @objc func newChat () {
        
        self.view.addSubview(self.newChatContainerView)
        self.setupNewChatContainerView()
        
    }
    
    
    
    
    var newChatContainerViewHeightAnchor : NSLayoutConstraint?
    
    func setupNewChatContainerView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = newChatContainerView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newChatContainerView.addSubview(blurEffectView)
        
        newChatContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newChatContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        newChatContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier : 1/1.25).isActive = true
        newChatContainerViewHeightAnchor = newChatContainerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/3)
        newChatContainerViewHeightAnchor?.isActive = true
        
        newChatContainerView.addSubview(emailTextField)
        newChatContainerView.addSubview(addButton)
        newChatContainerView.addSubview(cancelButton)
        
        emailTextField.leftAnchor.constraint(equalTo: newChatContainerView.leftAnchor, constant: 25).isActive = true
        
        emailTextField.rightAnchor.constraint(equalTo: newChatContainerView.rightAnchor, constant: -25).isActive = true
        emailTextField.centerXAnchor.constraint(equalTo: newChatContainerView.centerXAnchor).isActive = true
        emailTextField.centerYAnchor.constraint(equalTo: newChatContainerView.centerYAnchor).isActive = true
        
        
        emailTextField.widthAnchor.constraint(equalTo: newChatContainerView.widthAnchor, constant: -50).isActive = true
        
        
        addButton.centerXAnchor.constraint(equalTo: newChatContainerView.centerXAnchor).isActive = true
        addButton.bottomAnchor.constraint(equalTo: newChatContainerView.bottomAnchor, constant: -12).isActive = true
        addButton.widthAnchor.constraint(equalTo: newChatContainerView.widthAnchor,multiplier: 1/2.5).isActive = true
        addButton.heightAnchor.constraint(equalTo: newChatContainerView.heightAnchor,multiplier : 1/8).isActive = true
        
        cancelButton.rightAnchor.constraint(equalTo: newChatContainerView.rightAnchor, constant : -10).isActive = true
        cancelButton.topAnchor.constraint(equalTo: newChatContainerView.topAnchor, constant : 10).isActive = true
        
        cancelButton.widthAnchor.constraint(equalTo: newChatContainerView.widthAnchor, multiplier: 1/4).isActive = true
        cancelButton.heightAnchor.constraint(equalTo : newChatContainerView.heightAnchor, multiplier: 1/8).isActive = true
        
        
        
        
        self.label.text = "Invalid Email"
        self.label.adjustsFontSizeToFitWidth = true
        self.label.textColor = UIColor.black
        self.label.textAlignment = .center
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.layer.masksToBounds = true
        self.label.font = label.font.withSize(15)
        self.label.isHidden = true
        
        
        
        newChatContainerView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: addButton.topAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: newChatContainerView.centerXAnchor).isActive = true
        
        
        label.widthAnchor.constraint(equalTo: newChatContainerView.widthAnchor, multiplier: 1/2).isActive = true
        
        label.heightAnchor.constraint(equalTo: emailTextField.heightAnchor).isActive = true
        self.view.addSubview(self.friendAddedView)
        
        friendAddedView.topAnchor.constraint(equalTo: self.newChatContainerView.topAnchor).isActive = true
        friendAddedView.leftAnchor.constraint(equalTo: self.newChatContainerView.leftAnchor).isActive = true
        friendAddedView.rightAnchor.constraint(equalTo: self.newChatContainerView.rightAnchor).isActive = true
        friendAddedView.bottomAnchor.constraint(equalTo: self.newChatContainerView.bottomAnchor).isActive = true
        friendAddedView.widthAnchor.constraint(equalTo: self.newChatContainerView.widthAnchor).isActive = true
        friendAddedView.heightAnchor.constraint(equalTo: self.newChatContainerView.heightAnchor).isActive = true
        friendAddedView.isHidden = true
        
        
        friendAddedView.addSubview(friendAddedMessage)
        
        
        
        friendAddedMessage.centerXAnchor.constraint(equalTo: self.friendAddedView.centerXAnchor).isActive = true
        
        friendAddedMessage.centerYAnchor.constraint(equalTo: self.friendAddedView.centerYAnchor).isActive = true
        
        
        friendAddedMessage.widthAnchor.constraint(equalTo: friendAddedView.widthAnchor, multiplier: 0.8).isActive = true
        
        friendAddedMessage.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        
        
        
        
    }
    
    
    
    
    
    
    @objc func addFriend() {
        
        if (!isInternetConnected) {
            
            return
        }
        
        
        if let email = emailTextField.text {
            
            
            Auth.auth().fetchProviders(forEmail: email, completion: { (stringArray, error) in
                if error != nil {
                    print(error!)
                    self.label.isHidden = false
                    Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.displayInvalidEmailMessage), userInfo: nil, repeats: false)
                } else {
                    if stringArray == nil {
                        
                        self.label.isHidden = false
                        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.displayInvalidEmailMessage), userInfo: nil, repeats: false)
                        
                        
                        
                        
                    } else {
                        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
                            
                            
                            
                            
                            let dictionary = snapshot.value as? [String:AnyObject]
                            let friendId = snapshot.key
                            
                            
                            
                            let userEmail = dictionary!["email"] as? String
                            
                            
                            
                            if (email == userEmail!) {
                                
                                let uid = Auth.auth().currentUser?.uid
                                Database.database().reference().child("users").child(uid!).child("friends").observe(.value, with: { (snapshot) in
                                    
                                    
                                    
                                    if (snapshot.hasChild(friendId)) {
                                        self.label.isHidden = false
                                        
                                        
                                        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.displayInvalidEmailMessage), userInfo: nil, repeats: false)
                                        
                                        
                                    } else {
                                        
                                        let friendsRef = Database.database().reference().child("users").child(uid!).child("friends")
                                        
                                        friendsRef.updateChildValues([friendId : 1])
                                        
                                        
                                        
                                        self.friendAddedView.isHidden = false
                                        
                                        let gradientLayer = CAGradientLayer()
                                        let startingColorGradient = UIColor(red: 255/255, green: 195/255, blue: 113/255, alpha: 1).cgColor
                                        let endingColorGradient = UIColor(red: 255/255, green: 95/255, blue: 109/255, alpha: 1).cgColor
                                        gradientLayer.frame = self.friendAddedView.bounds
                                        gradientLayer.colors = [startingColorGradient,endingColorGradient]
                                        self.friendAddedView.layer.insertSublayer(gradientLayer, at: 0)
                                        
                                        
                                        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.displaySuccessMessage), userInfo: nil, repeats: false)
                                        
                                    }
                                    
                                    
                                    
                                })
                                
                            }
                            
                            
                            
                            
                        }, withCancel: nil)
                        
                    }
                }
            })
            
            
        }
        
    }
    
    
    
    
    @objc func displayInvalidEmailMessage() {
        
        self.label.isHidden = true
        
        
    }
    
    
    
    
    @objc func displaySuccessMessage() {
        self.friendAddedView.isHidden = true
        self.newChatContainerView.removeFromSuperview()
        self.emailTextField.text = ""
        
    }
    
    
    @objc func dismissAddFriend() {
        
        newChatContainerView.removeFromSuperview()
        
    }
    
    
    @objc func dismissController() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageUrl {            
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.dismiss(animated: true) {
            print("Dismiss completed")
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user)
            
        }
    }
    
}








