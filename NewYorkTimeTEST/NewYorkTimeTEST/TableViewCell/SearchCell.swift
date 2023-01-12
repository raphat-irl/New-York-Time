//
//  SearchCell.swift
//  NewYorkTimeTEST
//
//  Created by MacbookAir M1 FoodStory on 5/1/2566 BE.
//

import Foundation
import UIKit

class SearchCell:UITableViewCell {
    
    @IBOutlet weak var bgView:UIView!
    @IBOutlet weak var coverImage:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var descLabel:UILabel!
    @IBOutlet weak var byLabel:UILabel!
    
    static let identifier = "SearchCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.cornerRadius = 8
        bgView.layer.borderColor = UIColor.lightGray.cgColor
        bgView.layer.borderWidth = 1
        
    }
    
    func setCell(menu:Menu, position:Int){
        for i in 0..<menu.multimedia.count {
            let url = menu.multimedia[i]
            
            coverImage.kf.setImage(with: URL(string: url))
        }
        
        titleLabel.text = menu.title
        descLabel.text = menu.abstract
        byLabel.text = menu.byline
    }
}
