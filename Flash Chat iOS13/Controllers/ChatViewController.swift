

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = [
        //        Message(sender: "fimi", body: "Hey Malik how is it going?"),
        //        Message(sender: "Malik", body: "same circus different clowns"),
        //        Message(sender: "fimi", body: "Keep pushing G!, repetition is the key to mastery."),
        //        Message(sender: "Malik", body: "Word!")
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true
        
        //Register Table view
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()
        
    }
    
    func loadMessages() {
        
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { (querySnapshot, error) in
            self.messages = []
            
            if let e = error {
                print("There was an issue saving data to firestore, \(e)")
            } else {
                // Tap into query  snapshot and get data
                if let snapshotDocuments = querySnapshot?.documents {
                    // loop throught documents snapshot and  tap into data
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let sender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: sender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            // tap into table view and reload data
                            
                            // because .getDocuments happens in a closure, in the (background), we fetch the Dispatch.main in the for ground to update the data
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                //method to scroll to the bottom of the table view when a new messge is added
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        // get the message from the text field
        // if? there a current user, get the email and save to message sender
        //next send data to fireStore
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {

            // Data Dictoinary
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: messageSender, K.FStore.bodyField: messageBody,
                K.FStore.dateField: Date().timeIntervalSince1970
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("Successfully saved data.")
                    
                    DispatchQueue.main.async{
                        self.messageTextfield.text = ""
                        //so it happens on the main thread and not the bg thread *Code in Closure*
                    }

                }
            }
            
        }
        
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
}

// that data source is responsible for porpulating the table view
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // creates the number of cells that match the number of messages
        return messages.count
    }
    
    
    // Method gets called as many times as there are cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // use a message object to propulate the cell
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell     // as! key word cast as the message cell class
        // after creating message obj chang messages[indexPath.row].body to message.body
        cell.label.text = message.body
        
        // check if message is from current user
        if message.sender == Auth.auth().currentUser?.email {
            // hide the other users cell
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.blue)
            cell.label.textColor = UIColor(named: K.BrandColors.lighBlue)
        }
        // if message is from another sender
        else{
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
    
        
        
        return cell
    }
}

