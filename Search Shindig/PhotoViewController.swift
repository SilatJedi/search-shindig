//
//  PhotoViewController.swift
//  Search Shindig
//
//  Created by James Anderson on 1/31/17.
//  Copyright © 2017 James Anderson. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var photoUrlString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let photoUrl = URL(string: photoUrlString)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: photoUrl!)
            DispatchQueue.main.async {
                self.photoImageView.image = UIImage(data: data!)
            }
        }
    }
}
