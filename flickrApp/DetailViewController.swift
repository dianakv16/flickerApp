//
//  DetailViewController.swift
//  flickrApp
//
//  Created by Diana Karina Vainberg Gauna on 12/12/2016.
//  Copyright © 2016 Diana Karina Vainberg Gauna. All rights reserved.
//

import UIKit
import Social

class DetailViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    var item: PhotoInfo!
    var photoMgr = PhotoManager()
    
    
    @IBOutlet weak var titleImage: UITextView!
    
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var tagsText: UITextView!
    
    @IBOutlet weak var descText: UITextView!
    
    @IBOutlet weak var share: UIButton!
    
    @IBAction func shareSheet(_ sender: UIButton) {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            let message = "Look at this picture I found"
            let image = self.detailImage.image
            let sheet = UIActivityViewController(activityItems: [message, image], applicationActivities: nil)
            self.present(sheet, animated: true, completion: nil)
        
        case .pad:
            self.share.isHidden = true
            
        default:
            break
            
        }
        
    }
    
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        self.navigationItem.title = "Photo"
        self.titleImage.text = item.title
        self.descText.text = item.description
        self.tagsText.text = item.tags
        
        //The ipad gave an error when the user clicks on Share, so I decided 
        //to hide it until I find a better solution
        switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                self.share.isHidden = true
            default:
                break
        }

        
        func resolveHashTags(){
            let nsText:NSString = self.tagsText.text as NSString
            let textRange = NSMakeRange(0, nsText.length)
            
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.center
            
            //I set the attributes here, because the ones from the storyboard
            //are overwritten
            let attrs = [
                NSFontAttributeName : UIFont.systemFont(ofSize: 15.0),
                NSParagraphStyleAttributeName: paragraphStyle,
                ]
            let attrString = NSMutableAttributedString(string: self.tagsText.text, attributes: attrs)
            
            nsText.enumerateSubstrings(in: textRange, options: .byWords, using: {
                (substring, mainRange, substringRange, _) in
                
                
                if let sub = substring {
                    attrString.addAttribute(NSLinkAttributeName, value: "tag:\(sub)", range: mainRange)
                    
                    
                }
            })
            
            
            self.tagsText.attributedText = attrString
            self.tagsText.delegate = self
        }
        
        resolveHashTags()
        
        photoMgr.requestImage(urlStr: item.url_m) {
            (data, success) in
            
            if success {
                DispatchQueue.main.async {
                    if let img = data as? UIImage {
                        self.detailImage.image = img
                    }
                }
                
            }
            
        }
        
        
    }
    //This is to show the first line of each textview first
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tagsText.setContentOffset(CGPoint.zero, animated: false)
        titleImage.setContentOffset(CGPoint.zero, animated: false)
        descText.setContentOffset(CGPoint.zero, animated: false)
    }
    
    
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool{
       
        let searchViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        //This is to get the tag word only
        let commaSeparatedArray = URL.absoluteString.characters.split { $0 == ":" }
        let tag = commaSeparatedArray.map(String.init)[1]
        searchViewController.searchField.text = tag
        let bool = searchViewController.textFieldShouldReturn(searchViewController.searchField)
        if bool {
            print("The word was sent to the search view")
        }
        self.navigationController?.pushViewController(searchViewController, animated: true)
        
        return false
    }
    
}
