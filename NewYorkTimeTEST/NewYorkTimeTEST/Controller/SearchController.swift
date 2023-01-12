//
//  SearchController.swift
//  NewYorkTimeTEST
//
//  Created by MacbookAir M1 FoodStory on 7/1/2566 BE.
//

import Foundation
import UIKit

class SearchController:UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var menuView: UITableView!
    @IBOutlet weak var searchBox: UITextField!
    
    var menuList:[Menu]!
    var filterList:[Menu] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        requestData()
        
    }
    
    func setupView() {
        searchBox.delegate = self
        searchBox.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        menuView.register(UINib(nibName: "SearchCell", bundle: nil),
                          forCellReuseIdentifier: SearchCell.identifier)
    }
    
    //MARK: - UITextField delegate
    
    @objc func textFieldDidChange(_ textField: UITextField){
        if textField.text != "" {
            menuList = filterList.filter {$0.title.lowercased().contains(textField.text
                                                                         ?? "" )}
        }
        menuView.reloadData()
    }
    
    //MARK: - UITableView datasource & delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuList == nil ? 0 : menuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.identifier, for: indexPath as IndexPath) as? SearchCell else {
            return UITableViewCell()
        }
        
        let data = menuList[indexPath.row]
        cell.setCell(menu: data, position: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = menuList[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let destinatoinVC = storyboard.instantiateViewController(withIdentifier: "DetailController")
            as? DetailController{
            destinatoinVC.menu = data
            
            self.navigationController?.pushViewController(destinatoinVC, animated: true )
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
                    self.filterList = []
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
                    self.filterList.append(menu)
                }
                
                //  Reload data
                self.menuView.reloadData()
                self.stopLoading()
            }
        })
        connection.onLostConnection({ () -> Void in
        })
        connection.execute()
        self.startLoading()
    }
}
