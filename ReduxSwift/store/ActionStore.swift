//
//  ActionStore.swift
//  ReduxSwift
//
//  Created by David Thorn on 07.09.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import Foundation

/// The main store that all subscribers, transformers are stored and controlled.
fileprivate var store: ActionStore = ActionStore.init()

/// All actions that the store understands and requires.
public typealias ACTION = String
public typealias ACTION_OBSERVER = (_ state: Decodable) -> Void
public typealias ERROR_OBSERVER = (id: OBSERVER_ID , handler: (_ error: Error) -> Void )
public typealias ACTION_TRANSFORMER = (id: TRANSFORMER_ID , handler: (_ state: Codable) -> Codable )
public typealias TRANSFORMER_ID = String
public typealias OBSERVER_ID = String

public struct EmptyParams: Codable{ public init(){} }

/// A packet that should be used to wrap all top level types from swift
public struct Packet<T: Codable>: Codable{
    public let item: T
    public init(item: T) {
        self.item = item
    }
    
    /// Encodes the item T to data
    /// This property will always return Data, it is the responsibility of
    /// the decoding end to determine if the packet stunk or not.
    public var encoded: Data {
        do {
            return try JSONEncoder.init().encode(self)
        } catch {
            return Data.init()
        }
    }
}

public enum PresentationType: String, Codable {
    case present
    case push
    case modal
}

public struct PresentationPacket<Model: Codable>: Codable{
    public let url: URL
    public let item: Model?
    public let type: PresentationType
    public init(url: URL, item: Model? , type: PresentationType = .push) {
        self.url = url
        self.item = item
        self.type = type
    }
    
    /// Encodes the item T to data
    /// This property will always return Data, it is the responsibility of
    /// the decoding end to determine if the packet stunk or not.
    public var encoded: Data {
        do {
            return try JSONEncoder.init().encode(self)
        } catch {
            return Data.init()
        }
    }
}

extension URL {
    public var packet: Packet<URL> { return Packet<URL>.init(item: self) }
}

/// Helper method to create a packet from a URL.
///
/// - Parameter url: URL
/// - Returns: Packet<URL>
public func packet(url: URL) -> Packet<URL> {
    return Packet<URL>.init(item: url)
}

