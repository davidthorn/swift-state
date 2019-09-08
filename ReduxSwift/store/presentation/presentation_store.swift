//
//  presentation_store.swift
//  ReduxSwift
//
//  Created by David Thorn on 08.09.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import UIKit

fileprivate var controller: UINavigationController?

public func presentation_store_initialise(controller: UINavigationController) {
 
    person_detail_present(with: controller)
    
    addPresentor { (presentationPacket: Decodable) in
        
        if let anyFeature = decodePresentationPacket(as: Data.self, data: presentationPacket) {
            
            switch anyFeature.type {
            case .modal:
                guard let item = anyFeature.item else { return }
                dispatch(action: anyFeature.action, data: item)
            case .present:
                guard let item = anyFeature.item else { return }
                dispatch(action: anyFeature.action, data: item)
            case .push:
                guard let item = anyFeature.item else { return }
                dispatch(action: anyFeature.action, data: item)
            }
        }
    }
    
}
