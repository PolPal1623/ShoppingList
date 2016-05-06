//
//  LibraryTableViewCell.swift
//  ShoppingList
//
//  Created by Polynin Pavel on 26.01.16.
//  Copyright © 2016 Polynin Pavel. All rights reserved.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {
  
  //===================================//
  // MARK: - IBOutlet связывающие Scene и LibraryTableViewCell
  //===================================//
  
  @IBOutlet weak var imageBackgroundLibrary: UIImageView! // Фоновое изображение ячейки
  
  @IBOutlet weak var nameProductInLibrary: UILabel! // Название продукта в библиотеке
  
  //===================================//
  // MARK: - Методы которые в данный момент не используются
  //===================================//

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
