//
//  ViewController.swift
//  AMCreditCardDemo
//
//  Created by Artur Mkrtchyan on 12/6/17.
//  Copyright © 2017 Artur Mkrtchyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var creditCardView: AMCreditCardView!
    @IBOutlet weak var inputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func inputFieldEditingChanged(_ textField: UITextField) {
        if textField.placeholder == "CVV" {
            creditCardView.cvv = textField.text
        } else {
            creditCardView.cardNumber = textField.text
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.text = ""
        if textField.placeholder == "CVV" {
            textField.resignFirstResponder()
        }
        textField.placeholder = textField.placeholder == "CVV" ? "Card Number" : "CVV"
        creditCardView.flip()
        return true
    }
}