/// Helper method that converts a URL to encoded Data.
///
/// - Parameter url: URL
/// - Returns: Data
public func packet(url: URL) -> Data {
    return packet(url: url).encoded
}

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
        self.initialiseObservers(action: action)
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
        addTransformer(action: action, transformer: transformer)
    }
    
    mutating func addTransformer(action: ACTION , transformer: ACTION_TRANSFORMER) {
        self.initialiseObservers(action: action)
        self.actionTransformers[action] = self.actionTransformers[action]?.filter{ $0.id != transformer.id }
        self.actionTransformers[action]?.append(transformer)
    }
    
    /// Initialises all observer arrays for the actions if it is nil
    ///
    /// - Parameter action: ACTION
    fileprivate mutating func initialiseObservers(action: ACTION) {
        if self.errorObservers[action] == nil { self.errorObservers[action] = [] }
        if self.actionTransformers[action] == nil { self.actionTransformers[action] = [] }
        if self.actionObservers[action] == nil { self.actionObservers[action] = [] }
    }
    
    /// Adds a subscriber for this action.
    ///
    /// - Parameters:
    ///   - action: ACTION The name of the action that should be subscribed to.
    ///   - error: ERROR_OBSERVER The handler that is called upon an action being dispatched.
    mutating func subscribe(action: ACTION , error: ERROR_OBSERVER) {
        self.initialiseObservers(action: action)
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
    /// If the first parameter is set to true then only the first subscriber will receive this data.
    ///
    /// - Parameters:
    ///   - action: ACTION The name of the action that this data should be dispatched to.
    ///   - data: Codable The codable data that will be provided to all subscribers of this action.
    ///   - first: Bool Indicates if the only the first subscriber should receive the data.
    func dispatch(action: ACTION , data: Codable, first: Bool = false) {
        
        let transformedData = transform(action: action, data: data)
        
        let observers = getActionObservers(action: action)
        
        switch first {
        case true:
            observers.first?(transformedData)
        case false:
            observers.forEach { observer in
                observer(transformedData)
            }
        }
        
    }
    
    /// Returns all action observers that have subscribed for this ACTION.
    ///
    /// - Parameter action: ACTION Name of the action.
    /// - Returns: [ACTION_OBSERVER]
    func getActionObservers(action: ACTION) -> [ACTION_OBSERVER] {
        guard let actionsObservers = actionObservers[action] else { return [] }
        return actionsObservers
    }
    
    /// Removes all action observers that have subscribed to this action.
    ///
    /// - Parameter action: ACTION
    mutating func removeAllActionObservers(action: ACTION) {
        self.actionObservers[action]?.removeAll()
    }
    
    /// Calls all transformers that have subscribed to this action.
    /// All transformers are then passed the data to transform it is required.
    /// The transformers will always be passed an already transformed data from a previous transformer.
    ///
    /// - Parameters:
    ///   - action: ACTION
    ///   - data: Codable
    /// - Returns: Codable
    func transform(action: ACTION , data: Codable) -> Codable {
        var transformedData = data
        if let transformers = actionTransformers[action] {
            transformedData = transformers.reduce(transformedData, { (_tData, transformer) -> Codable in
                return transformer.handler(_tData)
            })
        }
        return transformedData
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
    
    /// Adds an observer for the PRESENT action.
    /// - Note: Only one observer can be subscribed to the PRESENT action, therefore all others will be removed.
    ///
    /// - Parameter observer: @escaping ACTION_OBSERVER
    mutating func addPresentor(observer: @escaping ACTION_OBSERVER) {
        self.initialiseObservers(action: PRESENT)
        removeAllActionObservers(action: PRESENT)
        subscribe(action: PRESENT, observer: observer)
    }
    
}

/// Helper method to subscribe to this action.
/// The action observer will be called everytime dispatch is called with this action.
///
/// - Parameters:
///   - action: ACTION
///   - observer: @escaping ACTION_OBSERVER
public func subscribe(action: ACTION , observer: @escaping ACTION_OBSERVER) {
    store.subscribe(action: action, observer: observer)
}

/// Helper method to subscribe to this action.
/// This action transformer will be called everytime dispatch is called with this action.
/// The action transformer will be passed the data that has been dispatched.
/// The transformers are passed the data in the sequeunce that they subscribed.
///
/// - Parameters:
///   - action: ACTION
///   - transformer: ACTION_TRANSFORMER
public func subscribe(action: ACTION , transformer: ACTION_TRANSFORMER) {
    store.subscribe(action: action, transformer: transformer)
}

/// Dispatches this data to all observers and transformers that have subscribed to this action.
/// If the first parameter is set to true then only the first subscriber will receive this data.
///
/// - Parameters:
///   - action: ACTION The name of the action that this data should be dispatched to.
///   - data: Codable The codable data that will be provided to all subscribers of this action.
///   - first: Bool Indicates if the only the first subscriber should receive the data.
public func dispatch(action: ACTION , data: Codable, first: Bool = false) {
    store.dispatch(action: action, data: data, first: first)
}

public func dispatch(action: ACTION , error: Error) {
    store.dispatch(action: action, error: error)
}

public func decode<T: Decodable>(as type: T.Type , data: Decodable) -> T? {
    do {
        guard let data = data as? Data else { return nil }
        return try JSONDecoder.init().decode(type, from: data)
    } catch {
        return nil
    }
}

public func encode<T: Encodable>(type: T) -> Data? {
    do {
        return try JSONEncoder.init().encode(type)
    } catch {
        return nil
    }
}

/// Dispatches a PRESENT action contains the url packet to a presentor/coordinato
/// The URL should contain all information that the coordinator requires to present the correct feature.
/// The store will only dispatch this event once and that will be to the first subscriber that subscribed to PRESENT.
///
/// - Parameter url: Packet<URL> Information a coordinator uses to distinguish the feature to be presented.
public func coordinate<T: Codable>(model: PresentationPacket<T>) {
    dispatch(action: PRESENT, data: model.encoded, first: true)
}

public func addPresentor(observer: @escaping ACTION_OBSERVER) {
    store.addPresentor(observer: observer)
}
