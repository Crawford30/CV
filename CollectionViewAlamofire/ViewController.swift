//
//  ViewController.swift
//  CollectionViewAlamofire
//
//  Created by JOEL CRAWFORD on 2/18/20.
//  Copyright © 2020 JOEL CRAWFORD. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage



class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    enum myTags: Int {
        
        case cellFavourites = 2000
        case cellShare      = 4000
        case cellBookNow    = 6000
        
    }
    
    enum iPhoneDevice: Int {
        
        case iPhone8
        case iPhone8Plus
        case iPhone11
        case iPhone11ProMax
        
    }
    
    enum myTabButtons: Int {
        
        case tabAllServices
        case tabFeatured
        case tabFavourites
        
    }



    @IBOutlet weak var faketabbar:      UIButton!
    @IBOutlet weak var featuredButton:  UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    
    @IBOutlet weak var collectionView:           UICollectionView!
    @IBOutlet weak var horizontalcollectionView: UICollectionView!
        
    @IBOutlet weak var navBar: UINavigationBar!
    
    //=============For Categories===============
    let categoryLink = "https://ichuzz2work.com/api/services/categories"
    
    //==========For Services=========
     let link = "https://ichuzz2work.com/api/services"
    
    var categoryImages: [String] = []    // variables and constants ALWAYS START WITH a lowercase letter
    var categoryTitle: [String] = []    // UPPERCASE letters are reserved for names of classes
    
    var categoryThumbnails: NSMutableArray = NSMutableArray()

    let iPhone8PlusHeight: CGFloat = 736.0
    
    var tabButtonMode: Int = myTabButtons.tabAllServices.rawValue // Default mode
    
    var vertCVExpanded:   CGRect = CGRect()
    var vertCVCompressed: CGRect = CGRect()

    //==============cell size for category(ie, horizontal scroll view======
    let horizontalCVCellSize: CGSize = CGSize( width: 88, height: 90 )
    
    let myCellSize: CGSize = CGSize( width: 149, height: 148) // Vertical CV cell size
    
    //============For Services===================
    var serviceImages: [String] = []
    var serviceTitle:  [String] = []
    
    var serviceThumbnails: NSMutableArray = NSMutableArray()
        
   
    //===========vertical spacing for the cell
    let myVertCVSpacing:  CGFloat = CGFloat( 8.0 )
        //=========horizonatl spacing for the cell===
    let myHorizCVSpacing: CGFloat = CGFloat( 4.0 )
    
    let buttonFontSize:           CGFloat = CGFloat( 15.0 )
    let buttonEmphasizedFontSize: CGFloat = CGFloat( 18.0 )

    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    override func viewDidLoad() {
        
        super.viewDidLoad() // ‼️‼️‼️‼️‼️  This should ALWAYS BE THE FIRST CODE in viewDidLoad  ‼️‼️‼️‼️‼️‼️‼️‼️‼️

        var tempNavBarRect: CGRect = navBar.frame

        if self.view.frame.size.height <= iPhone8PlusHeight {
            
            tempNavBarRect.origin.y = 20
            
            navBar.frame = tempNavBarRect
            
            
            var tabBarRect: CGRect = faketabbar.frame
            
            tabBarRect.size.width = self.view.frame.size.width / 3
            
            let newYOrigin = self.view.frame.size.height - tabBarRect.size.height
            
            tabBarRect.origin.y = newYOrigin
            faketabbar.frame    = tabBarRect

            tabBarRect.origin.x += tabBarRect.size.width
            tabBarRect.origin.y  = newYOrigin
            featuredButton.frame = tabBarRect

            tabBarRect.origin.x  += tabBarRect.size.width
            tabBarRect.origin.y   = newYOrigin
            favouriteButton.frame = tabBarRect

        }
        
        navBar.topItem!.title = "ichuzz2work.com"
        
        horizontalcollectionView.backgroundColor = UIColor(named: "myGreenTint")

        setTabBarButtonColors()
                
        //-----------------------------------------------------------------------------------------------------
        
        LoadCategories()
        LoadServices()

        //-----------------------------------------------------------------------------------------------------

        horizontalcollectionView.delegate   = self  //=======for Horizontal CV========
        horizontalcollectionView.dataSource = self
        
        collectionView.delegate             = self    //=======for vertical CV====
        collectionView.dataSource           = self

        //-----------------------------------------------------------------------------------------------------

        var tempHCV: CGRect = horizontalcollectionView.frame
        
        tempHCV.origin.x    = 0
        tempHCV.origin.y    = faketabbar.frame.origin.y - ( horizontalcollectionView.frame.size.height + 8 )
        tempHCV.size.width  = self.view.frame.size.width //only one item in a row, but with spaces between them
        
        horizontalcollectionView.frame = tempHCV
        
        collectionView.backgroundColor = .clear
        
        var tempRect: CGRect = collectionView.frame
        tempRect.origin.y    = tempNavBarRect.origin.y + tempNavBarRect.size.height + 8 // 8 pixels below navBar
        tempRect.size.width  = ( myCellSize.width * 2 ) + ( myVertCVSpacing * 3 )
        tempRect.size.height = ( horizontalcollectionView.frame.origin.y - tempRect.origin.y ) - 8
        tempRect.origin.x    = CGFloat( roundf( Float( ( self.view.frame.size.width - tempRect.size.width ) / 2.0) ) ) //centers the collection view horizonatlly
        
        collectionView.frame = tempRect

        vertCVCompressed = tempRect // Calculate expanded and compressed frames once

        tempRect.size.height = ( horizontalcollectionView.frame.size.height + horizontalcollectionView.frame.origin.y ) - collectionView.frame.origin.y
        
        vertCVExpanded = tempRect // Height is the only difference

    }
    
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func setTabBarButtonColors() {
        
        switch tabButtonMode {
            
        case myTabButtons.tabAllServices.rawValue:
                        
            faketabbar.titleLabel?.font = UIFont.boldSystemFont(ofSize: buttonEmphasizedFontSize )
            faketabbar.setTitleColor( UIColor(named: "myGreenTint"), for: UIControl.State.normal )
            faketabbar.backgroundColor = .white
    
            featuredButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize )
            featuredButton.setTitleColor( .white, for: UIControl.State.normal )
            featuredButton.backgroundColor = UIColor(named: "myGreenTint")
            
            favouriteButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize )
            favouriteButton.setTitleColor( .white, for: UIControl.State.normal )
            favouriteButton.backgroundColor = UIColor(named: "myGreenTint")
            
            break

        case myTabButtons.tabFeatured.rawValue:
            
            faketabbar.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize )
            faketabbar.setTitleColor( .white, for: UIControl.State.normal )
            faketabbar.backgroundColor = UIColor(named: "myGreenTint")
    
            featuredButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: buttonEmphasizedFontSize )
            featuredButton.setTitleColor( UIColor(named: "myGreenTint"), for: UIControl.State.normal )
            featuredButton.backgroundColor = .white
            
            favouriteButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize )
            favouriteButton.setTitleColor( .white, for: UIControl.State.normal )
            favouriteButton.backgroundColor = UIColor(named: "myGreenTint")
            
            break

        case myTabButtons.tabFavourites.rawValue:
            
            faketabbar.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize )
            faketabbar.setTitleColor( .white, for: UIControl.State.normal )
            faketabbar.backgroundColor = UIColor(named: "myGreenTint")
    
            featuredButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize )
            featuredButton.setTitleColor( .white, for: UIControl.State.normal )
            featuredButton.backgroundColor = UIColor(named: "myGreenTint")
            
            favouriteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: buttonEmphasizedFontSize )
            favouriteButton.setTitleColor( UIColor(named: "myGreenTint"), for: UIControl.State.normal )
            favouriteButton.backgroundColor = .white
            
            break

        default:
            
            return
            
        }
        
    }
    
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    @IBAction func menuButtonTapped(_ sender: UIBarButtonItem) {
        
        print("Menu button tapped!")
        
    }
    
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        
        print("Search button tapped!")

    }
    
    //🔷🔷🔷🔷🔷🔷🔷🔷  ACTIONS FOR THE TAB BAR BUTTONS  🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    @IBAction func AllServicesAction(_ sender: UIButton) {
        
        if tabButtonMode == myTabButtons.tabAllServices.rawValue {
            
            return // Do nothing if already in that mode
            
        }
        
        print("All ServicesAction Button tapped")

        tabButtonMode = myTabButtons.tabAllServices.rawValue

        setTabBarButtonColors()
                
        collectionView.frame = vertCVCompressed
        
        horizontalcollectionView.isHidden = false
        
    }
    
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    //======Featured Action Button=====
    @IBAction func FeaturedAction(_ sender: UIButton) {

        if tabButtonMode == myTabButtons.tabFeatured.rawValue {
            
            return // Do nothing if already in that mode
            
        }
        
        if !horizontalcollectionView.isHidden {
        
            horizontalcollectionView.isHidden = true
            
            collectionView.frame = vertCVExpanded

        }

        tabButtonMode = myTabButtons.tabFeatured.rawValue

        setTabBarButtonColors()
        
        print("Featured Button tapped")
        
    }
    
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    @IBAction func vCVFaveButtonTapped(_ sender: UIButton) {
        
        print("Favourites Button \(String(sender.tag)) pressed!")

    }
    
    @IBAction func vCVShareButtonTapped(_ sender: UIButton) {

        print("Share Button \(String(sender.tag)) pressed!")

    }
    
    //=================for favourite Action Button===
    @IBAction func FavouriteAction(_ sender: UIButton) {
        
        if tabButtonMode == myTabButtons.tabFavourites.rawValue {
            
            return // Do nothing if already in that mode
            
        }
        
        if !horizontalcollectionView.isHidden {
        
            horizontalcollectionView.isHidden = true
            
            collectionView.frame = vertCVExpanded

        }
        
        tabButtonMode = myTabButtons.tabFavourites.rawValue

        setTabBarButtonColors()
        
        print("favourite Button tapped")
        
    }
    
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //=======for horizonatl collection view=====
        if (collectionView == horizontalcollectionView) {

            return categoryImages.count

        } else {

            //=======for vertical collection view=====
            return serviceImages.count

        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if ( collectionView == horizontalcollectionView ) {
            
            print("Horizontal Cell #\(String(indexPath.item)) selected!")
            
        }
        
    }
    
    //🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //===========for Horizontal collection view============
        
        if ( collectionView == horizontalcollectionView ) {
            
            let horizontalcell = horizontalcollectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCell", for: indexPath) as! horizontalCollectionViewCell
            
            horizontalcell.categoryLabel.text = self.categoryTitle[indexPath.item]
            
            if categoryThumbnails.object(at: indexPath.item) is UIImage {
                
                // ❌❌❌❌❌  DO NOT DOWNLOAD AND SCALE THE IMAGE IF WE ALREADY HAVE IT  ❌❌❌❌❌
                
                horizontalcell.categoryImageView.image = categoryThumbnails.object( at: indexPath.item ) as? UIImage
                
                print("Image retrieved from categoryThumbnails array") // Remove this
                
            } else {

                let Categoryimagestring = self.categoryImages[indexPath.item] //getting image for category
                
                //======replacing a space in a the image string====
                let newCategoryimagetstring = Categoryimagestring.replacingOccurrences(of: "", with: "%20", options: .literal)
                
                if let categoryimageurl = newCategoryimagetstring as? String {

                    Alamofire.request("https://api.ichuzz2work.com/" + categoryimageurl).responseImage { (response) in

                        if let categoryImage = response.result.value {

                            DispatchQueue.main.async {
                                
                                let categorysize        = horizontalcell.categoryImageView.frame.size
                                let scaledCategoryImage = categoryImage.af_imageScaled(to: categorysize)
                                
                                horizontalcell.categoryImageView?.image = scaledCategoryImage
                                
                                // Replace placeholder string with actual image
                                self.categoryThumbnails.replaceObject( at: indexPath.item, with: scaledCategoryImage )

                            }

                        }

                    }

                }
                
            }
            
            return horizontalcell
        }
        
        //================for vertical scroll collection view===========
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        cell.servicelabel.text = self.serviceTitle[indexPath.item]
        cell.servicelabel.layer.cornerRadius = 6
        cell.servicelabel.clipsToBounds      = true

        let imageString = self.serviceImages[indexPath.item]
        
        cell.bookNowButtonOutlet.layer.cornerRadius = 6
        cell.bookNowButtonOutlet.clipsToBounds      = true
        cell.bookNowButtonOutlet.tag                = myTags.cellBookNow.rawValue + indexPath.item
        
        cell.favouriteBtn.tag = myTags.cellFavourites.rawValue + indexPath.item
        cell.shareBtn.tag     = myTags.cellShare.rawValue      + indexPath.item
        
        if serviceThumbnails.object(at: indexPath.item) is UIImage {
            
            // ❌❌❌❌❌  DO NOT DOWNLOAD AND SCALE THE IMAGE IF WE ALREADY HAVE IT  ❌❌❌❌❌

            cell.serviceimage.image = serviceThumbnails.object( at: indexPath.item ) as? UIImage
            
            print("Image retrieved from serviceThumbnails array") // Remove this
            
        } else {
            
            //======replacing a space in an image URL with %20
            let newString = imageString.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
            
            if let imageUrl = newString as? String {
                
                //https://ichuzz2work.com/api/services

                Alamofire.request("https://api.ichuzz2work.com/" + imageUrl).responseImage { (response) in

                    if let image = response.result.value  {

                        DispatchQueue.main.async {

                            let size        = CGSize(width: 150.0, height: 150.0)
                            let scaledImage = image.af_imageScaled(to: size) //scale the size gisregarding the aspect ratio
                            
                            cell.serviceimage?.image = scaledImage
                            
                            // Replace placeholder string with actual image
                            self.serviceThumbnails.replaceObject( at: indexPath.item, with: scaledImage )
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        return cell
    }
    
    //🔷🔷🔷🔷🔷🔷  Load services in the vertical scroll view  🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if ( collectionView == horizontalcollectionView ) {

            return horizontalCVCellSize

        } else {

            return myCellSize

        }
        
    }
    
    //🔷🔷🔷🔷🔷  Load services in the vertical scroll view  🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func LoadServices() {
        
        Alamofire.request(link, method: .get)

            .validate()

            .responseJSON { (response) in

                guard response.result.isSuccess else {
                    print("Error with response: \(String(describing: response.result.error))")
                    return
                }
                
                guard let dict = response.result.value as? Dictionary <String,AnyObject> else {
                    print("Error with dictionary: \(String(describing: response.result.error))")
                    return
                }
                
                guard let dictData = dict["data"] as? [Dictionary <String,AnyObject>] else {
                    print("Error with dictionary data: \(String(describing: response.result.error))")
                    return
                }
                
                for serviceData in dictData {
                    
                    self.serviceImages.append(serviceData["image"] as! String)
                    self.serviceTitle.append(serviceData["name"] as! String)
                
                    self.serviceThumbnails.add("placeholder") // Replace later with actual UIImage

                }
                                
                self.collectionView.reloadData()
                
                return
                
        }
        
    }
    
    //🔷🔷🔷🔷🔷🔷  Load categories in the horizonalscroll view  🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

    func LoadCategories() {
        
        Alamofire.request(categoryLink, method: .get)
            
            .validate()

            .responseJSON { (response) in

                guard response.result.isSuccess else {
                    print("Error with response: \(String(describing: response.result.error))")
                    return
                }
                
                guard let dict = response.result.value as? Dictionary <String,AnyObject> else {
                    print("Error with dictionary: \(String(describing: response.result.error))")
                    return
                }
                
                guard let dictData = dict["data"] as? [Dictionary <String,AnyObject>] else {
                    print("Error with dictionary data: \(String(describing: response.result.error))")
                    return
                }
                
                for categoryData in dictData {
                    
                    self.categoryImages.append(categoryData["image"] as! String)
                    self.categoryTitle.append(categoryData["name"] as! String)

                    self.categoryThumbnails.add("placeholder") // Replace later with actual UIImage
                    
                }
                
                self.horizontalcollectionView.reloadData()
                
                return
                
        }
        
    }
    
    @IBAction func bookNowTapped(_ sender: UIButton) {

        print("Book Now \(String(sender.tag)) pressed!")
        
    }
    
}

//🔷🔷🔷🔷🔷  extention for UICollectionViewDelegateFlowLayout  🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷

extension ViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if ( collectionView == horizontalcollectionView ) {

            return UIEdgeInsets(top: myHorizCVSpacing, left: myHorizCVSpacing, bottom: myHorizCVSpacing, right: myHorizCVSpacing)

        } else {

            return UIEdgeInsets(top: myVertCVSpacing, left: myVertCVSpacing, bottom: myVertCVSpacing, right: myVertCVSpacing)

        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if ( collectionView == horizontalcollectionView ) {

            return myHorizCVSpacing

        } else {

            return myVertCVSpacing

        }
    
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        if ( collectionView == horizontalcollectionView ) {

            return myHorizCVSpacing

        } else {

            return myVertCVSpacing

        }

    }
    
}

//🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷🔷



