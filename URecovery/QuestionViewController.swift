//
//  QuestionViewController.swift
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

class QuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var questionNumber: UILabel!
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueButton: UIButton!
    
    //var db: Firestore!
    let db = Firestore.firestore()
    var questions = [Question]()
    var currentQuestion = 0
    var answers = [Int:[Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TableView
        tableView.delegate = self
        tableView.dataSource = self
        
        continueButton.layer.cornerRadius = 15.0
        
        SVProgressHUD.show(withStatus: "Loading Questions")
        getQuestions()
        
        NotificationCenter.default.addObserver(self, selector: #selector(cellSelected), name: Notification.Name("Selected"), object: nil)

        // Do any additional setup after loading the view.
    }
    
    @objc func cellSelected(_ notification:Notification) {
        let indexRow = notification.userInfo!["index"] as! Int
        let selected = notification.userInfo!["selected"] as! Bool
        
        if(selected){
            tableView.selectRow(at: IndexPath(row: indexRow, section: 0), animated: true, scrollPosition: .middle)
        } else {
            tableView.deselectRow(at: IndexPath(row: indexRow, section: 0), animated: true)
        }
    }
    
    func updateUI(){
        questionText.text = questions[currentQuestion].question
        questionNumber.text = String(currentQuestion + 1) + " of 10"
        let progress = Float(Float(currentQuestion) * 0.1 + 0.1)
        progressBar.setProgress(progress, animated: true)
        tableView.reloadData()
        let topIndex = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: topIndex, at: .top, animated: true)

        SVProgressHUD.dismiss()
        
        let width = self.view.frame.width
        self.tableView.transform = CGAffineTransform(translationX: width, y: 0.0)
        self.questionText.transform = CGAffineTransform(translationX: width, y: 0.0)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.tableView.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
            self.questionText.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
        })
        
        tableView.allowsMultipleSelection = questions[currentQuestion].multiEnabled
    }
    
    func getQuestions(){
        db.collection("questions").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let id = document.documentID
                    let questiontext = document.data()["question"] as! String
                    let answers = document.data()["answers"] as! [String]
                    let index = document.data()["index"] as! Int
                    let multi = document.data()["multiEnabled"] as! Bool
                    self.questions.append(Question(id: id, index: index, question: questiontext, answers: answers, multiEnabled: multi))
                }
                self.questions.sort(by: { $0.index < $1.index })
                self.updateUI()
            }
        }
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(questions.count != 0) {
            return questions[currentQuestion].answers.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "answerCell") as! AnswerTableViewCell
        cell.label.text = questions[currentQuestion].answers[indexPath.row]
        cell.selectionStyle = .none
        cell.index = indexPath.row
        return cell
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        if let selected = tableView.indexPathsForSelectedRows {
            SVProgressHUD.show()
            if(currentQuestion != 4 && currentQuestion != 6) {
                var array = [String]()
                for x in 0...selected.count - 1 {
                    let temp = questions[currentQuestion].answers[selected[x].row]
                    array.append(temp)
                    print(temp)
                }
                answers[currentQuestion] = array
            } else {
                var array = [Int]()
                for x in 0...selected.count - 1 {
                    let temp = selected[x].row
                    array.append(temp)
                    print(temp)
                }
                answers[currentQuestion] = array
            }
            currentQuestion += 1
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                let width = self.view.frame.width
                self.tableView.transform = CGAffineTransform(translationX: -width, y: 0.0)
                self.questionText.transform = CGAffineTransform(translationX: -width, y: 0.0)
            },completion: { finished in
                if(self.currentQuestion == 10) {
                    self.performSegue(withIdentifier: "results", sender: self)
                } else {
                    self.updateUI()
                }
            })
        } else {
            let alert = UIAlertController(title: "Error", message: "Please make a selection before continuing", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ResultsViewController
        {
            let vc = segue.destination as? ResultsViewController
            vc?.answers = answers
        }
    }
}
