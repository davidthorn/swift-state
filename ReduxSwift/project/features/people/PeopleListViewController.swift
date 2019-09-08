//
//  PeopleListViewController.swift
//  ReduxSwift
//
//  Created by David Thorn on 07.09.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import UIKit

class PeopleListViewController: UIViewController {

    var viewModel: PeopleModel!
    var didPresent: Bool = false
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.dataSource = self
        self.tableview.delegate = self
     
        self.viewModel.load {
            self.tableview.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard didPresent else { return }
        didPresent = false
        self.viewModel.load {
            self.tableview.reloadData()
        }
    }
    
}

extension PeopleListViewController {
    static func instance(viewModel: PeopleModel) -> PeopleListViewController {
        let sb = UIStoryboard.init(name: "PeopleList", bundle: Bundle.init(for: PeopleListViewController.self))
        let vc = sb.instantiateInitialViewController() as! PeopleListViewController
        vc.viewModel = viewModel
        return vc
    }
}

extension PeopleListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.get(index: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Cell \(item.name)"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
}

extension PeopleListViewController: UITableViewDelegate {
    
    /// Coordinates to the person detail view upon a person cell being selected.
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: IndexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = viewModel.get(index: indexPath)
        let data = try! JSONEncoder.init().encode(person)
        let presentation = PresentationPacket<Data>.init(url: URL(string: "app://people")!, item: data, action: Person.Actions.DETAIL , type: .modal)
        didPresent = true
        coordinate(model: presentation)
    }
    
}
