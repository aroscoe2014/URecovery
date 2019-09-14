//
//  AnswerTableViewCell.swift
//  URecovery
//
//  Created by Alex Roscoe on 7/28/19.
//  Copyright © 2019 Alex Roscoe. All rights reserved.
//

import UIKit
import M13Checkbox

class AnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkbox: M13Checkbox!
    @IBOutlet weak var backgorund: UIImageView!
    
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkbox.markType = .radio
        checkbox.stateChangeAnimation = .expand(.stroke)
    }
    
    @IBAction func Circletouched(_ sender: Any) {
        print("CheckMark Touched")
        if(isSelected){
            setSelected(false, animated: true)
        } else {
            setSelected(true, animated: true)
        }
        let scores = ["index": index, "selected": isSelected] as [String : Any]
        NotificationCenter.default.post(name: Notification.Name("Selected"), object: self, userInfo: scores)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if(selected){
            checkbox.setCheckState(.checked, animated: true)
            backgorund.image = UIImage(named: "Rectangle8")
        } else {
            checkbox.setCheckState(.unchecked, animated: true)
            backgorund.image = UIImage(named: "Rectangle7")
        }
        // Configure the view for the selected state
    }

}
