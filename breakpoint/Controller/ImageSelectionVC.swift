//
//  ImageSelectionVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 15/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

class ImageSelectionVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var imageType: String? = "light"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        showAnimate()
    }
    @IBAction func closePressed(_ sender: Any) {
        removeAnimate()
    }
    
    @IBAction func imageTypeSelected(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            imageType = "light"
            collectionView.backgroundColor = #colorLiteral(red: 0.2549019608, green: 0.2705882353, blue: 0.3137254902, alpha: 1)
        case 1:
            imageType = "dark"
            collectionView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        default:
            break
        }
        collectionView.reloadData()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
}

extension ImageSelectionVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 28
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileImageCell", for: indexPath) as? ProfileImageCell else { return UICollectionViewCell()}
        if imageType == "light" {
            cell.configureCell(image: UIImage(named: "light\(indexPath.row)")!)
        }
        else if imageType == "dark" {
           cell.configureCell(image: UIImage(named: "dark\(indexPath.row)")!)
        }
        return cell
    }
    
    
}
