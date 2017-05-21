//
//  SearchViewController.swift
//  flickrApp
//
//  Created by Diana Karina Vainberg Gauna on 10/12/2016.
//  Copyright © 2016 Diana Karina Vainberg Gauna. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SearchViewController: UICollectionViewController, UITextFieldDelegate{

    
    @IBOutlet weak var searchField: UITextField!
    

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func search(_ sender: UITextField) {
        guard self.searchField.text != nil else {
            return
        }
        
        
    }
    
    
    @IBAction func editingEnd(_ sender: UITextField) {
        guard self.searchField.text != nil else {
            return
        }
    
        
    }
    
    
    var photoSet = [PhotoInfo]()
    
    var photoMgr = PhotoManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate = self
        guard self.searchField.text != nil else {
            return
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    

   
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoSet.count
        
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SearchViewCell
        cell.isUserInteractionEnabled = false
        if (self.searchField.text != ""){
          
            if photoSet.count > 0{
               
               let img = photoSet[indexPath.row]
                photoMgr.requestImage(urlStr: img.url_m) {
                    (data, success) in
                    
                    if success {
                        DispatchQueue.main.async {
                            if let img = data as? UIImage {
                                self.activityIndicator.stopAnimating()
                                cell.imageView.image = nil
                                cell.imageView.image = img
                                
                                cell.isUserInteractionEnabled = true
                            }
                        }
                    }
                }
                
            }else{
             self.activityIndicator.startAnimating()
                
                cell.imageView.image = nil
              
                cell.isUserInteractionEnabled = false
            }
        } else {
            let alert = UIAlertController(title: "Search", message: "Please enter a word to search in flickr", preferredStyle: .alert)
            let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okBtn)
            self.present(alert, animated: true, completion: nil)
        }
        return cell
    }
   
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selection = self.collectionView?.indexPathsForSelectedItems!
        if (photoSet.count > 0){
            let item = photoSet[selection![0].row]
            let dest = segue.destination as! DetailViewController
            dest.item = item
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        guard let text = self.searchField.text else {
            print("No text was found in the text field")
            return false
        }
        //This is for when the user searches for several words with spaces
        let dataUser = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        
        self.photoSet.removeAll(keepingCapacity: false)
        self.photoMgr.photoSet.removeAll(keepingCapacity: false)
        self.photoMgr.requestRecentPhotos(type: "search", text: dataUser!) {
            (data, success) in
            if success {
                DispatchQueue.main.async{
                    self.photoSet += data as! [PhotoInfo]
                    
                    self.activityIndicator.startAnimating()
                    self.collectionView?.reloadData()
                }
                
            }
            
        }
        
        self.collectionView?.reloadData()
        return true
    }

}



