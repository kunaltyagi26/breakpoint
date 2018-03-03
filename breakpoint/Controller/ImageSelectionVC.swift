//
//  ImageSelectionVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 15/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Pastel

class ImageSelectionVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var imageSelectionView: PastelView!
    @IBOutlet weak var imagesView: UIView!
    
    var imageType: String? = "light"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.black
        self.imageSelectionView.alpha = 0.7
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageSelectionView.startPastelPoint = .bottomLeft
        imageSelectionView.endPastelPoint = .topRight
        imageSelectionView.setColors([UIColor(red: 98/255, green: 39/255, blue: 116/255, alpha: 1.0), UIColor(red: 197/255, green: 51/255, blue: 100/255, alpha: 1.0), UIColor(red: 113/255, green: 23/255, blue: 234/255, alpha: 1.0), UIColor(red: 234/255, green: 96/255, blue: 96/255, alpha: 1.0)])
        imageSelectionView.startAnimation()
        showAnimate()
    }
    
    @IBAction func closePressed(_ sender: Any) {
        removeAnimate()
    }
    
    @IBAction func imageTypeSelected(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            imageType = "light"
            collectionView.backgroundColor = UIColor.black
        case 1:
            imageType = "dark"
            collectionView.backgroundColor = UIColor.white
        default:
            break
        }
        collectionView.reloadData()
    }
    
    func showAnimate()
    {
        //self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        //self.view.alpha = 0.0;
        print("Being called now.")
        UIView.animate(withDuration: 0.25, animations: {
            self.imagesView.alpha = 1.0
            self.imagesView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
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
                //self.view.removeFromSuperview()
                //guard let personalDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "personalDetailsVC") as? PersonalDetailsVC else { return }
                self.dismiss(animated: false, completion: nil)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*let selectedImage = collectionView.cellForItem(at: indexPath) as! ProfileImageCell
        guard let personalDetailsVC = storyboard?.instantiateViewController(withIdentifier: "personalDetailsVC") as? PersonalDetailsVC else { return }
        print(selectedImage.profileImage.image!)
        personalDetailsVC.setImage(selectedImage: selectedImage.profileImage.image!)
        removeAnimate()
        personalDetailsVC.configureImage(selectedImage: selectedImage.profileImage.image!)*/
        if imageType == "light" {
            DataService.instance.setAvatarName(avatarName: "light\(indexPath.item)")
        }
        else if imageType == "dark" {
            DataService.instance.setAvatarName(avatarName: "dark\(indexPath.item)")
        }
        removeAnimate()
        //dismiss(animated: true, completion: nil)
    }
}
