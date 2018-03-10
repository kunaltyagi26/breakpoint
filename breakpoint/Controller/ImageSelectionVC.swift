//
//  ImageSelectionVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 15/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Pastel
import Photos

class ImageSelectionVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var imageSelectionView: PastelView!
    @IBOutlet weak var imagesView: UIView!
    
    var imageType: String? = "light"
    var imagePicker = UIImagePickerController()
    var selectedImageFromPicker = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.black
        self.imageSelectionView.alpha = 0.7
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
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
    
    @IBAction func fromGalleryPressed(_ sender: Any) {
        checkPermission()
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            //print("Access is granted by user")
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                //print("Button capture")
                
                imagePicker.sourceType = .savedPhotosAlbum;
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                //print("status is \(newStatus)")
                /*if newStatus ==  PHAuthorizationStatus.authorized {
                    if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                        print("Button capture")
                        
                        self.imagePicker.sourceType = .savedPhotosAlbum;
                        
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                }*/
            })
            //print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
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
                /*guard let personalDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "personalDetailsVC") as? PersonalDetailsVC else { return }
                self.present(personalDetailsVC, animated: true, completion: nil)*/
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
            //DataService.instance.setAvatarName(avatarName: "light\(indexPath.item)")
            selectedImageFromPicker = UIImage(named: "light\(indexPath.item)")!
            DataService.instance.setAvatarName(avatarName: selectedImageFromPicker)
        }
        else if imageType == "dark" {
            //DataService.instance.setAvatarName(avatarName: "dark\(indexPath.item)")
            selectedImageFromPicker = UIImage(named: "light\(indexPath.item)")!
            DataService.instance.setAvatarName(avatarName: selectedImageFromPicker)
        }
        
        guard let personalDetailsVC = storyboard?.instantiateViewController(withIdentifier: "personalDetailsVC") as? PersonalDetailsVC else { return }
        personalDetailsVC.setImage(selectedImage: selectedImageFromPicker)
        
        removeAnimate()
        //dismiss(animated: true, completion: nil)
    }
}


extension ImageSelectionVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let orginalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = orginalImage
            /*let imgData: NSData = NSData(data: UIImageJPEGRepresentation((orginalImage), 1)!)
            let imageSize: Int = imgData.length
            print("size of image in KB: %f ", Double(imageSize) / 1024.0)*/
        }
        guard let personalDetailsVC = storyboard?.instantiateViewController(withIdentifier: "personalDetailsVC") as? PersonalDetailsVC else { return }
        personalDetailsVC.setImage(selectedImage: selectedImageFromPicker)
        dismiss(animated: true, completion: nil)
        present(personalDetailsVC, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
