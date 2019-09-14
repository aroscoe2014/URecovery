//
//  Question.swift
//  URecovery
//
//  Created by Alex Roscoe on 7/28/19.
//  Copyright © 2019 Alex Roscoe. All rights reserved.
//

import Foundation

class Question {
    let id: String
    let index: Int
    let question: String
    let answers: [String]
    let multiEnabled: Bool
    
    init(id: String, index: Int, question: String, answers: [String], multiEnabled: Bool){
        self.id = id
        self.index = index
        self.question = question
        self.answers = answers
        self.multiEnabled = multiEnabled
    }
}
