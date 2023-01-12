//
//  ListController.swift
//  NewYorkTimeTEST
//
//  Created by MacbookAir M1 FoodStory on 4/1/2566 BE.
//

import Foundation
import UIKit
class ListController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,
                      UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var menuView: UICollectionView!
    
    var menuList: [Menu]!
    
    private var itemWidth: CGFloat = 0
    private var itemHight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        requestData()
    }
    
    func setupView() {
        menuView.register(UINib(nibName: MenuCell.identifier, bundle: nil),
                          forCellWithReuseIdentifier: MenuCell.identifier)
        
        var screenWidth = UIScreen.main.bounds.width
        screenWidth -= 52
        
        itemWidth = screenWidth / CGFloat(2)
        itemHight = 240
        
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor.white

    }
    
    //MARK: - UICollectionView datasource & delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuList == nil ? 0 : menuList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCell.identifier, for: indexPath as IndexPath) as? MenuCell else {
            return UICollectionViewCell()
        }
        
        let data = menuList[indexPath.row]
        cell.setCell(menu: data, position: indexPath.row, itemWidth: self.itemWidth)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = menuList[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let destinationVC = storyboard.instantiateViewController(withIdentifier: "DetailController") as? DetailController {
            destinationVC.menu = data
            
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 16,bottom: 10, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHight)
    }
    
    //MARK: - IBAction
    
    @IBAction func onSearchBtnTapped(_ sender: UIButton) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detinationVC = storyboard.instantiateViewController(withIdentifier: "SearchController") as? SearchController{
            
            self.navigationController?.pushViewController(detinationVC, animated: true)
        }
    }
    
    //MARK: - Request api
    
    func requestData() {
        let baseUrl = "http://api.nytimes.com/svc/topstories/v2/books.json?api-key=GDrQ2aBDKGj6DELALg9H4JeXLysN1peW"
        let connection = Connection(url: baseUrl)
        connection.requestMethod = "GET"
        connection.onComplete({ (result) -> Void in
            let resultData = result.data(using: String.Encoding.utf8)
            let json = JSON(data: resultData!, options: JSONSerialization.ReadingOptions(rawValue: 0), error: nil)
            let error = json["error"].int16Value
            if(error == 0) {
                
                if self.menuList == nil {
                    self.menuList = []
                } else {
                    self.menuList.removeAll()
                }
                
                let resultJArr = json["results"].arrayValue
                for i in 0..<resultJArr.count {
                    let resultJObj = resultJArr[i]
                    let title = resultJObj["title"].stringValue
                    let abstract = resultJObj["abstract"].stringValue
                    let byline = resultJObj["byline"].stringValue
                    let url = resultJObj["url"].stringValue
                    let multimediaJArr = resultJObj["multimedia"].arrayValue
                    // Convert date
                   
                    var imagelist:[String] = []
                    
                    for j in 0..<multimediaJArr.count {
                        let mediaJObj = multimediaJArr[j]
                        let imageurl = mediaJObj["url"].stringValue
                        imagelist.append(imageurl)
                        
                    }
                    
                    //  Create instance
                    let menu = Menu(title: title,
                                    abstract: abstract,
                                    byline: byline,
                                    url: url,
                                    multimedia: imagelist)
                    
                    //  Add to list
                    self.menuList.append(menu)
                }
                
                //  Reload data
                self.menuView.reloadData()
//                self.loadingView.stopAnimating()
                
                self.stopLoading()
            }
        })
        connection.onLostConnection({ () -> Void in
        })
        connection.execute()
        self.startLoading()
//        loadingView.startAnimating()
    }
    
    

}
