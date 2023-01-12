//
//  MenuCellCollectionViewCell.swift
//  NewYorkTimeTEST
//
//  Created by MacbookAir M1 FoodStory on 27/12/2565 BE.
//

import UIKit
import Kingfisher

class MenuCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImage:UIImageView!
    @IBOutlet weak var titleLable:UILabel!
    @IBOutlet weak var bgViewConstraint:NSLayoutConstraint!
    
    static let identifier = "MenuCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCell(menu: Menu,position: Int, itemWidth: CGFloat) {
        for i in 0..<menu.multimedia.count {
            let url = menu.multimedia[i]
            
            coverImage.kf.setImage(with: URL(string: url))
        }
        
        titleLable.text = menu.title
        bgViewConstraint.constant = itemWidth
    }
}
