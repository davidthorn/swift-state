//
//  PeopleStore.swift
//  ReduxSwift
//
//  Created by David Thorn on 07.09.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import Foundation

fileprivate var people: [Person] = [
    .init(id: UUID.init().uuidString, name: "David"),
    .init(id: UUID.init().uuidString, name: "Giannis"),
    .init(id: UUID.init().uuidString, name: "Fabio")
]

public struct Person: Codable {
    
    public struct Actions {
        public static let DETAIL: String = "PERSON.DETAIL.ACTION"
        public static let UPDATE: String = "PERSON.UPDATE.ACTION"
        public static let DELETE: String = "PERSON.DELETE.ACTION"
        public static let CREATE: String = "PERSON.CREATE.ACTION"
    }
    
    public let id: String
    public let name: String
    
    public init(id: String , name: String) {
        self.id = id
        self.name = name
    }
    
    public static func decodes(with packetData: Decodable) -> Bool {
        return packet(contains: Person.self, data: packetData)
    }
    
    public static func decode(data: Decodable) -> PresentationPacket<Person>? {
        return decodePresentationPacket(as: Person.self, data: data)
    }
    
    public static func decode(data: Decodable) -> PresentationPacket<Data>? {
        return decodePresentationPacket(as: Data.self, data: data)
    }
    
    public func persist() {
        guard let data = encodeModel(type: self) else { return }
        dispatch(action: Person.Actions.UPDATE, data: data)
    }
}

fileprivate let PEOPLE_ERROR_ALL_ACTION = "PEOPLE_ERROR_ALL_ACTION"

/// Responds to PEOPLE_GET_ALL_ACTION
public func people_store_register() {
    subscribe(action: PeopleModel.GET_ALL_ACTION , observer: PeopleModel.sendAll)
    subscribe(action: Person.Actions.UPDATE, observer: PeopleModel.update)
    subscribe(action: Person.Actions.DELETE, observer: PeopleModel.delete)
}

fileprivate func encodePeople(people: [Person] ) throws -> Data {
    return try JSONEncoder.init().encode(people)
}

final public class PeopleModel {
    
    public static let GET_ALL_ACTION: String = "PEOPLE.GET_ALL.ACTION"
    public static let ALL_ACTION: String = "PEOPLE.ALL.ACTION"
    
    public typealias Item = Person
    
    private var items: [Item]
    
    public var numberOfItems: Int {
        return items.count
    }
    
    public init(items: [Item]) {
        self.items = items
    }
    
    public func get(index: IndexPath) -> Item {
        return items[index.row]
    }
    
    public func load(completion: @escaping () -> Void) {
        getAll { (people) in
            self.items = people
            completion()
        }
    }
    
}

extension PeopleModel {
    
    fileprivate var ERROR_ACTION: String {
        return "PEOPLE_ERROR_ALL_ACTION"
    }
    
    fileprivate func getAll(completion: @escaping (_ items: [Person]) -> Void) {
        subscribe(action: PeopleModel.ALL_ACTION) { (decodable) in
            
            do {
                guard let data = decodable as? Data else { return }
                let people = try JSONDecoder.init().decode([Person].self, from: data)
                completion(people)
            } catch {
                dispatch(action: self.ERROR_ACTION, error: NSError.init())
            }
        }
        dispatch(action: PeopleModel.GET_ALL_ACTION, data: EmptyParams.init())
    }
    
    fileprivate static func update(_ state: Decodable) {
        guard let data = state as? Data else { return }
        guard let person = decode(as: Person.self, data: data) else { return }
        people = people.map{ $0.id != person.id ? $0 : person}
    }
    
    fileprivate static func sendAll(_ state: Decodable) -> Void {
        
        do {
            dispatch(action: PeopleModel.ALL_ACTION, data: try encodePeople(people: people))
        } catch let error {
            dispatch(action: PEOPLE_ERROR_ALL_ACTION, error: error)
        }
    }

    fileprivate static func delete(_ state: Decodable) {
        guard let data = state as? Data else { return }
        guard let person = decode(as: Person.self, data: data) else { return }
        people = people.filter{ $0.id != person.id}
    }
}
