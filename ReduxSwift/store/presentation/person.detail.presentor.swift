//
//  HomePresentationAction.swift
//  ReduxSwift
//
//  Created by David Thorn on 07.09.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import UIKit

public let PRESENT_PERSON_DETAIL: String =  Person.Actions.DETAIL

fileprivate func present(with person: Person , using controller: UINavigationController) {
    let vc = PersonDetailViewController.instance(person: person)
    controller.pushViewController(vc, animated: true)
}

public func person_detail_present(with controller: UINavigationController) {
    
    subscribe(action: PRESENT_PERSON_DETAIL) { (decodable) in
        guard let person = decode(as: Person.self, data: decodable) else { return }
        present(with : person, using: controller)
        
        
    }
}


