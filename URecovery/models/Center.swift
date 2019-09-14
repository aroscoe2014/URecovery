//
//  Center.swift
//  URecovery
//
//  Created by Alex Roscoe on 7/28/19.
//  Copyright © 2019 Alex Roscoe. All rights reserved.
//

import Foundation

class Center {
    let id: String
    let city: String
    let discharge: Bool
    let famProg: Bool
    let famTher: Bool
    let gender: String
    let genderInclusive: Bool
    let insurance: Bool
    let insuranceType: [Bool]
    let language: [Bool]
    let medicad: Bool
    let medicare: Bool
    let name: String
    let phone: String
    let privatePay: Bool
    let scholarship: Bool
    let state: String
    let street: String
    let treamentModes: [String]
    let treats: [String]
    let website: String
    let zipcode: String
    
    init(id: String, city: String, discharge: Bool, famProg: Bool, famTher: Bool, gender: String, genderInclusive: Bool, insurance: Bool, insuranceType: [Bool], language: [Bool], medicad: Bool, medicare: Bool, name: String, phone: String, privatePay: Bool, scholarship: Bool, state: String, street: String, treamentModes: [String], treats: [String], website: String,  zipcode: String){
        self.id = id
        self.city = city
        self.discharge = discharge
        self.famProg = famProg
        self.famTher = famTher
        self.gender = gender
        self.genderInclusive = genderInclusive
        self.insurance = insurance
        self.insuranceType = insuranceType
        self.language = language
        self.medicad = medicad
        self.medicare = medicare
        self.name = name
        self.phone = phone
        self.privatePay = privatePay
        self.scholarship = scholarship
        self.state = state
        self.street = street
        self.treamentModes = treamentModes
        self.treats = treats
        self.website = website
        self.zipcode = zipcode
    }
}
