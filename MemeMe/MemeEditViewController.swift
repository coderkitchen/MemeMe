//
//  MemeEditViewController.swift
//  MemeMe
//
//  Created by Scott Nelson on 9/23/15.
//  Copyright © 2015 Scott Nelson. All rights reserved.
//

import UIKit
import AVFoundation

class MemeEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var photoDisplay: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var takePhotoButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var doneEditingButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!

    var memeIndex:Int!
    
    private var topTextVerticalConstraint: NSLayoutConstraint!
    private var bottomTextVerticalConstraint: NSLayoutConstraint!
    private var topTextWidthConstraint: NSLayoutConstraint!
    private var bottomTextWidthConstraint: NSLayoutConstraint!
    private var meme: Meme!
    
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField(topText)
        setupTextField(bottomText)
        //intialize text field vertical constraints and width for default meme screen
        initConstraints()
        
        if let memeIndex = memeIndex {
            meme = memes[memeIndex]
            topText.text = meme.topText
            bottomText.text = meme.bottomText
            photoDisplay.image = meme.image
            shareButton.enabled = true
        }
        else {
            //only allow "saving" a meme that already exists,
            //otherwise user must share the meme to get it to "sent memes"
            doneEditingButton.title = ""
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        //check if camera is available, and disable Camera (takePhoto) if not
        takePhotoButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        //add listeners for when device is rotated and when keyboard appears and disappears
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        //hide back button for edit screen
        navigationController?.navigationBar.hidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //if going into edit mode for an existing meme, need to wait for the UIImageView to layout before positioning text
        if let meme = meme {
            positionTextFields(meme.image)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //remove listeners
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        //restore navigation bar
        navigationController?.navigationBar.hidden = false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func getDefaultText(textField: UITextField) -> String {
        if (textField == topText) {
            return "TOP"
        }
        else if (textField == bottomText){
            return "BOTTOM"
        }
        return ""
    }
    
    func setupTextField(textField: UITextField) {
        //initialize text to default strings
        textField.text = getDefaultText(textField)
        //set meme text attributes
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "Impact", size: 40)!,
            NSStrokeWidthAttributeName : -3
        ]
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.Center
        //default keyboard to uppercase for all letters
        textField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        textField.delegate = self
    }
    
    func initConstraints() {
        topText.translatesAutoresizingMaskIntoConstraints = false
        bottomText.translatesAutoresizingMaskIntoConstraints = false
        
        //create the top/bottom margin constraints relative to UIImageView
        topTextVerticalConstraint = NSLayoutConstraint(item: topText, attribute: .Top, relatedBy: .Equal,
            toItem: photoDisplay, attribute: .Top, multiplier: 1.0, constant: 0)
        bottomTextVerticalConstraint = NSLayoutConstraint(item: bottomText, attribute: .Bottom, relatedBy: .Equal,
            toItem: photoDisplay, attribute: .Bottom, multiplier: 1.0, constant: 0)
        //create the width constraints for the text fields
        topTextWidthConstraint = NSLayoutConstraint(item: topText, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal,
            toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0)
        bottomTextWidthConstraint = NSLayoutConstraint(item: bottomText, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal,
            toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0)
        
        //set the constraint values to defaults for the meme default screen
        setConstraintsDefaults()
        
        NSLayoutConstraint.activateConstraints([topTextVerticalConstraint, bottomTextVerticalConstraint, topTextWidthConstraint, bottomTextWidthConstraint])
    }
    
    func setConstraintsDefaults() {
        //for the meme default screen, show text fields with a 10px top/bottom vertical margin
        //and a 20px right/left margin from the edge of the parent view
        updateConstraints(10, width: view.frame.size.width-40)
    }
    
    func updateConstraints(verticalOffset: CGFloat, width: CGFloat) {
        topTextVerticalConstraint.constant = verticalOffset
        bottomTextVerticalConstraint.constant = -verticalOffset
        topTextWidthConstraint.constant = width
        bottomTextWidthConstraint.constant = width
        //view.setNeedsLayout()
    }
    
    func positionTextFields(image: UIImage) {
        //get the size of the actual image after adjusted to AspectFit content view mode
        let rect = AVMakeRectWithAspectRatioInsideRect(image.size, photoDisplay.bounds)
        //find the vertical offset of the image in the imageview and pad by 10px
        let verticalOffset = ((photoDisplay.frame.height - rect.height)/2)+10
        //get the actual image width and add a 10px margin on both sides
        let width = rect.width-20
        //update constraints to position the text fields appropriately in the actual UIImage
        updateConstraints(verticalOffset, width: width)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoDisplay.image = photo
            positionTextFields(photo)
            //enable sharing and saving
            shareButton.enabled = true
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func takePhoto(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickPhoto(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func cancelMeme(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func doneEditing(sender: UIBarButtonItem) {
        saveMeme()
        updateSentMemes()
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        //generate meme to send and save in instance variable
        saveMeme()
        //share meme image using default activity view controller
        let shareItems:Array = [meme!.finalImage]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = {(activityType:String?, completed:Bool, items: [AnyObject]?, err:NSError?) -> Void in
            if completed {
                //if user does not cancel share action, then add to "sent memes" and exit edit mode
                self.updateSentMemes()
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    //TextField delegate methods
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == getDefaultText(textField)) {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "") {
            textField.text = getDefaultText(textField)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    //execute when UIDeviceOrientationDidChange notification is received
    func rotated() {
        if let image = photoDisplay.image {
            positionTextFields(image)
        }
        else {
            setConstraintsDefaults()
        }
    }
    
    //execute when UIKeyboardWillShow notification is received
    func keyboardWillShow(notification: NSNotification) {
        //shift meme view up only for bottomText
        if (bottomText.isFirstResponder()) {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    //funciton to executed when UIKeyboardWillHide notification is received
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    //get keyboard height from notification user info
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    //generate meme image with text
    func generateMeme() -> UIImage {
        //create context the size of the AspectFit UIImage
        let rect = AVMakeRectWithAspectRatioInsideRect(photoDisplay.image!.size, photoDisplay.bounds)
        UIGraphicsBeginImageContext(rect.size)
        
        //find offset of UIImage in UIImageView
        let verticalOffset = ((photoDisplay.frame.height - rect.height)/2)
        let horizontalOffset = ((photoDisplay.frame.width - rect.width)/2)
        
        //select section of view where UIImage is
        view.drawViewHierarchyInRect(CGRectMake(   -(photoDisplay.frame.origin.x+horizontalOffset),
            -(photoDisplay.frame.origin.y+verticalOffset),
            view.frame.width, view.frame.height),
            afterScreenUpdates: true)
        
        let meme : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return meme
    }
    
    func saveMeme() {
        //generate meme and save in instance variable
        view.endEditing(true)
        meme = Meme(topText: topText.text!, bottomText: bottomText.text!,
            image: photoDisplay.image!, finalImage: generateMeme())
    }
    
    func updateSentMemes() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let memeIndex = memeIndex {
            //update existing meme
            appDelegate.memes[memeIndex] = meme
        }
        else {
            //add new meme
            appDelegate.memes.append(meme)
        }
    }

}
