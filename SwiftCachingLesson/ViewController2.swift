//
//  ViewController2.swift
//  SwiftCachingLesson
//
//  Created by Ilyas on 02.05.17.
//  Copyright © 2017 ru.itisIosLab. All rights reserved.
//

import UIKit

class ViewController2: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var changeCacheSwitch: UISwitch!
    var cachingManager:CacheManagerProtocol!
    let reuseIdentifier = "Cell"

    var session: URLSession!
    var task: URLSessionTask!
    var dataArr:[[String: Any]]!
    let url = "https://itunes.apple.com/search?term=flappy&entity=software"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        changeCacheSwitch.addTarget(self, action: #selector(cacheMethodChange), for: .touchUpInside)
        
        cachingManager = CacheManager()
        cachingManager.setNSCache(status: changeCacheSwitch.isOn)
        
        // Do any additional setup after loading the view, typically from a nib.
        dataArr = []
        session = URLSession.shared
        
        
        task = session.downloadTask(with: URL(string:"https://itunes.apple.com/search?term=flappy&entity=software")!, completionHandler: { (location, responseData, error) in
            
            if location != nil{
                let data:Data! = try? Data(contentsOf: location!)
                do{
                    let dic = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as AnyObject
                    self.dataArr = dic.value(forKey : "results") as? [[String:Any]]
                    print("download done")
                    DispatchQueue.main.async(execute: {
                        self.collectionView.reloadData()
                    })
                    
                }catch{
                    print("something went wrong, try again")
                }
            }
        })
        task.resume()
    }

    func cacheMethodChange() -> Void {
        if changeCacheSwitch.isOn {
            cachingManager.setNSCache(status: changeCacheSwitch.isOn)
            
        }else{
            cachingManager.setNSCache(status: !changeCacheSwitch.isOn)
        }
        collectionView.reloadData()
    }
}

extension ViewController2: UICollectionViewDataSource, UICollectionViewDelegate{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        let key = "\(indexPath.row)"
        
        let urlStr = dataArr[indexPath.row]["artworkUrl60"] as! String
        let textStr = dataArr[indexPath.row]["trackCensoredName"] as! String
        let url = URL(string: urlStr)!

        cachingManager.add(key: key, url: url, text: textStr) { (imageBlock, stringBlock) in
            cell.cellImageView.sd_setImage(with: url)
            cell.cellLabel.text = stringBlock
        }
        
        
        
  
        return cell
    }
}
