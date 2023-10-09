//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore() //Here we are creating a reference to our database, so we can out data from our viewController into the database
    
    var messages: [Message] = []//This is empty as we are getting our message from our database, which is what the user types into the messageTextField
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        navigationItem.title = K.appName
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)//Here we are registering our xib file. The nibName is the name of the xib file(Nib and xib mean the same thing)
        
        
        //Due to the fact we want our text messages, in our database to be shown when the app loads up, we need to call it in the viewDidLoad():
        loadMessages()

    }
    
    func loadMessages() {//This method is going to be used to add texts from our database into our tableView/ app
        

        //SnapShot listener, listens for when, new data is added into the database. e.g: a new text is sent within the app
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { querySnapshot, error in
            
            self.messages = []//This empties our array, before a new item is added into the array.
            
            if let e = error {//This checks if there was an error when retrieving data
                print("There was an issue retrieving data from fireStor \(e)")
            } else {
                if let snapShotDocuments = querySnapshot?.documents {//Here we are optional binding our snapShotDocuments
                    for doc in snapShotDocuments {
                        let data = doc.data()//The .data gives us our data, stored in the fireStore database
                        if let Messagesender = data[K.FStore.senderField] as? String, let body = data[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: Messagesender, body: body)
                            self.messages.append(newMessage)
                                                        
                            

                            DispatchQueue.main.async {//This code updates our data in the foreground
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)//This codes scrolls down to the last sent text in the tableView
                                
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
    
    @IBAction func sendPressed(_ sender: UIButton) {//Here we are adding data into our database using Firebase Firestore.
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email { //This is how to get the email of the signed in user in firebase
            
            db.collection(K.FStore.collectionName).addDocument(data: [//When adding data to a database, we use dictionaries
                K.FStore.senderField: messageSender,//key = "sender", value = sender email
                K.FStore.bodyField: messageBody, //key = "body", value = user's text
                K.FStore.dateField: Date().timeIntervalSince1970 //Here we are storing the time the data was added
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving the data into Firestore \(e)")
                }
                else {
                    print("Successfully saved data")
                    
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
            
            
            
            
    }
}
    
    @IBAction func LogOutPressed(_ sender: UIBarButtonItem) {//When log out is pressed, the app goes to the main screen
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)//This method should take us all the way back to the root viewController
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    

}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {//This tells our app how many rows we want in our table
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {//The indexPath is the position. This method creates a cell for every row we have in a tableView
        let message = messages[indexPath.row]//Here we are storing the current message into a constant called message
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell//Here we are creating our tableViewCell and downcasting it as a MessageCell
        cell.label.text = message.body//Here we are passing data into our TableViewCell. indexPath.row gives us thwe row of the tableViewCell
        
        //This is a message from the current signed in user
        if message.sender == Auth.auth().currentUser?.email {
            cell.LeftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.MessageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        } else { //This is a message from another user
            cell.LeftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.MessageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        
        
        return cell
    }
}


