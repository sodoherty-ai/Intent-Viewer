//
//  ViewController.swift
//  Intent Viewer
//
//  Created by Simon O'Doherty on 28/02/2021.
//

import UIKit
import Assistant

class SettingsController: UIViewController {
    
    @IBOutlet weak var apikeyTextField: UITextField!
    @IBOutlet weak var endpointTextField: UITextField!
    @IBOutlet weak var versionTextField: UITextField!
    @IBOutlet weak var workspaceIDTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = UIColor.white
    }

    
    @IBAction func testButton(_ sender: UIButton) {
        K.api.version = versionTextField.text
        K.api.apikey = apikeyTextField.text
        K.api.endpoint = endpointTextField.text
        K.api.workspaceid = workspaceIDTextField.text
        
        var errors = [String]()
        if K.api.apikey == nil || K.api.apikey == "" { errors.append("No API Key") }
        if K.api.endpoint == nil || K.api.endpoint == "" { errors.append("No Endpoint") }
        if K.api.workspaceid == nil || K.api.workspaceid == "" { errors.append("No workspace ID")}
        
        if errors.count > 0 {
            errorAlert(errors)
            return
        }
        else if K.api.version == nil || K.api.version == "" {
            errors = ["Defaulting version to 2020-04-01"]
            errorAlert(errors)
            K.api.version = "2020-04-01"
            versionTextField.text = K.api.version
        }
        
        performSegue(withIdentifier: K.storyboard.intents, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

    func errorAlert(_ errors: [String]) {
        var errorText = ""
        for e in errors {
            errorText += "\(e)\n"
        }
        
        let alert = UIAlertController(title: "Error", message: errorText, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { _ in
            print(errorText)
        }
        alert.addAction(okAction)

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

