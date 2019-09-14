//
//  ResultsViewController.swift
//  URecovery
//
//  Created by Alex Roscoe on 7/28/19.
//  Copyright © 2019 Alex Roscoe. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import SVProgressHUD
import CoreLocation

class ResultsViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    var answers = [Int:[Any]]()
    let db = Firestore.firestore()
    
    var centers = [Center]()
    var filter = [Center]()
    var locations = [String: Int]()
    var final = [Center]()
    var offsetCount = 0;
    var error = false
    var zipError = false
    
    var timer: Timer?
    var prevCount = 50
    var done = false
    
    
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var zipView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultsView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let width = self.view.frame.width
        self.tableView.transform = CGAffineTransform(translationX: width, y: 0.0)
        self.noResultsView.transform = CGAffineTransform(translationX: width, y: 0.0)
        
        self.zipView.transform = CGAffineTransform(translationX: width, y: 0.0)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.zipView.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(final.count != 0) {
            return final.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CenterCell") as! CenterTableViewCell
        let temp = final[indexPath.row]
        cell.titleLabel.text = temp.name
        cell.addressLabel.text = temp.street + ", " + temp.city + ", " + temp.state
        cell.phoneLabel.text = temp.phone
        cell.websiteLabel.text = temp.website
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 136.0;//Choose your custom row height
    }
    
    func getLocationFromPostalCode(postalCode : String, id: String){
        let geocoder = CLGeocoder()
        let userPostal = self.zipCode.text!
        geocoder.geocodeAddressString(userPostal) {
            (placemarks, error) -> Void in
            // Placemarks is an optional array of type CLPlacemarks, first item in array is best guess of Address
            
            if let placemark = placemarks?[0] {
                
                if placemark.postalCode == userPostal{
                    let userPoint = placemarks?[0]
                    // you can get all the details of place here
                    geocoder.geocodeAddressString(postalCode) {
                        (placemarks, error) -> Void in
                        // Placemarks is an optional array of type CLPlacemarks, first item in array is best guess of Address
                        
                        if let placemark = placemarks?[0] {
                            
                            if placemark.postalCode == postalCode{
                                let start = placemark.location!
                                let end = userPoint?.location!
                                let distanceInMeters = Int(end!.distance(from: start)) // result is in meters
                                self.locations[id] = distanceInMeters
                                //print(distanceInMeters)
                                print(self.locations.count)
                                print(self.centers.count - self.offsetCount)
                                if(self.locations.count == (self.centers.count - self.offsetCount - 1)) {
                                    print("Location Done")
                                    if(!self.done) {
                                        self.getTop()
                                        self.done = true
                                    }
                                }
                            } else {
                                self.offsetCount += 1
                            }
                        }
                    }
                }
                else{
                    print("Please enter valid zipcode")
                }
            }
        }
    }
    
    func getTop(){
        let sortedByValueDictionary = locations.sorted { $0.1 < $1.1 }
        if(sortedByValueDictionary.count > 0){
            let first = sortedByValueDictionary[0]
            var index = centers.firstIndex(where: { (item) -> Bool in
                item.id == first.key // test if this is the item you're looking for
            })
            final.append(centers[index!])
            if(sortedByValueDictionary.count > 1) {
                let second = sortedByValueDictionary[1]
                index = centers.firstIndex(where: { (item) -> Bool in
                    item.id == second.key // test if this is the item you're looking for
                })
                final.append(centers[index!])
                
                if(sortedByValueDictionary.count > 2) {
                    let third = sortedByValueDictionary[2]
                    index = centers.firstIndex(where: { (item) -> Bool in
                        item.id == third.key // test if this is the item you're looking for
                    })
                    final.append(centers[index!])
                }
            }
        }
        tableView.reloadData()
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.tableView.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
        },completion: { finished in
            SVProgressHUD.dismiss()
        })
        
    }
    
    
    func getResults(){
        let problem = answers[0] as! [String]
        db.collection("centers").whereField("treats", arrayContains: problem[0]).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let id = document.documentID
                    let city = document.data()["city"] as! String
                    let discharge = document.data()["discharge"] as! Bool
                    let famProg = document.data()["famProg"] as! Bool
                    let famTher = document.data()["famTher"] as! Bool
                    var gender: String
                    if((document.data()["gender"]) != nil){
                        gender = document.data()["gender"] as! String
                    } else {
                        gender = "female"
                    }
                    let genderInclusive = document.data()["genderInclusive"] as! Bool
                    let insurance = document.data()["insurance"] as! Bool
                    let insuranceType = document.data()["insuranceType"] as! [Bool]
                    let language = document.data()["language"] as! [Bool]
                    let medicad = document.data()["medicad"] as! Bool
                    let medicare = document.data()["medicare"] as! Bool
                    let name = document.data()["name"] as! String
                    let phone = document.data()["phone"] as! String
                    let privatePay = document.data()["privatePay"] as! Bool
                    let scholarship = document.data()["scholarship"] as! Bool
                    let state = document.data()["state"] as! String
                    let street = document.data()["street"] as! String
                    let treamentModes = document.data()["treatmentModes"] as! [String]
                    let treats = document.data()["treats"] as! [String]
                    let website = document.data()["website"] as! String
                    let zipcode = document.data()["zipcode"] as! String
                    
                    self.centers.append(Center(id: id, city: city, discharge: discharge, famProg: famProg, famTher: famTher, gender: gender, genderInclusive: genderInclusive, insurance: insurance, insuranceType: insuranceType, language: language, medicad: medicad, medicare: medicare, name: name, phone: phone, privatePay: privatePay, scholarship: scholarship, state: state, street: street, treamentModes: treamentModes, treats: treats, website: website, zipcode: zipcode))
                }
                var scholarshipSelected = false
                let selected = self.answers[3] as! [String]
                if(selected[0] == "Yes") {
                    scholarshipSelected = true
                }
                //Filter Insurance Type
                if(!scholarshipSelected){
                    for x in 0...self.centers.count - 1 {
                        let temp = self.centers[x].insuranceType
                        let selected = self.answers[4] as! [Int]
                        if(selected[0] == 21){
                            self.error = true
                        }
                        else if(temp[selected[0]]){
                            self.filter.append(self.centers[x])
                        }
                    }
                    self.centers = self.filter
                    self.filter.removeAll()
                    print("Insurance Filter Done")
                }
                
                //Filter Language
                if(self.centers.count != 0){
                    for x in 0...self.centers.count - 1 {
                        let temp = self.centers[x].language
                        let selected = self.answers[6] as! [Int]
                        if(temp[selected[0]]){
                            self.filter.append(self.centers[x])
                        }
                    }
                    self.centers = self.filter
                    self.filter.removeAll()
                    print("Langauge Filter Done")
                } else {
                    self.error = true
                }
                
                //Filter Private Pay
                if(self.centers.count != 0){
                    for x in 0...self.centers.count - 1 {
                        let temp = self.centers[x].privatePay
                        let selected = self.answers[2] as! [String]
                        if(selected[0] == "Yes") {
                            if(temp){
                                self.filter.append(self.centers[x])
                            }
                        } else {
                            if(!temp){
                                self.filter.append(self.centers[x])
                            }
                        }
                        
                    }
                    self.centers = self.filter
                    self.filter.removeAll()
                    print("Private Pay Filter Done")
                } else {
                    self.error = true
                }
                
                //Filter Scholarship
                if(self.centers.count != 0) {
                    for x in 0...self.centers.count - 1 {
                        let temp = self.centers[x].scholarship
                        let selected = self.answers[3] as! [String]
                        if(selected[0] == "Yes") {
                            if(temp){
                                self.filter.append(self.centers[x])
                            }
                        } else {
                            self.filter.append(self.centers[x])
                        }
                        
                    }
                    self.centers = self.filter
                    self.filter.removeAll()
                    print("Scholarship Filter Done")
                } else {
                    self.error = true
                }
                
                //Filter Discharge Planning
                if(self.centers.count != 0){
                    for x in 0...self.centers.count - 1 {
                        let temp = self.centers[x].discharge
                        let selected = self.answers[8] as! [String]
                        if(selected[0] == "Yes") {
                            if(temp){
                                self.filter.append(self.centers[x])
                            }
                        } else {
                            self.filter.append(self.centers[x])
                        }
                        
                    }
                    self.centers = self.filter
                    self.filter.removeAll()
                    print("Discharge Filter Done")
                } else {
                    self.error = true
                }
                
                //Filter Family
                if(self.centers.count != 0) {
                    for x in 0...self.centers.count - 1 {
                        let selected = self.answers[7] as! [String]
                        
                        if(selected[0] == "Family Programming") {
                            let temp = self.centers[x].famProg
                            if(temp){
                                self.filter.append(self.centers[x])
                            }
                        } else if (selected[0] == "Family Therapy") {
                            let temp = self.centers[x].famTher
                            if(temp){
                                self.filter.append(self.centers[x])
                            }
                        } else {
                            self.filter.append(self.centers[x])
                        }
                        
                    }
                    self.centers = self.filter
                    self.filter.removeAll()
                    print("Family Filter Done")
                } else {
                    self.error = true
                }
                
                //Filter Gender
                if(self.centers.count != 0){
                    for x in 0...self.centers.count - 1 {
                        let selected = self.answers[9] as! [String]
                        if(selected[0] == "All Inclusive"){
                            let temp = self.centers[x].genderInclusive
                            if(temp){
                                self.filter.append(self.centers[x])
                            }
                        } else {
                            let temp = self.centers[x].genderInclusive
                            if(!temp){
                                let temp2 = self.centers[x].gender
                                if(temp2 == "female"){
                                    self.filter.append(self.centers[x])
                                }
                            }
                        }
                    }
                    self.centers = self.filter
                    self.filter.removeAll()
                    print("Gender Filter Done")
                } else {
                    self.error = true
                }
                
                //Filter Gender
                if(self.centers.count != 0){
                    for x in 0...self.centers.count - 1 {
                        let selected = self.answers[5] as! [String]
                        let temp = self.centers[x].treamentModes
                        for i in 0...selected.count - 1 {
                            if(temp.contains(selected[i])){
                                self.filter.append(self.centers[x])
                            }
                        }
                    }
                    var seen = Set<String>()
                    var unique = [Center]()
                    if(self.filter.count != 0){
                        for center in self.filter {
                            if !seen.contains(center.id) {
                                unique.append(center)
                                seen.insert(center.id)
                            }
                        }
                        self.centers = unique
                    } else {
                        self.error = true
                    }
                    print("Treatment Modes Done")
                } else {
                    self.error = true
                }
                
                print("Getting Location")
                
                if(self.centers.count != 0){
                    for x in 0...self.centers.count - 1 {
                        let temp = self.centers[x]
                        self.getLocationFromPostalCode(postalCode: temp.zipcode, id: temp.id)
                    }
                } else {
                    self.error = true
                }
                
                if(self.error){
                    self.noResultsView.isHidden = false
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.noResultsView.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
                    },completion: { finished in
                        SVProgressHUD.dismiss()
                    })
                }
            }
        }
    }
    
    @objc func fireTimer(timer: Timer) {
        print("Timer fired!")
        
        if self.locations.count == self.prevCount {
            timer.invalidate()
            print("End")
            if(!self.done) {
                self.getTop()
                self.done = true
            }
        }
        self.prevCount = locations.count
    }
    
    @IBAction func btnPressed(_ sender: Any) {
        self.view.endEditing(true)
        SVProgressHUD.show(withStatus: "Checking ZipCode")
        let geocoder = CLGeocoder()
        let userPostal = self.zipCode.text!
        geocoder.geocodeAddressString(userPostal) {
            (placemarks, error) -> Void in
            // Placemarks is an optional array of type CLPlacemarks, first item in array is best guess of Address
            
            if let placemark = placemarks?[0] {
                
                if placemark.postalCode == userPostal{
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        let width = self.view.frame.width
                        self.zipView.transform = CGAffineTransform(translationX: -width, y: 0.0)
                    },completion: { finished in
                        SVProgressHUD.show(withStatus: "Getting Results")
                        self.getResults()
                        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: true)
                    })
                }
                else{
                    print("Please enter valid zipcode")
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Error", message: "Please enter a valid ZipCode", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            }
        }
        
    }
    
    
}
