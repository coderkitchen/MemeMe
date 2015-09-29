//
//  MemeViewController.swift
//  MemeMe
//
//  Created by Scott Nelson on 9/23/15.
//  Copyright © 2015 Scott Nelson. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    @IBOutlet weak var memeDisplay: UIImageView!

    var memeIndex:Int!
    
    private var meme:Meme!
    private var editButton:UIBarButtonItem!
    private var deleteButton:UIBarButtonItem!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        
        //add navigation buttons
        editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "editMeme")
        deleteButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "deleteMeme")
        let spacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: self, action: nil)
        spacer.width = 25
        navigationItem.rightBarButtonItems = [editButton,spacer,deleteButton]
        
        //set image to generated meme image
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let memeIndex = memeIndex {
            meme = appDelegate.memes[memeIndex]
        }
        memeDisplay.image = meme.finalImage
    }
    
    func deleteMeme() {
        //when delete is pressed, ask user to confirm the delete
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this meme?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {(UIAlertAction) -> Void in
            //if confirm was pressed, remove the meme from shared sent memes
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let memeIndex = self.memeIndex {
                if (memeIndex < appDelegate.memes.count) {
                    appDelegate.memes.removeAtIndex(memeIndex)
                }
            }
            self.navigationController!.popViewControllerAnimated(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func editMeme() {
        let editMemeController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditViewController") as! MemeEditViewController
        editMemeController.memeIndex = memeIndex
        navigationController!.pushViewController(editMemeController, animated: true)
    }

}
