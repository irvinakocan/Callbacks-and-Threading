//
//  ViewController.swift
//  Callbacks and Threading
//
//  Created by Macbook Air 2017 on 5. 2. 2024..
//

import UIKit

class ViewController: UIViewController {
    
    var users = [String]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        getUsers(completion: { [weak self] result, data, error in
            if let data = data as? [String] {
                if result && error == nil {
                    self?.users.append(contentsOf: data)
                    
                    // As we are inside background thread, we have to come back to the main thread (URLSession does this for us by itself)
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }
        })
        
        setTableView()
    }
    
    private func getUsers(completion: @escaping (Bool, Any?, Error?) -> Void) {
        
        // Background thread / Global asynchronous call
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
            guard let path = Bundle.main.path(forResource: "someJSON", ofType: "txt") else {
                return
            }
            
            let url = URL(fileURLWithPath: path)
            
            do {
                let data = try Data(contentsOf: url)
                let json = try JSONSerialization.jsonObject(with: data)
                guard let array = json as? [[String: Any]] else { return }
                
                var names = [String]()
                for user in array {
                    names.append(user["name"] as? String ?? "")
                }
                
                // We can return to the main thread also here
                completion(true, names, nil)
            }
            catch {
                // And also here
                completion(false, nil, "was not possible to get data" as? Error)
            }
        })
    }
    
    private func setTableView() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row]
        cell.textLabel?.textColor = .white
        return cell
    }
}

