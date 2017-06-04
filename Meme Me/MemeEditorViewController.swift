//
//  ViewController.swift
//  Meme Me
//
//  Created by Duy Le on 5/16/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController {
    @IBOutlet weak var memeIV: UIImageView!
    @IBOutlet weak var topTF: UITextField!
    @IBOutlet weak var bottomTF: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var discardBtn: UIBarButtonItem!
    @IBOutlet weak var takePicBtn: UIBarButtonItem!

    override func viewWillAppear(_ animated: Bool) {
        configure(topTF, defaultText: "Top text placeholder")
        configure(bottomTF, defaultText: "Botton text placeholder")
        
        subscribeToKeyboardNotifications()
        
        shareBtn.isEnabled = false
        discardBtn.isEnabled = false
        
        takePicBtn.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        super.viewWillAppear(animated)
    }
    
    
    
    func configure(_ textField: UITextField, defaultText: String) {
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -5.0]
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self
        textField.textAlignment = .center
        textField.text = defaultText
        textField.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    @IBAction func choosePictureBtnPressed(_ sender: Any) {
        showImagePickerVC(source: "photo library")
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler = { (activity, completed, items, error) in
            
            if (completed) {
                
                print("")
                print("In MemeEditorViewController -> shareMeme() -> returning from successful \"sharing\"...")
                
                self.save()
                
            }
            else {
                
                print("")
                print("In MemeEditorViewController -> shareMeme() -> returning from cancelled \"sharing\"...")
                
            }
            
        }
    }
    @IBAction func discardBtnPressed(_ sender: Any) {
        shareBtn.isEnabled = false
        discardBtn.isEnabled = false
        memeIV.image=nil
        topTF.text = ""
        bottomTF.text = ""
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            memeIV.image = image
            dismiss(animated: true, completion: {
                self.shareBtn.isEnabled = true
                self.discardBtn.isEnabled = true
            })
            
        }
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        topTF.resignFirstResponder()
        bottomTF.resignFirstResponder()
        return true
    }
    func keyboardWillShow(_ notification:Notification) {
        if bottomTF.isEditing {
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
    
    func save () {
        // Create the meme
        let meme = Meme(topText: topTF.text, bottomText: bottomTF.text!, originalImage: memeIV.image!, memedImage: generateMemedImage())
        
    }
    
    func generateMemedImage() -> UIImage {
        
        self.navigationController?.isNavigationBarHidden = true
        hideToolbars(boo: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.navigationController?.isNavigationBarHidden = false
        hideToolbars(boo: false)
        
        return memedImage
    }
    func hideToolbars(boo: Bool){
        topToolbar.isHidden = boo
        bottomToolbar.isHidden = boo
    }
    func showImagePickerVC(source:String){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if(source == "camera"){
            imagePicker.sourceType = .camera
        }
        else {
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func takePicBtnPressed(_ sender: Any) {
        showImagePickerVC(source: "camera")
    }

}
extension MemeEditorViewController: UIImagePickerControllerDelegate {
    
}
extension MemeEditorViewController: UINavigationControllerDelegate {
    
}
extension MemeEditorViewController: UITextFieldDelegate {
    
}

