//
//  transformer_store.swift
//  ReduxSwift
//
//  Created by David Thorn on 08.09.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import Foundation

public func transformer_store_initialise() {
    
    subscribe(action: "PEOPLE_ALL_ACTION", transformer: (id: UUID.init().uuidString , handler: { data in
        print("transform called for people all")
        return data
    }))
    
}
