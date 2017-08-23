//
//  ViewController.swift
//  Instagram Clone
//
//  Created by Abdullah A Mamun on 7/14/17.
//  Copyright © 2017 Abdullah A Mamun. All rights reserved.
//

import UIKit
import Firebase



class SignupVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let plusButton:UIButton = {
        var bt = UIButton(type:.system)
        bt.setImage(UIImage(named:"plus_photo"), for: .normal)
        bt.addTarget(self, action: #selector(handlePhoto), for: .touchUpInside)
        return bt
    }()
    func handlePhoto()  {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
           plusButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
           plusButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        plusButton.layer.cornerRadius = plusButton.frame.width/2
        plusButton.layer.masksToBounds = true
        //
        dismiss(animated: true, completion: nil)
    }
    
    
         //for saving user selection into selected
         var  selectedCommunity : String?
    
    // creating an array for uipickerview
    let communities = ["Bangladeshi","Indian","Chinese","Pakistani","Japanese"]

    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter valid Email"
        
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputchange), for: .editingChanged)
        return tf
    }()
    func handleTextInputchange()  {
        let isFormValid = (emailTextField.text?.isValidEmail())! && passwordTextField.text?.characters.count ?? 0 >= 6 && userNameTextField.text?.characters.count ?? 0 > 0 && selectedCommunity?.characters.count ?? 0 > 0
        
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        }
        else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    let userNameTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputchange), for: .editingChanged)
        return tf
    }()
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter password 6 characters long"
        tf.isSecureTextEntry = true
        
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputchange), for: .editingChanged)
        return tf
    }()
    let signUpButton:UIButton = {
        let bt  = UIButton(type: .system)
        bt.setTitle("Sign Up", for: .normal)
        bt.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        bt.layer.cornerRadius = 5
        bt.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        bt.setTitleColor(.white, for: .normal)
        bt.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        bt.isEnabled = false
        return bt
        
    }()
    
    
   
    
    
    let picker:UIPickerView = {
      let pv = UIPickerView()
        pv.backgroundColor =  UIColor.white
        return pv
    }()
    
    
    let communitySelector:UITextField = {
         let ct = UITextField()
        ct.placeholder = "Choose Your Community"
        ct.backgroundColor = UIColor(white: 0, alpha: 0.03)
        ct.borderStyle = .roundedRect
        ct.font = UIFont.systemFont(ofSize: 14)
        ct.addTarget(self, action: #selector(handleTextInputchange), for: .editingChanged)
        return ct
    }()
        
    //function to create a toolbar to dismiss pickerView
    func createToolbar()  {
        let toolbar = UIToolbar()
        toolbar.barTintColor = .white
        //change the color of the text
        // toolbar.tintColor = .green
        toolbar.sizeToFit()
        let doneBt = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector( dismissKeyboard))
        toolbar.setItems([doneBt], animated: false)
        // to determine whether the vc should ignore the touch of user,true means not to ignore
        toolbar.isUserInteractionEnabled = true
        communitySelector.inputAccessoryView = toolbar
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(plusButton)
        plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        plusButton.anchor(top: view.topAnchor, paddingTop: 40, left: nil, paddingLeft: 0, right: nil, paddingRight: 0, bottom: nil, paddingBottom: 0, width: 140, height: 140)
        picker.dataSource = self
        picker.delegate = self
        communitySelector.inputView = picker
        createToolbar()
        setupInputFields()
    }
    
   
    
    func handleSignUp()  {
        guard let email = emailTextField.text, email.characters.count > 0
            else { return}
        guard let userName = userNameTextField.text,userName.characters.count>0 else { return}
        guard let password = passwordTextField.text,password.characters.count>0  else { return}
        guard let community = communitySelector.text,community.characters.count>0  else { return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print("Failed to create user",err)
            }
            print("Successfully created user" ,user?.uid ?? "")
            //to save user's picture
            //NS
            let fileName = NSUUID().uuidString // create a unique string that identifies types,items etc.
            guard let image = self.plusButton.imageView?.image else {return}
            guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else {return}
            Storage.storage().reference().child("Profile_images").child(fileName).putData(uploadData, metadata: nil, completion: { (metaData, err) in
                if let err = err {
                  print("Failed to upload profile image",err)
                }
                guard let profileImageUrl = metaData?.downloadURL()?.absoluteString else {return}
                
                print("Successfully uploaded profile image",profileImageUrl)
                //to save user's info
                guard let uid = user?.uid else{return}
                let dictionaryValues = ["username":userName,"community":community,"ProfileImage":profileImageUrl]
                let values = [uid:dictionaryValues]
            
                Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if let err = err {
                     print("Failed to create user info",err)
                    }
                    print("Successfully created user's info")
                })
            })
            
        }
    }
    
    
    
    fileprivate func setupInputFields()  {
        let stackView = UIStackView(arrangedSubviews: [emailTextField,userNameTextField,communitySelector,passwordTextField,signUpButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)
        stackView.anchor(top: plusButton.bottomAnchor, paddingTop: 20, left: view.leftAnchor, paddingLeft: 40, right: view.rightAnchor, paddingRight: -40, bottom: nil, paddingBottom: 0, width: 0, height: 200)
        
    }
    
    
}



extension SignupVC: UIPickerViewDelegate,UIPickerViewDataSource {
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return  communities.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return communities[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
           selectedCommunity = communities[row]
           communitySelector.text = selectedCommunity
        
    }
}


extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: characters.count)) != nil
    }
}






