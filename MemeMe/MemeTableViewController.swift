//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Scott Nelson on 9/17/15.
//  Copyright © 2015 Scott Nelson. All rights reserved.
//

import Foundation
import UIKit

class MemeTableViewController: UITableViewController {
    
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }

    override func viewWillAppear(animated: Bool) {
        tableView!.reloadData()
        tabBarController?.tabBar.hidden = false
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableViewCell", forIndexPath: indexPath) as! MemeTableViewCell
        cell.photoDisplay.image = memes[indexPath.row].image
        cell.topText.attributedText = getAttributedString(memes[indexPath.row].topText)
        cell.bottomText.attributedText = getAttributedString(memes[indexPath.row].bottomText)
        cell.memeText.text = memes[indexPath.row].topText+"..."+memes[indexPath.row].bottomText
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let memeController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        memeController.memeIndex = indexPath.row
        navigationController!.pushViewController(memeController, animated: true)
    }
    
    @IBAction func createNewMeme(sender: UIBarButtonItem) {
        let editMemeController = storyboard!.instantiateViewControllerWithIdentifier("MemeEditViewController") as! MemeEditViewController
        navigationController!.pushViewController(editMemeController, animated: true)
    }
    
    func getAttributedString(text: String) -> NSAttributedString {
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "Impact", size: 12)!,
            NSStrokeWidthAttributeName : -3
        ]
        return NSAttributedString(string: text, attributes: memeTextAttributes)
    }
}