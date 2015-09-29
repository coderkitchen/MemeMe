//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Scott Nelson on 9/17/15.
//  Copyright © 2015 Scott Nelson. All rights reserved.
//

import Foundation
import UIKit

class MemeCollectionViewController: UICollectionViewController {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    override func viewWillAppear(animated: Bool) {
        collectionView!.reloadData()
        tabBarController?.tabBar.hidden = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateLayout", name: UIDeviceOrientationDidChangeNotification, object: nil)
        //update layout here in case orientation has changed since view was loaded
        updateLayout()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func updateLayout() {
        let minWidth:CGFloat = 120
        let itemCount = Int(self.view.frame.size.width/minWidth)
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2*space)) / CGFloat(itemCount)
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        cell.photoDisplay?.image = memes[indexPath.row].image
        cell.topText?.attributedText = getAttributedString(memes[indexPath.row].topText)
        cell.bottomText?.attributedText = getAttributedString(memes[indexPath.row].bottomText)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let memeController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        memeController.memeIndex = indexPath.row
        navigationController!.pushViewController(memeController, animated: true)
    }
    
    @IBAction func createNewMeme(sender: UIBarButtonItem) {
        let editMemeController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditViewController") as! MemeEditViewController
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