//
//  LoginController.swift
//  Positively
//
//  Created by Chintan Puri on 08/10/17.
//  Copyright © 2017 Chintan Puri. All rights reserved.
//


import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

class LoginController: UIViewController{
    
    let internet = Reachability()!
    var isInternetConnected = true
    var activityIndicatorView = UIActivityIndicatorView()
    let waitingLabel : UILabel = {
        let label = UILabel()
        label.text = "Waiting for network..."
        label.isHidden = true
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        return label
        
    }()
    
    let backButton : UIButton = {
        
        
        let button = UIButton()
        
        button.setTitle("", for: UIControlState())
        button.setImage(#imageLiteral(resourceName: "backbtn"), for: UIControlState())
        button.tintColor = UIColor(displayP3Red: 255/255, green: 25/255, blue: 90/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.black, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(dismissLoginController), for: .touchUpInside)
        
        return button
        
    }()
    
    var messagesController: MessagesController?
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(displayP3Red: 178/255, green: 57/255, blue: 67/255, alpha: 1)
        button.layer.cornerRadius = 16
        button.setTitle("Login", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return button
    }()
    
    lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.layer.cornerRadius = 16
        button.setTitle("Forgot Password ?", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.black, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        button.addTarget(self, action: #selector(showForgotPasswordController), for: .touchUpInside)
        
        return button
    }()
    
    
    
    
    
    
    @objc func handleLogin() {
        if (!isInternetConnected) {
            return
        }
        
        let token : [String : AnyObject] = [Messaging.messaging().fcmToken! : Messaging.messaging().fcmToken as AnyObject]
        
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print(error ?? "")
                self.invalidUsernamePasswordMessage.isHidden = false
                Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.displayInvalidEmailMessage), userInfo: nil, repeats: false)
                return
            }
            
            //successfully logged in our user
            
            let userId = Auth.auth().currentUser?.uid
            
            if Messaging.messaging().fcmToken != nil {
                Messaging.messaging().subscribe(toTopic: userId! )
            }
            
            //posting token
            self.postToken(Token: token)
            
            let mc = MessagesController()
            let navController = UINavigationController(rootViewController: mc)
            self.present(navController, animated: true, completion: nil)
            
        })
        
    }
    
    
    func postToken(Token:[String:AnyObject]) {
        print ("FCM Token :", Token)
        let ref = Database.database().reference()
        ref.child("fcmToken").child(Messaging.messaging().fcmToken!).setValue(Token)
        
    }
    
    
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let invalidUsernamePasswordMessage = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfInternetIsReachable()
        setupInternetChangedNotifier()
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginButton)
        view.addSubview(backButton)
        view.addSubview(waitingLabel)
        view.addSubview(activityIndicatorView)
        
        setupInputsContainerView()
        setupLoginButton()
        setupWaitingForNetwork()
    }
    
    func setupWaitingForNetwork() {
        
        waitingLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        
        waitingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        self.waitingLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/2).isActive = true
        
        self.waitingLabel.heightAnchor.constraint(equalTo: self.loginButton.heightAnchor).isActive = true
        
        self.activityIndicatorView.hidesWhenStopped = true
        
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.activityIndicatorView.center.x = self.view.center.x
        self.activityIndicatorView.center.y = 60
        
        
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
            DispatchQueue.main.async {
                self.dismissNoConnMessage()
            }
        }
        else {
            self.isInternetConnected = false
            DispatchQueue.main.async {
                self.showNoConnMessage()
            }
        }
    }
    
    
    
    func showNoConnMessage() {
        self.activityIndicatorView.startAnimating()
        self.waitingLabel.isHidden = false
    }
    
    
    func dismissNoConnMessage(){
        self.activityIndicatorView.stopAnimating()
        self.waitingLabel.isHidden = true
        
        
        
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView() {
        //need x, y, width, height constraints
        
        backButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30).isActive = true
        backButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        inputsContainerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.frame.size.height/5).isActive = true
        
        
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        
        emailTextFieldHeightAnchor?.isActive = true
        
        
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor,constant: 20).isActive = true
        
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        self.invalidUsernamePasswordMessage.text = "Incorrect Username or Password"
        self.invalidUsernamePasswordMessage.adjustsFontSizeToFitWidth = true
        self.invalidUsernamePasswordMessage.textColor = UIColor.black
        self.invalidUsernamePasswordMessage.textAlignment = .center
        self.invalidUsernamePasswordMessage.translatesAutoresizingMaskIntoConstraints = false
        self.invalidUsernamePasswordMessage.layer.masksToBounds = true
        self.invalidUsernamePasswordMessage.font = invalidUsernamePasswordMessage.font.withSize(15)
        self.invalidUsernamePasswordMessage.isHidden = true
        
        
        
        self.view.addSubview(invalidUsernamePasswordMessage)
        
        invalidUsernamePasswordMessage.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        invalidUsernamePasswordMessage.bottomAnchor.constraint(equalTo: loginButton.topAnchor).isActive = true
        
        invalidUsernamePasswordMessage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        
        invalidUsernamePasswordMessage.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/2).isActive = true
        
        invalidUsernamePasswordMessage.heightAnchor.constraint(equalTo: self.passwordTextField.heightAnchor).isActive = true
        
        
    }
    
    
    @objc func showForgotPasswordController() {
        let forgotPasswordVC = ForgotPasswordController()
        self.present(forgotPasswordVC, animated: true, completion: nil)
        
    }
    
    func setupLoginButton() {
        //need x, y, width, height constraints
        
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.view.addSubview(self.forgotPasswordButton)
        
        forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12).isActive = true
        forgotPasswordButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        forgotPasswordButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        
    }
    
    @objc func displayInvalidEmailMessage() {
        self.invalidUsernamePasswordMessage.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func dismissLoginController() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}








