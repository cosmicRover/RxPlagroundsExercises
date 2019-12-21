//
//  ViewController.swift
//  RxSwift_Exercise
//
//  Created by Joy Paul on 12/12/19.
//  Copyright © 2019 Joy Paul. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {
    
    let text:UITextField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(text)
        text.backgroundColor = UIColor.gray
        text.delegate = self
    }

}
extension ViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(text.text!) //TODO call Rx here
        return true
    }
}

