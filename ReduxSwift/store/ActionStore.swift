//
//  ActionStore.swift
//  ReduxSwift
//
//  Created by David Thorn on 07.09.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import Foundation

public typealias ACTION = String
public typealias ACTION_OBSERVER = (_ state: Decodable) -> Void
public typealias ERROR_OBSERVER = (id: OBSERVER_ID , handler: (_ error: Error) -> Void )
public typealias ACTION_TRANSFORMER = (id: TRANSFORMER_ID , handler: (_ state: Codable) -> Codable )
public typealias TRANSFORMER_ID = String
public typealias OBSERVER_ID = String

public struct EmptyParams: Codable{ public init(){} }

fileprivate struct ActionStore {
    
    var actionObservers: [ACTION:[ACTION_OBSERVER]] = [:]
    var actionTransformers: [ACTION:[ACTION_TRANSFORMER]] = [:]
    var errorObservers: [ACTION:[ERROR_OBSERVER]] = [:]
    
    init() { }
    
    /// Adds a subscriber to the actions observers lists to be called every time an action is dispatched
    /// using this key.
    ///
    /// - Parameters:
    ///   - action: ACTION The name of the action that should be subscribed to.
    ///   - observer: @escaping ACTION_OBSERVER
    mutating func subscribe(action: ACTION , observer: @escaping ACTION_OBSERVER) {
        
        if self.actionObservers[action] == nil {
           self.actionObservers[action] = []
        }
    
        self.actionObservers[action]?.append(observer)
    }
    
    /// Adds a subscriber for this action.
    /// The transformer that is provided the data for this action. The transformer can create a new version
    /// of the data and then return or if no changes are required the transformer should return the original data.
    ///
    /// - Parameters:
    ///   - action: ACTION The name of the action that should be subscribed to.
    ///   - transformer: ACTION_TRANSFORMER
    mutating func subscribe(action: ACTION , transformer: ACTION_TRANSFORMER) {
        
        if self.actionTransformers[action] == nil {
            self.actionTransformers[action] = []
        }
   
        self.actionTransformers[action] = self.actionTransformers[action]?.filter{ $0.id != transformer.id }
        
        self.actionTransformers[action]?.append(transformer)
    }
    
    /// Adds a subscriber for this action.
    ///
    /// - Parameters:
    ///   - action: ACTION The name of the action that should be subscribed to.
    ///   - error: ERROR_OBSERVER The handler that is called upon an action being dispatched.
    mutating func subscribe(action: ACTION , error: ERROR_OBSERVER) {
        
        if self.errorObservers[action] == nil {
            self.errorObservers[action] = []
        }
        
        self.errorObservers[action] = self.errorObservers[action]?.filter{ $0.id != error.id }
        
        self.errorObservers[action]?.append(error)
    }
    
    /// Removes a transformer handler for an action.
    ///
    /// - Parameters:
    ///   - transformer: TRANSFORMER_ID The id of the transformer that should be removed for this action
    ///   - action: ACTION The action for this transformer.
    mutating func remove(transformer: TRANSFORMER_ID , action: ACTION) {
        guard let transformers = actionTransformers[action] else { return }
        self.actionTransformers[action] = transformers.filter{ $0.id == transformer }
    }
    
    /// Removes an error handler for an observer id
    ///
    /// - Parameters:
    ///   - error: OBSERVER_ID The id of the error observer that had previously subscribed to this action.
    ///   - action: ACTION The action name for this error observer.
    mutating func remove(error: OBSERVER_ID , action: ACTION) {
        guard let errors = errorObservers[action] else { return }
        self.errorObservers[action] = errors.filter{ $0.id == error }
    }
    
    /// Dispatches this data to all observers and transformers that have subscribed to this action.
    ///
    /// - Parameters:
    ///   - action: ACTION The name of the action that this data should be dispatched to.
    ///   - data: Codable The codable data that will be provided to all subscribers of this action.
    func dispatch(action: ACTION , data: Codable) {
        
        var transformedData = data
        
        if let transformers = actionTransformers[action] {
            transformedData = transformers.reduce(transformedData, { (_tData, transformer) -> Codable in
                return transformer.handler(_tData)
            })
        }
        
        guard let actionsObservers = actionObservers[action] else{ return }
        actionsObservers.forEach { observer in
            observer(transformedData)
        }
    }
    
    /// Dispatches this error to all observers that have subscribed to this action.
    ///
    /// - Parameters:
    ///   - action: ACTION The name of the action that this error should be dispatched to.
    ///   - error: The error that will be provided to all subscribers of this action.
    func dispatch(action: ACTION , error: Error) {
        
        guard let errorObservers = errorObservers[action] else{ return }
        errorObservers.forEach { observer in
            observer.handler(error)
        }
    }
    
}

fileprivate var store: ActionStore = ActionStore.init()

public func subscribe(action: ACTION , observer: @escaping ACTION_OBSERVER) {
    store.subscribe(action: action, observer: observer)
}

public func subscribe(action: ACTION , transformer: ACTION_TRANSFORMER) {
    store.subscribe(action: action, transformer: transformer)
}

/// Dispatches action to all subscribers.
/// All subscribers of this action prior to being dispatched will be
/// passed the data as their observers param.
///
/// - Parameters:
///   - action: REDUX_ACTION A string representing the action.
///   - data: The data passed must comply to codable so that it can be decoded, encoded on both sides.
public func dispatch(action: ACTION , data: Codable) {
    store.dispatch(action: action, data: data)
}

public func dispatch(action: ACTION , error: Error) {
    store.dispatch(action: action, error: error)
}
