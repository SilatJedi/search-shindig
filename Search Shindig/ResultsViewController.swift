//
//  ResultsViewController.swift
//  Search Shindig
//
//  Created by James Anderson on 1/31/17.
//  Copyright © 2017 James Anderson. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var resultsTableView: UITableView!

    
    var tags:String = ""
    var photos = [PhotoModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: "tags") == nil {
            
            UserDefaults.standard.setValue(tags, forKey: "tags")
            
            getPhotoList()
        } else {
            tags = UserDefaults.standard.string(forKey: "tags")!
            
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResultsTableViewCell

        if photos.count > 0 {
            
            let photo:PhotoModel = photos[indexPath.row]
            
            let photoUrl = URL(string: "https://farm\(photo.getFarmId()).staticflickr.com/\(photo.getServerId())/\(photo.getPhotoId())_\(photo.getSecret())_s.jpg")
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: photoUrl!)
                DispatchQueue.main.async {
                    cell.cellImageView.image = UIImage(data: data!)
                }
            }
            
            cell.label.text = photo.getTitle()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if photos.count > 0 {
            let photoView = self.storyboard?.instantiateViewController(withIdentifier: "photo") as! PhotoViewController
            
            let photo:PhotoModel = photos[indexPath.row]
            
            photoView.photoUrlString = "https://farm\(photo.getFarmId()).staticflickr.com/\(photo.getServerId())/\(photo.getPhotoId())_\(photo.getSecret())_c.jpg"
            
            self.present(photoView,animated: true, completion: nil)
        }
    }
    
    func loadTable() {
        DispatchQueue.main.async(execute: {
            self.resultsTableView.reloadData()
            return
        })
    }
    
    
    
    
    
    
    
    
    //====================== API Functions====================
    func getURL(tags: String) -> String{
        let formattedTags = tags.replacingOccurrences(of: " ", with: "+")
        
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=1dd17dde0fed7286935d83875fcc17dd&per_page=25&format=json&nojsoncallback=1&content_type=1&tags=" + formattedTags
        
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
                                farmId: photoDict.value(forKey: "farm") as! Int,
                                serverId: photoDict.value(forKey: "server") as! String,
                                secret: photoDict.value(forKey: "secret") as! String,
                                title: photoDict.value(forKey: "title") as! String
                            )
                        )
                        
                        self.loadTable()
                    }
                } else {
                    
                    let alert = UIAlertController(title: "Uh-Oh", message: "Your search has yielded no results.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        
                        let searchView = self.storyboard?.instantiateViewController(withIdentifier: "search") as! ResultsViewController
                        
                        self.present(searchView,animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
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
