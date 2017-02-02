//
//  SearchViewController.swift
//  Search Shindig
//
//  Created by James Anderson on 1/31/17.
//  Copyright © 2017 James Anderson. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate{

    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBAction func search(_ sender: Any) {
        if (searchTextField.text?.characters.count)! > 0 {
            let resultsView = self.storyboard?.instantiateViewController(withIdentifier: "results") as! ResultsViewController
        
            resultsView.tags = searchTextField.text!
            
            self.present(resultsView,animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Uh-oh!", message: "If you wish to search for nothing, then sit down and meditate for a while. Otherwise, enter a tag into the search field.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.becomeFirstResponder()
    }
    
    //dismiss soft keyboard when touch happens outside of a textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        searchButton.sendActions(for: .touchUpInside)
        
        return true
    }
}
