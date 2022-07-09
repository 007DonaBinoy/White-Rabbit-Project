//
//  ViewController.swift
//  Machine Test
//
//  Created by SITS on 09/07/22.
//

import UIKit
import Alamofire
import CoreData

class ViewController: UIViewController {
    
    var url = "https://www.mocky.io/v2/5d565297300000680030a986"
    var coreDataValues = [Int:[String:Any]]()
    var employeNameArr = [String]()
    var imageArr = [String]()
    var companyNameArr = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if UserDefaults.standard.string(forKey: "isDataPresent") == nil {
            employeeDetails()
        } else {
            retriveData()
        }
        
    }
    
    func employeeDetails() {
        AF.request(url, method: .get).responseJSON { [self] response in
            switch response.result {
            case .success(_):
                let dict = response.value as? [[String:Any]]
                print("dict : \(dict as Any)")
                if dict == nil {
                } else {
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    let entity = NSEntityDescription.entity(forEntityName: "Employe", in: context)
                    
                    
                    for i in 0...dict!.count - 1 {
                        let newUser = NSManagedObject(entity: entity!, insertInto: context)
                        print("i count : \(i)")
                        newUser.setValue("\(dict![i]["id"] ?? "")", forKey: "id")
                        newUser.setValue("\(dict![i]["name"] ?? "")", forKey: "name")
                        newUser.setValue("\(dict![i]["username"] ?? "")", forKey: "username")
                        newUser.setValue("\(dict![i]["email"] ?? "")", forKey: "email")
                        newUser.setValue("\(dict![i]["profile_image"] ?? "")", forKey: "profile_image")
                        newUser.setValue("\(dict![i]["phone"] ?? "")", forKey: "phone")
                        newUser.setValue("\(dict![i]["website"] ?? "")", forKey: "website")
                        
                        let address = dict![i]["address"] as! [String:Any]
                        newUser.setValue("\(address["street"] ?? "")", forKey: "street")
                        newUser.setValue("\(address["suite"] ?? "")", forKey: "suite")
                        newUser.setValue("\(address["zipcode"] ?? "")", forKey: "zipcode")
                        newUser.setValue("\(address["city"] ?? "")", forKey: "city")
                        
                        let locations = address["geo"] as! [String:Any]
                        newUser.setValue("\(locations["lat"] ?? "")", forKey: "lat")
                        newUser.setValue("\(locations["lng"] ?? "")", forKey: "lng")
                        
                        if dict![i]["company"] is NSNull == false {
                            let company = dict![i]["company"] as! [String:Any]
                            newUser.setValue("\(company["name"] ?? "")", forKey: "cname")
                            newUser.setValue("\(company["catchPhrase"] ?? "")", forKey: "catchPhrase")
                            newUser.setValue("\(company["bs"] ?? "")", forKey: "bs")
                        }
                        
                    }
                    do {
                        try context.save()
                        
                    } catch {
                        print("Failed saving")
                    }
                    let coreDataStatus = "success"
                    UserDefaults.standard.set(coreDataStatus, forKey: "isDataPresent")
                    DispatchQueue.main.async {
                        self.retriveData()
                    }
                    
                }
            case .failure(_):
                return
            }
        }
    }
    
    
    func retriveData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Employe")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "name") as! String)
                employeNameArr.append(data.value(forKey: "name") as? String ?? "")
                companyNameArr.append(data.value(forKey: "cname") as? String ?? "")
                imageArr.append(data.value(forKey: "profile_image") as? String ?? "")
                self.tableView.reloadData()
            }
            
        } catch {
            
            print(error)
        }
    }
    
}

extension  ViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeNameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.companyNameLbl.text = companyNameArr[indexPath.row]
        cell.nameLbl.text = employeNameArr[indexPath.row]
        cell.employeImage.loadFrom(URLAddress: imageArr[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension UIImageView {
    func loadFrom(URLAddress: String) {
        guard let url = URL(string: URLAddress) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                    self?.image = loadedImage
                }
            }
        }
    }
}


class TableViewCell : UITableViewCell {
    
    @IBOutlet weak var companyNameLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var employeImage: UIImageView!
}
