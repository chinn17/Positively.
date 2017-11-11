//
//  SignUpViewController.swift
//  Positively
//
//  Created by Chintan Puri on 08/10/17.
//  Copyright © 2017 Chintan Puri. All rights reserved.
//



import UIKit

class SignUpViewController: UIViewController {
    
    let internet = Reachability()!
    var activityIndicatorView = UIActivityIndicatorView()
    var isInternetConnected = true
    let pdfTitle = "Privacy Policy"
    
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
        
        button.setTitle("Back", for: UIControlState())
        button.setImage(#imageLiteral(resourceName: "backbtn"), for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(displayP3Red: 255/255, green: 25/255, blue: 90/255, alpha: 1)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(dismissSignUpController), for: .touchUpInside)
        
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
    
    
    let tapToAddLabel : UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor.black
        label.text = "Tap To Add Image"
        let fontSize = label.font.pointSize;
        label.font = UIFont(name: "Futura", size: fontSize)
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        return label
        
        
    }()
    
    let accountCreatedView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let accountCreatedMessage : UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.adjustsFontSizeToFitWidth = true
        label.text = "Account Created Successfully"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        return label
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfInternetIsReachable()
        setupInternetChangedNotifier()
        
        self.privacyPolicy.isHidden = false
        view.backgroundColor = UIColor.white
        view.addSubview(backButton)
        view.addSubview(inputsContainerView)
        view.addSubview(registerButton)
        view.addSubview(profileImageView)
        view.addSubview(waitingLabel)
        view.addSubview(activityIndicatorView)
        
        setupAccountCreatedMessage()
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupWaitingForNetwork()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func setupWaitingForNetwork() {
        
        waitingLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        
        waitingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        self.waitingLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/2).isActive = true
        
        self.waitingLabel.heightAnchor.constraint(equalTo: self.registerButton.heightAnchor).isActive = true
        
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
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
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
    
    let passwordSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let passwordsDoNotMatchMessage : UILabel = {
        
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.text = "Passwords Do Not Match"
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        return label
        
    }()
    
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dp")
        imageView.layer.cornerRadius = 75
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(displayP3Red: 178/255, green: 57/255, blue: 67/255, alpha: 1)
        
        button.layer.cornerRadius = 16
        button.setTitle("Sign Up", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        
        return button
    }()
    
    
    let privacyPolicy : UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor.darkGray
        let fontSize = label.font.pointSize;
        label.font = UIFont(name: "Futura", size: fontSize)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        let underlineAttribute = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: "By clicking Sign Up, you agree to Positively's Privacy Policy", attributes: underlineAttribute)
        label.attributedText = underlineAttributedString
        
        return label
        
        
    }()
    
    
    
    func setupProfileImageView() {
        //need x, y, width, height constraints
        profileImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        self.profileImageView.addSubview(self.tapToAddLabel)
        tapToAddLabel.isHidden = false
        tapToAddLabel.centerXAnchor.constraint(equalTo: self.profileImageView.centerXAnchor).isActive = true
        tapToAddLabel.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor).isActive = true
        
        tapToAddLabel.widthAnchor.constraint(equalTo: self.profileImageView.widthAnchor, multiplier: 0.8).isActive = true
        tapToAddLabel.heightAnchor.constraint(equalTo: self.profileImageView.heightAnchor, multiplier: 1/2).isActive = true
        
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView() {
        backButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30).isActive = true
        backButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //        inputsContainerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -self.view.frame.size.height/10).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        inputsContainerView.addSubview(passwordSeparatorView)
        inputsContainerView.addSubview(confirmPasswordTextField)
        self.view.addSubview(passwordsDoNotMatchMessage)
        
        //        need x, y, width, height constraints
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        nameTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //        need x, y, width, height constraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameSeparatorView .bottomAnchor).isActive = true
        
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        
        emailTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailSeparatorView.bottomAnchor).isActive = true
        
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        passwordTextFieldHeightAnchor?.isActive = true
        
        passwordSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordSeparatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        passwordSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        confirmPasswordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        
        confirmPasswordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        confirmPasswordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4).isActive = true
        
        passwordsDoNotMatchMessage.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor).isActive = true
        passwordsDoNotMatchMessage.bottomAnchor.constraint(equalTo: registerButton.topAnchor, constant: -10).isActive = true
        passwordsDoNotMatchMessage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        passwordsDoNotMatchMessage.text = "Passwords Do Not Match"
        
        passwordsDoNotMatchMessage.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        passwordsDoNotMatchMessage.heightAnchor.constraint(equalTo: confirmPasswordTextField.heightAnchor, multiplier: 1/2).isActive = true
        passwordsDoNotMatchMessage.isHidden = true
        
        
        self.view.addSubview(privacyPolicy)
        privacyPolicy.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        privacyPolicy.topAnchor.constraint(equalTo: registerButton.bottomAnchor).isActive = true
        privacyPolicy.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        privacyPolicy.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyTapped))
        privacyPolicy.isUserInteractionEnabled = true
        privacyPolicy.addGestureRecognizer(tapGesture)
        
    }
    
    
    @objc func privacyPolicyTapped() {
        
        let url = Bundle.main.url(forResource: pdfTitle, withExtension: "pdf")
        
        let webView = UIWebView(frame: self.view.frame)
        let urlRequest = URLRequest(url: url!)
        webView.loadRequest(urlRequest as URLRequest)
        webView.scalesPageToFit = true
        let pdfVC = UIViewController()
        pdfVC.view.addSubview(webView)
        pdfVC.title = pdfTitle
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor(displayP3Red: 255/255, green: 25/255, blue: 90/255, alpha: 1)
        
        self.navigationController?.pushViewController(pdfVC, animated: true)
        
    }
    
    
    func setupLoginRegisterButton() {
        //need x, y, width, height constraints
        
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: passwordsDoNotMatchMessage.bottomAnchor, constant: 20).isActive = true
        registerButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    
    
    func setupAccountCreatedMessage() {
        self.view.addSubview(self.accountCreatedView)
        
        accountCreatedView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        accountCreatedView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        accountCreatedView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        accountCreatedView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        accountCreatedView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        accountCreatedView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        accountCreatedView.isHidden = true
        
        accountCreatedView.addSubview(accountCreatedMessage)
        
        accountCreatedMessage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        accountCreatedMessage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        accountCreatedMessage.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30).isActive = true
        
        
        accountCreatedMessage.widthAnchor.constraint(equalTo: accountCreatedView.widthAnchor, multiplier: 0.8).isActive = true
        
        accountCreatedMessage.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func dismissSignUpController() {
        self.profileImageView.isHidden = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}






