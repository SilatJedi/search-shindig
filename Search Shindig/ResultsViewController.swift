//
//  ResultsViewController.swift
//  Search Shindig
//
//  Created by James Anderson on 1/31/17.
//  Copyright © 2017 James Anderson. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var tags:String = ""
    var photos = [PhotoModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tags != "" {
            getPhotoList()
        }
    }

    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        
        //need an image here
//        downloadImage(url: , imageView: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func load_table() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            return
        })
    }
    
    
    
    
    
    
    
    
    //====================== API Functions====================
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL, imageView: UIImageView) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    func getURL(tags: String) -> String{
        let formattedTags = tags.replacingOccurrences(of: " ", with: "+")
        
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=1dd17dde0fed7286935d83875fcc17dd&tags=" + formattedTags + "&per_page=25&format=json&nojsoncallback=1&content_type=1"
        
        return url
    }
    

    func getPhotoList() {
        let request = NSMutableURLRequest(url: URL(string: getURL(tags: tags))!)
        
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard data != nil else {
                print("no data was received: \(error)")
                
                let alert = UIAlertController(title: "Uh-Oh", message: "An error has occcured. Please, try again later.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                return
            }
        do {
        
            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] {
                
                print(json)
                
                let parentDict:NSDictionary = json["photos"] as! NSDictionary
                let photoArray:NSArray = parentDict.object(forKey: "photo") as! NSArray
                
                if parentDict["total"] as! String != "0" {
                    for i in 1...photoArray.count {
                        let photoDict = photoArray[i - 1] as! NSDictionary
                    
                        self.photos.append(
                            PhotoModel(
                                photoId: photoDict.value(forKey: "id") as! String,
                                farmId: photoDict.value(forKey: "farm") as! String,
                                serverId: photoDict.value(forKey: "server") as! String,
                                secret: photoDict.value(forKey: "secret") as! String
                            )
                        )
                        
                        
                        
                    }
                } else {
                    //need to alert user that tags yielded no results
                }
                print(photoArray)
                
            } else {
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                print("Error could not parse JSON: \(jsonStr)")
                
                let alert = UIAlertController(title: "Uh-Oh", message: "An error has occcured. Please, try again later.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            } catch let parseError {
                print(parseError)
                
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                print("Error could not parse JSON: '\(jsonStr)'")
                
                let alert = UIAlertController(title: "Uh-Oh", message: "An error has occcured. Please, try again later.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }.resume()
    }

    
    
}
