//
//  DetailController.swift
//  NewYorkTimeTEST
//
//  Created by MacbookAir M1 FoodStory on 4/1/2566 BE.
//

import Foundation
import UIKit

class DetailController:UIViewController {
    
    @IBOutlet weak var coverDetailImage: UIImageView!
    @IBOutlet weak var titleDetailLabel: UILabel!
    @IBOutlet weak var descDetailLabel: UILabel!
    @IBOutlet weak var webDetailButton: UIButton!
    
    var menu: Menu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView(){
        webDetailButton.layer.cornerRadius = 8
        webDetailButton.layer.borderColor = UIColor.gray.cgColor
        webDetailButton.layer.borderWidth = 1
        
        for i in 0..<menu.multimedia.count {
            let url = menu.multimedia[i]
            
            coverDetailImage.kf.setImage(with: URL(string: url))
        }
        
        titleDetailLabel.text = menu.title
        descDetailLabel.text = menu.abstract
    }
    
    //MARK: - IBAction
    
    @IBAction func onOpenWebBtnTapped(_ sender:UIButton){
        if let url = URL(string: menu.url), UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
        }
    }
}
