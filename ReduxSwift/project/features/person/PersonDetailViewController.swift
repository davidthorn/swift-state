//
//  PersonDetailViewController.swift
//  ReduxSwift
//
//  Created by David Thorn on 08.09.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import UIKit

class PersonDetailViewController: UIViewController {

    var person: Person!
    
    @IBOutlet weak var personNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        personNameTextField.text = person.name
        personNameTextField.addTarget(self, action: #selector(personNameChanged), for: .editingChanged)
    }
    
    @objc fileprivate func personNameChanged() {
        person = Person.init(id: person.id, name: personNameTextField.text ?? "" )
        update(person: person)
    }
    
    fileprivate func update(person: Person) {
        person.persist()
    }
    
    @IBAction func updateAction(_ sender: Any) {
        personNameChanged()
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension PersonDetailViewController {
    static func instance(person: Person) -> PersonDetailViewController {
        let sb = UIStoryboard.init(name: "PersonDetail", bundle: Bundle.init(for: PersonDetailViewController.self))
        let vc = sb.instantiateInitialViewController() as! PersonDetailViewController
        vc.person = person
        return vc
    }
}
