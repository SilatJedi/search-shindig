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
        
        if tags != "" {
            getPhotoList()
            tags = ""
            loadTable()
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
            
            let photoUrlString = "https://farm\(photo.getFarmId()).staticflickr.com/\(photo.getServerId())/\(photo.getPhotoId())_\(photo.getSecret())_s.jpg"
            
            print(photoUrlString)
            
            let Url = URL(string: photoUrlString)!
            
            let session = URLSession(configuration: .default)

            let downloadPicTask = session.dataTask(with: Url) { (data, response, error) in
                // The download has finished.
                if let e = error {
                    print("Error downloading picture: \(e)")
                } else {
                    // No errors found.

                    if let res = response as? HTTPURLResponse {
                        print("Downloaded picture with response code \(res.statusCode)")
                        if let imageData = data {

                            let image = UIImage(data: imageData)
                            
                            cell.cellImageView.image = image
                        } else {
                            print("Couldn't get image: Image is nil")
                        }
                    } else {
                        print("Couldn't get response code for some reason")
                    }
                }
            }
            
            downloadPicTask.resume()
            
            cell.label.text = photo.getTitle()
            
            //need an image here
    //        downloadImage(url: , imageView: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func loadTable() {
        DispatchQueue.main.async(execute: {
            self.resultsTableView.reloadData()
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
