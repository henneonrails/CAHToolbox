//
//  CAHToolbox.swift
//
//  Created by Holger Haenisch on 04.10.15.
//  Copyright © 2015 Holger Hänisch. All rights reserved.
//

import Foundation
import UIKit

// NARK - string extension

extension String {
    /**
    Save a String to a file with given name to the local document directory
    
    - parameter fileName: File name as String free to choose
    - parameter content: The String to save in the documents directory
    */
    public func saveStringToFileInDocumentsDirectory(fileName : String, content : String) {
        let fileWithPath = getLocalDocumentPath()?.URLByAppendingPathComponent(fileName)
        var error : NSError? = nil
        if let file = fileWithPath {
            do {
                try content.writeToURL(file, atomically: true, encoding: NSUTF8StringEncoding)
            } catch let error1 as NSError {
                error = error1
                print(error)
            }
        }
        if (error != nil) {
            print("error saving file in documents directory: \(error?.localizedDescription))")
        }
    }
    
    private func getLocalDocumentPath() -> NSURL? {
        let documentDirectory : AnyObject? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
        return NSURL(fileURLWithPath: documentDirectory as! String)
    }
    
}


// MARK - alert helper
/**
*Alert Helper*
show a simple alert view with one OK button to dissmiss

- parameter title: The title of the alert
- parameter message: The content of the alert
- parameter viewController: Where to show the alert
*/
public func showSimpleAlertWithTitle(title: String!, message: String, viewController: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
    alert.addAction(action)
    viewController.presentViewController(alert, animated: true, completion: nil)
}

// MARK - sharing menu helper
/**
*Sharing Menu Helper*
simple approach to get sharing working. Simply call it from a bar button e.g. 

- parameter sharingText: if you want to share a simple String
- parameter sharingHTML: if you hava a String with HTML content it will be formatted for iOS
- parameter sharingImage: if you want to share a UIImage
- parameter sharingURL: if you want to share a NSURL
- parameter barButton: on iPad you have to provide a UIBarButton as anchor for the popover view
*/

public func shareTextImageAndURL(sharingText sharingText: String?,sharingHTML: String?, sharingImage: UIImage?, sharingURL: NSURL?, barButton: UIBarButtonItem?, viewController: UIViewController) {
    var sharingItems = [AnyObject]()
    
    if let text = sharingText {
        sharingItems.append(text)
    }
    if var html = sharingHTML {
        html = "<html><body>"+html+"</body></html>"
        sharingItems.append(html)
    }
    if let image = sharingImage {
        sharingItems.append(image)
    }
    if let url = sharingURL {
        sharingItems.append(url)
    }
    
    let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
    
    if let button = barButton {
        activityViewController.popoverPresentationController?.barButtonItem = button
    }
    viewController.presentViewController(activityViewController, animated: true, completion: nil)
    //self.presentViewController(activityViewController, animated: true, completion: nil)
}
