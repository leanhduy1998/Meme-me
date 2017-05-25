//
//  ViewController.swift
//  Meme Me
//
//  Created by Duy Le on 5/16/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var memeIV: UIImageView!
    @IBOutlet weak var topTV: UITextField!
    @IBOutlet weak var bottomTV: UITextField!
    @IBOutlet weak var toolBarStackView: UIStackView!
    @IBOutlet weak var pictureStackView: UIStackView!
    
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var discardBtn: UIButton!
    var meme:Meme!
    
    
    
    
    struct Meme{
        var topText: String!
        var bottomText: String!
        var originalImage: UIImage!
        var memedImage: UIImage!
    }

    override func viewWillAppear(_ animated: Bool) {
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -5.0]
        topTV.defaultTextAttributes = memeTextAttributes
        bottomTV.defaultTextAttributes = memeTextAttributes
        topTV.delegate = self
        bottomTV.delegate = self
        topTV.textAlignment = .center
        bottomTV.textAlignment = .center
        
        subscribeToKeyboardNotifications()
        
        shareBtn.isEnabled = false
        discardBtn.isEnabled = false
        pictureStackView.isHidden = false
        self.topTV.isEnabled = true
        self.bottomTV.isEnabled = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }

    @IBAction func takePictureBtnPressed(_ sender: Any) {
    }
    @IBAction func choosePictureBtnPressed(_ sender: Any) {
        let UIImagePicker = UIImagePickerController()
        UIImagePicker.delegate = self
        self.present(UIImagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        save()
        let image = meme.memedImage
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
    @IBAction func discardBtnPressed(_ sender: Any) {
        pictureStackView.isHidden = false
        shareBtn.isEnabled = false
        discardBtn.isEnabled = false
        memeIV.image=nil
        topTV.text = ""
        bottomTV.text = ""
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            memeIV.image = image
            dismiss(animated: true, completion: {
                self.shareBtn.isEnabled = true
                self.discardBtn.isEnabled = true
                self.pictureStackView.isHidden = true
            })
            
        }
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        topTV.resignFirstResponder()
        bottomTV.resignFirstResponder()
        return true
    }
    func keyboardWillShow(_ notification:Notification) {
        if bottomTV.isEditing {
            view.frame.origin.y -=  getKeyboardHeight(notification)
        }
    }
    func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardDidHide, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    func save() {
        // Create the meme
        meme = Meme(topText: topTV.text, bottomText: bottomTV.text!, originalImage: memeIV.image!, memedImage: generateMemedImage())
    }
    func generateMemedImage() -> UIImage {
        
        self.navigationController?.isNavigationBarHidden = true
        toolBarStackView.isHidden = true
        pictureStackView.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.navigationController?.isNavigationBarHidden = false
        toolBarStackView.isHidden = false
        pictureStackView.isHidden = false
        
        
        return memedImage
    }


}

