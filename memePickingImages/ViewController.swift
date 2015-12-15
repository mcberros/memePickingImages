//
//  ViewController.swift
//  memePickingImages
//
//  Created by Carmen Berros on 27/11/15.
//  Copyright © 2015 mcberros. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {


    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottonText: UITextField!
    @IBOutlet weak var shareAction: UIBarButtonItem!

    private let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -4
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        topText.text = "TOP"
        topText.delegate = self
        topText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = .Center

        bottonText.text = "BOTTOM"
        bottonText.delegate = self
        bottonText.defaultTextAttributes = memeTextAttributes
        bottonText.textAlignment = .Center
    }

    override func viewWillAppear(animated: Bool) {
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)

        self.subscribeToKeyboardNotifications()
        shareAction.enabled = false
        UIApplication.sharedApplication().statusBarHidden=true;
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }

    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }


    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }


    @IBAction func startActivityView(sender: AnyObject) {
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.completionWithItemsHandler = saveMemeAfterSharing
        self.presentViewController(controller, animated: true, completion: nil)
    }

    private func saveMemeAfterSharing(activity: String?, completed: Bool, items: [AnyObject]?, err: NSError?) -> Void {
        if completed {
            self.save()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imagePickerView.image = image
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.shareAction.enabled = true
                });
            }
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: {});
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newText: NSString = textField.text!
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // Move view frame up
    func keyboardWillShow(notification: NSNotification) {
        if bottonText.isFirstResponder() && view.frame.origin.y == 0 {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    private func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

    private func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    private func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)

    }

    // Move view frame down
    func keyboardWillHide(notification: NSNotification) {
        if bottonText.isFirstResponder() {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }

    private func generateMemedImage() -> UIImage {

        // TODO: Hide toolbar and navbar
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // TODO:  Show toolbar and navbar
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        return memedImage
    }

    private func save() {
        //Create the meme
        _ = Meme(topText: topText.text!, bottonText: bottonText.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
    }
}

