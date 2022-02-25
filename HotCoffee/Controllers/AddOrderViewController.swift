//
//  AddOrderViewController.swift
//  HotCoffee
//
//  Created by riza erdi karakus on 25.02.2022.
//

import Foundation
import UIKit

protocol AddCoffeeOrderDelegate {
    func addCoffeeOrderViewControllerDidSave(order: Order, controller: UIViewController)
    func addCoffeeViewControllerDidClose(controller: UIViewController)
}

class AddOrderViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate:AddCoffeeOrderDelegate?
    
    private var vm = AddCoffeeOrderViewModel()
    
    private var coffeeSizesSegmentedControll: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
        //self.tableView.delegate = self
        //self.tableView.dataSource = self
    }
    
    private func setupUI(){
        self.coffeeSizesSegmentedControll = UISegmentedControl(items: self.vm.sizes)
        self.coffeeSizesSegmentedControll.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.coffeeSizesSegmentedControll)
        self.coffeeSizesSegmentedControll.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 20).isActive = true
        
        self.coffeeSizesSegmentedControll.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoffeeTypeTableViewCell", for: indexPath)
        cell.textLabel?.text = self.vm.types[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    @IBAction func close(){
        if let delegate = self.delegate {
            delegate.addCoffeeViewControllerDidClose(controller: self)
        }
    }
    
    @IBAction func save(){
        let name = self.nameTextField.text
        let email = self.emailTextField.text
        
        let selectedSize = self.coffeeSizesSegmentedControll.titleForSegment(at: self.coffeeSizesSegmentedControll.selectedSegmentIndex)
        
        guard let indexPath = self.tableView.indexPathForSelectedRow else {
            fatalError("Error in selecting coffee")
        }
        
        self.vm.name = name
        self.vm.email = email
        self.vm.selectedSize = selectedSize
        self.vm.selectedType = self.vm.types[indexPath.row]
        
        Webservice().load(resource: Order.create(vm: self.vm)) { result in
            switch result{
            case .success(let order):
                if let order = order, let delegate = self.delegate{
                    DispatchQueue.main.async {
                        delegate.addCoffeeOrderViewControllerDidSave(order: order, controller: self)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
}
