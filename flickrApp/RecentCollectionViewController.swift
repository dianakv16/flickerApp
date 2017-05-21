//
//  RecentCollectionViewController.swift
//  flickrApp
//
//  Created by Diana Karina Vainberg Gauna on 10/12/2016.
//  Copyright © 2016 Diana Karina Vainberg Gauna. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class RecentCollectionViewController: UICollectionViewController {
    
    
    
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBAction func refresh(_ sender: UIButton) {
        self.requestRecentPhotos()
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var photoSet = [PhotoInfo]()
    
    var photoMgr = PhotoManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        requestRecentPhotos()
    
            
    }
    
    
    
    func requestRecentPhotos(){
        self.photoSet.removeAll(keepingCapacity: false)
        self.photoMgr.photoSet.removeAll(keepingCapacity: false)
        self.photoMgr.requestRecentPhotos(type: "recent", text: "") {
            (data, success) in
            if success {
                DispatchQueue.main.async{
                    self.photoSet += data as! [PhotoInfo]
                    
                    self.collectionView?.reloadData()
                }
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

   
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if photoSet.count == 0{
            return 1
        }
        else {
            return photoSet.count
        }
        
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RecentCollectionViewCell
        cell.isUserInteractionEnabled = false
       if photoSet.count > 0{
            let img = photoSet[indexPath.row]
        
        
            photoMgr.requestImage(urlStr: img.url_m) {
                (data, success) in
                
                if success {
                    
                    DispatchQueue.main.async {
                        
                        if let img = data as? UIImage {
                            self.activityIndicator.stopAnimating()
                            
                            cell.imageView.image = img
                            
                            cell.isUserInteractionEnabled = true
                        }
                    }
                }
            }
        
        }else{
        
            activityIndicator.startAnimating()
        
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selection = self.collectionView?.indexPathsForSelectedItems!
        let item = photoSet[selection![0].row]
        let dest = segue.destination as! DetailViewController
        dest.item = item
        
    }
    
    

}



    

