//
//  CustomCell.swift
//  FireStoreStudy
//
//  Created by あかにしらぶお on 2021/09/12.
//

import UIKit

class CustomCell: UITableViewCell {

    
    
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var countLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
