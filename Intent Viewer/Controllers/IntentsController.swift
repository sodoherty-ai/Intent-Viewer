//
//  IntentsController.swift
//  Intent Viewer
//
//  Created by Simon O'Doherty on 28/02/2021.
//

import UIKit
import Assistant
import ChameleonFramework

class IntentsController: UITableViewController {

    @IBOutlet var intentTable: UITableView!
    
    var intentArray = [String]()
    var intentCollection: IntentCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        intentTable.delegate = self
        intentTable.allowsSelection = false
        
        loadIntents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Loading"
    }

    func loadIntents() {
        let authenticator = WatsonIAMAuthenticator(apiKey: K.api.apikey!)
        let assistant = Assistant(version: K.api.version!, authenticator: authenticator)
        assistant.serviceURL = K.api.endpoint!

        assistant.listIntents(workspaceID: K.api.workspaceid!, export: true, includeCount: true) { response, error in
            guard let intents = response?.result else {
                print(error?.localizedDescription ?? "unknown error")
                return
            }

            self.processIntents(intents)
        }
    }
    
    func processIntents(_ intentCollection: IntentCollection) {
        self.intentCollection = intentCollection
        
        intentArray = [String]()
        for intent in intentCollection.intents {
            intentArray.append("\(K.intentLabel) \(intent.intent)")
            
            if let examples = intent.examples {
                for example in examples {
                    intentArray.append(example.text)
                }
            }
            
        }
        
        DispatchQueue.main.async {
            self.navigationItem.title = "Intents"
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func arPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.storyboard.arView, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ARViewController
        
        if let collection = intentCollection?.intents {
            for intent in collection {
                var ex = [String]()
                if let examples = intent.examples {
                    for i in 0..<examples.count {
                        ex.append(examples[i].text)
                    }
                }
                
                let node = IntentData(intent: intent.intent, examples: ex)
                destinationVC.intents.append(node)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intentArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.intentCell, for: indexPath)

        let text = intentArray[indexPath.row]

        if text.starts(with: K.intentLabel) {
            cell.backgroundColor = K.color.intentbg
            cell.textLabel!.text = text.replacingOccurrences(of: K.intentLabel, with: "")
            cell.textLabel!.textColor = K.color.intentfg
        }
        else {
            cell.textLabel!.text = text
            cell.backgroundColor = K.color.examplebg
            cell.textLabel!.textColor = K.color.examplefg
        }
        
        return cell
    }
    
}
