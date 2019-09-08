//
//  ReduxHomeViewController.swift
//  ReduxSwift
//
//  Created by David Thorn on 07.09.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import UIKit

class ReduxHomeViewController: UIViewController {

    var viewModel: PeopleModel!
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.dataSource = self
     
        self.viewModel.load {
            self.tableview.reloadData()
        }
    }

}

extension ReduxHomeViewController {
    static func instance(viewModel: PeopleModel) -> ReduxHomeViewController {
        let sb = UIStoryboard.init(name: "ReduxHome", bundle: Bundle.init(for: ReduxHomeViewController.self))
        let vc = sb.instantiateInitialViewController() as! ReduxHomeViewController
        vc.viewModel = viewModel
        return vc
    }
}

extension ReduxHomeViewController: UITableViewDataSource {
    
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
