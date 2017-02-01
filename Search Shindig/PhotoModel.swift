//
//  PhotoModel.swift
//  Search Shindig
//
//  Created by James Anderson on 2/1/17.
//  Copyright © 2017 James Anderson. All rights reserved.
//

import Foundation

class PhotoModel {
    fileprivate var farmId = Int()
    fileprivate var serverId = String()
    fileprivate var photoId = String()
    fileprivate var secret = String()
    fileprivate var title = String()
    
    init(photoId: String, farmId: Int, serverId: String, secret: String, title: String) {
        self.photoId = photoId
        self.farmId = farmId
        self.serverId = serverId
        self.secret = secret
        self.title = title
    }
    
    func getPhotoId() -> String {
        return photoId
    }
    
    func getFarmId() -> String {
        return "\(farmId)"
    }
    
    func getServerId() -> String {
        return serverId
    }
    
    func getSecret() -> String {
        return secret
    }
    
    func getTitle() -> String {
        return title
    }
}
