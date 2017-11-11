//
//  ChatLogController.swift
//  Positively
//
//  Created by Chintan Puri on 08/10/17.
//  Copyright © 2017 Chintan Puri. All rights reserved.
//


import UIKit
import Firebase
import MobileCoreServices
import AVFoundation
import Alamofire
import SwiftyJSON

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let internet = Reachability()!
    var isInternetConnected = true
    var existingMessages = [Message]()
    var activityIndicatorView = UIActivityIndicatorView()
    var chatPartner : String?
    
    var user: User? {
        didSet {
            observeMessages()
            setupNavigationBarWithUser()
        }
    }
    
    let profileImage = UIImageView()
    
    var messages = [Message]()
    
    var messageString : String! = "."
    var score : Double = 0
    var emojiImage : UIImage?
    
    func observeMessages() {
        
        
        if (isInternetConnected) {
            
            guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
                return
            }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
            userMessagesRef.observe(.childAdded, with: { (snapshot) in
                
                guard let messageId = snapshot.key as String? else {
                    return
                }
                
                if (messageId == "isTyping") {
                    return
                }
                
                let messagesRef = Database.database().reference().child("messages").child(messageId)
                messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    
                    guard let dictionary = snapshot.value as? [String: AnyObject] else {
                        return
                    }
                    
                    if let messageText = dictionary["text"] as? String {
                        self.messageString = self.messageString + " " + messageText
                    }
                    
                    
                    
                    self.messages.append(Message(dictionary: dictionary))
                    DispatchQueue.main.async(execute: {
                        
                        
                        self.collectionView?.reloadData()
                        
                        if self.messages.count > 0 {
                            
                            if let indexPath = IndexPath(item: self.messages.count - 1, section: 0) as IndexPath? {
                                self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
                            }
                        }
                        
                        
                    })
                    
                }, withCancel: nil)
                
            }, withCancel: nil)
        }
        else {
            
            self.messages = self.existingMessages
            
            DispatchQueue.main.async(execute: {
                
                self.collectionView?.reloadData()
                
                if self.messages.count > 0 {
                    
                    if let indexPath = IndexPath(item: self.messages.count - 1, section: 0) as IndexPath? {
                        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
                    }
                }
                
                
            })
        }
        
        
    }
    
    
    
    let cellId = "cellId"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        checkIfInternetIsReachable()
        setupInternetChangedNotifier()
        
        checkIfChatPartnerIsTyping()
        
        if (isInternetConnected) {
            self.fetchUser()
        }else {
            self.observeMessages()
            
        }
        
        let startingColorOfGradient = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
        let endingColorOFGradient = UIColor(red: 230/255, green: 233/255, blue: 236/255, alpha: 1.0).cgColor
        self.gradientLayer.colors = [startingColorOfGradient , endingColorOFGradient]
        let bgView = CurvedView.init(frame: (self.collectionView?.frame)!)
        
        self.gradientLayer.frame = bgView.bounds
        
        bgView.layer.insertSublayer(self.gradientLayer, at: 0)
        self.collectionView?.backgroundView = bgView
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .interactive
        
        setupKeyboardObservers()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.updateBackgroundGradient()
        
    }
    
    
    func checkIfInternetIsReachable() {
        
        internet.whenReachable = { _ in
            print("NOW CONNECTED :",self.isInternetConnected)
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
            
            print("UNREACHABLE")
            DispatchQueue.main.async {
                
                self.showNoConnMessage()
            }
        }
    }
    
    
    
    func showNoConnMessage() {
        isInternetConnected = false
        self.navigationItem.title = "Waiting for network..."
        
    }
    
    
    func dismissNoConnMessage(){
        if(!isInternetConnected) {
            self.navigationItem.title = "Connected"
        }else {
            self.navigationItem.title = "Loading..."
        }
        isInternetConnected = true
        
        
    }
    
    
    
    
    
    func fetchUser() {
        
        if (isInternetConnected){
            guard let ref = Database.database().reference().child("users").child(self.chatPartner!) as DatabaseReference? else {
                return
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let user = User(dictionary: dictionary)
                user.id = self.chatPartner!
                self.user = user
                //            self.navigationItem.titleView?.isHidden = true
                //            self.activityIndicatorView.stopAnimating()
                //
            }, withCancel: nil)
        }
        
    }
    
    
    func setupNavigationBarWithUser() {
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.isUserInteractionEnabled = true
        
        
        if let profileImageUrl = user?.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        
        containerView.addSubview(profileImageView)
        
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        
        
        
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.text = user?.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        
    }
    
    
    
    
    
    
    
    lazy var inputContainerView: ChatInputContainerView = {
        
        var height : Int
        
        //checking for iPhone X height
        
        if (UIScreen.main.nativeBounds.height == 2436) {
            height = 75
        }
        else {
            height = 50
        }
        
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height: height))
        
        chatInputContainerView.inputTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        chatInputContainerView.inputTextField.delegate = self
        
        //         chatInputContainerView.inputTextField.addTarget(self, action: #selector(textFieldEnded), for: .editingDidEnd)
        //
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()
    
    var textTimer: Timer?
    
    @objc func textFieldChanged() {
        
        if (!isInternetConnected) {
            return
        }
        
        let uid = Auth.auth().currentUser?.uid
        let chatPartnerId = self.chatPartner
        
        Database.database().reference().child("user-messages").child(chatPartnerId!).child(uid!).child("isTyping").setValue("true")
        
        
        
        textTimer?.invalidate()
        textTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(textFieldStopEditing), userInfo: nil, repeats: false)
        
        
    }
    
    @objc func textFieldStopEditing() {
        if (!isInternetConnected) {
            return
        }
        
        let uid = Auth.auth().currentUser?.uid
        let chatPartnerId = self.chatPartner
        
        Database.database().reference().child("user-messages").child(chatPartnerId!).child(uid!).child("isTyping").setValue("false")
        
        
        
    }
    
    
    
    func checkIfChatPartnerIsTyping() {
        
        if (!isInternetConnected) {
            return
        }
        
        
        let uid = Auth.auth().currentUser?.uid
        let chatPartnerId = self.chatPartner
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid!).child(chatPartnerId!)
        userMessagesRef.updateChildValues(["isTyping": "false"])
        
        let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(chatPartnerId!).child(uid!)
        recipientUserMessagesRef.updateChildValues(["isTyping": "false"])
        
        
        userMessagesRef.observe(.value, with: { (snapshot) in
            
            //used when a conversation is deleted
            if snapshot.value is NSNull {
                return
            }
            guard let dictionary = snapshot.value as! [String:AnyObject]? else {
                return
            }
            
            let isTypingString = dictionary["isTyping"] as? String
            
            
            
            if (isTypingString == nil) {
                userMessagesRef.updateChildValues(["isTyping":"false"])
                return
            }
            
            if (isTypingString == "true") {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "typing...", style: .plain, target: self, action: nil)
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGray
                
            }else {
                self.navigationItem.rightBarButtonItem = nil
                
            }
            
            
            
        }, withCancel: nil)
        
    }
    
    
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        handleImageSelectedForInfo(info as [String : AnyObject])
        
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    fileprivate func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        
        return nil
    }
    
    fileprivate func handleImageSelectedForInfo(_ info: [String: AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        
        
        if let selectedImage = selectedImageFromPicker {
            
            uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl, image: selectedImage)
            })
        }
    }
    
    fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            
            
            
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image:", error!)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
                
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardDidShow() throws  {
        
        if self.messages.count > 0 {
            
            if let indexPath = IndexPath(item: self.messages.count - 1, section: 0) as IndexPath? {
                
                if self.indexPathIsValid(indexPath: indexPath) {
                    
                    self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
                }
                
            }
        }
        
        
    }
    
    func indexPathIsValid(indexPath: IndexPath) -> Bool {
        return indexPath.section < (collectionView?.numberOfSections)! && indexPath.row < collectionView!.numberOfItems(inSection: indexPath.section)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        cell.backgroundColor = UIColor.clear
        let message = messages[indexPath.item]
        
        cell.message = message
        
        
        
        cell.textView.text = message.text
        
        setupCell(cell, message: message)
        
        if let text = message.text {
            //a text message
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            //fall in here if its an image message
            
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    
    
    
    
    fileprivate func setupCell(_ cell: ChatMessageCell, message: Message) {
        
        cell.textView.textColor = UIColor.black
        if message.fromId == Auth.auth().currentUser?.uid {
            //outgoing blue
            if (self.score < 0) {
                cell.bubbleView.backgroundColor = UIColor(r: 245, g: 245, b: 245)
                
            }else {
                
                cell.bubbleView.backgroundColor = UIColor(r: 245, g: 245, b: 245)
                
                
            }
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            //incoming gray
            
            if (self.score < 0) {
                cell.bubbleView.backgroundColor = UIColor(r: 245, g: 245, b: 245)
                
            }else {
                
                cell.bubbleView.backgroundColor = UIColor(r: 245, g: 245, b: 245)
                
                
            }
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    
    
    func updateBackgroundGradient() {
        if(!isInternetConnected) {
            return
        }
        
        Alamofire.request("https://api.havenondemand.com/1/api/async/analyzesentiment/v2",parameters: ["apikey":"25e7b93a-24f6-450b-a8a5-e3e8f373a84b","text":self.messageString]).responseJSON { (response) in
            
            
            
            guard let resultForJobId = response.result.value! as? [String:Any] else{
                print("Response for jobID returned nil")
                return
                
            }
            
            
            guard let jobID = resultForJobId["jobID"] as? String else {
                print("Error in jobID")
                return
            }
            
            
            Alamofire.request("https://api.havenondemand.com/1/job/result/"+jobID,parameters: ["apikey":"25e7b93a-24f6-450b-a8a5-e3e8f373a84b"]).responseJSON(completionHandler: { (response) in
                if let result = response.result.value {
                    
                    let json = JSON(result)
                    
                    self.score = json["actions"][0]["result"]["sentiment_analysis"][0]["aggregate"]["score"].doubleValue
                    
                    self.score = self.score * 100
                    
                    
                    
                    
                    var startingColorGradient = UIColor(displayP3Red: 253/255, green: 231/255, blue: 155/255, alpha: 1).cgColor
                    var endingColorGradient = UIColor(red: 255/255, green: 95/255, blue: 109/255, alpha: 1).cgColor
                    
                    if (self.score < 0) {
                        if (self.score < -75) {
                            
                            startingColorGradient = UIColor(red: 198/255, green: 66/255, blue: 110/255, alpha: 1).cgColor
                            endingColorGradient = UIColor(red: 100/255, green: 43/255, blue: 115/255, alpha: 1).cgColor
                            
                            self.gradientLayer.colors = [startingColorGradient,endingColorGradient]
                        } else if (self.score < -25) {
                            startingColorGradient = UIColor(red: 189/255, green: 63/255, blue: 50/255, alpha: 1).cgColor
                            endingColorGradient = UIColor(red: 203/255, green: 53/255, blue: 107/255, alpha: 1).cgColor
                            
                            self.gradientLayer.colors = [startingColorGradient,endingColorGradient]
                            
                        } else {
                            
                            startingColorGradient = UIColor(red: 255/255, green: 106/255, blue: 0/255, alpha: 1).cgColor
                            endingColorGradient = UIColor(red: 238/255, green: 9/255, blue: 121/255, alpha: 1).cgColor
                            
                            self.gradientLayer.colors = [startingColorGradient,endingColorGradient]
                            
                            
                        }
                        
                    } else {
                        if (self.score > 75){
                            startingColorGradient = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
                            endingColorGradient = UIColor(red: 236/255, green: 233/255, blue: 230/255, alpha: 1).cgColor
                            self.gradientLayer.colors = [startingColorGradient,endingColorGradient]
                            
                        } else if self.score > 25 {
                            
                            
                            self.gradientLayer.colors = [startingColorGradient,endingColorGradient]
                            
                        } else {
                            
                            startingColorGradient = UIColor(red: 249/255, green: 212/255, blue: 35/255, alpha: 1).cgColor
                            endingColorGradient = UIColor(red: 255/255, green: 78/255, blue: 80/255, alpha: 1).cgColor
                            
                            self.gradientLayer.colors = [startingColorGradient,endingColorGradient]
                            
                            
                        }
                    }
                    
                }
                
            })
            
        }
    }
    
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            // h1 / w1 = h2 / w2
            // solve for h1
            // h1 = h2 / w2 * w1
            
            height = CGFloat(imageHeight / imageWidth * 200)
            
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    @objc func handleSend() {
        
        let messageText = inputContainerView.inputTextField.text!
        
        if(isInternetConnected == false || messageText.isEmpty || messageText.trimmingCharacters(in: .whitespaces).isEmpty) {
            return
        }
        
        if (messageText.isSingleEmoji) {
            self.emojiImage = messageText.image()
            sendEmoji()
        }
        
        let properties = ["text": messageText]
        self.updateBackgroundGradient()
        sendMessageWithProperties(properties as [String : AnyObject])
        
        
    }
    
    fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
        
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        sendMessageWithProperties(properties)
    }
    
    fileprivate func sendMessageWithProperties(_ properties: [String: AnyObject]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject]
        
        //append properties dictionary onto values somehow??
        //key $0, value $1
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
            
        }
    }
    
    
    
    
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                // math?
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                
            })
            
        }
    }
    
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
    
    fileprivate func sendEmoji() {
        (0...15).forEach { (_) in
            generateAnimatedViews()
        }
        
    }
    
    
    
    fileprivate func generateAnimatedViews() {
        let image = drand48() > 0.5 ? self.emojiImage! : self.emojiImage!
        let imageView = UIImageView(image: image)
        let dimension = 20 + drand48() * 10
        imageView.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        
        
        animation.path = customPath().cgPath
        animation.duration = 2 + drand48() * 3
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        imageView.layer.add(animation, forKey: nil)
        view.addSubview(imageView)
    }
    
}

func customPath() -> UIBezierPath {
    let path = UIBezierPath()
    
    path.move(to: CGPoint(x: 0, y: 200))
    
    let endPoint = CGPoint(x: 400, y: 200)
    
    let randomYShift = 200 + drand48() * 300
    let cp1 = CGPoint(x: 100, y: 100 - randomYShift)
    let cp2 = CGPoint(x: 200, y: 300 + randomYShift)
    
    path.addCurve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)
    return path
}


class CurvedView: UIView {
    
    override func draw(_ rect: CGRect) {
        //do some fancy curve drawing
        let path = customPath()
        path.lineWidth = 3
        path.stroke()
    }
    
}
