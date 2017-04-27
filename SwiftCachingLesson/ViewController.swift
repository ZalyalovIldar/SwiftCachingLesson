//
//  ViewController.swift
//  SwiftCachingLesson
//
//  Created by Ildar Zalyalov on 26.04.17.
//  Copyright © 2017 ru.itisIosLab. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var session: URLSession!
    var task: URLSessionTask!
    var dataArr:[[String: Any]]!
    
    var cashing: NSCache<AnyObject, AnyObject>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dataArr = []
        cashing = NSCache()
        session = URLSession.shared
        
        task = session.downloadTask(with: URL(string:"https://itunes.apple.com/search?term=flappy&entity=software")!, completionHandler: { (location, responseData, error) in
            
            if location != nil{
                let data:Data! = try? Data(contentsOf: location!)
                do{
                    let dic = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as AnyObject
                    self.dataArr = dic.value(forKey : "results") as? [[String:Any]]
                    print("download done")
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                    
                }catch{
                    print("something went wrong, try again")
                }
            }
        })
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath)
        let urlStr = dataArr[indexPath.row]["artworkUrl60"] as! String
        let url = URL(string: urlStr)!

        cell.imageView?.sd_setImage(with: url)
//
//        if (cashing.object(forKey: indexPath.row as AnyObject) != nil) {
//            let image = cashing.object(forKey: indexPath.row as AnyObject) as! UIImage
//            cell.imageView?.image = image
//        }else{
//            task = session.downloadTask(with: url, completionHandler: { (lUrl, response, error) in
//                
//                let data:Data! = try? Data(contentsOf: url)
//                DispatchQueue.main.async(execute: {
//                    let image = UIImage(data: data)
//                    
//                    self.cashing.setObject(image!, forKey: indexPath.row as AnyObject )
//                })
//            })
//            
//            task.resume()
//        }
        return cell
        
    }
}

