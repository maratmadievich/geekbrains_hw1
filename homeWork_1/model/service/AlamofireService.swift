//
//  AlamofireService.swift
//  homeWork_1
//
//  Created by Admin on 06.11.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol VkApiFriendsDelegate {
    
    func returnFriends(_ friends: [VkFriend])
}

protocol VkApiGroupsDelegate {
    
    func returnGroups(_ groups: [VkGroup])
    func returnLeave(_ gid: Int)
    func returnLeave(_ error: String)
    func returnJoin(_ gid: Int)
    func returnJoin(_ error: String)
}

protocol VkApiPhotosDelegate {
    
    func returnPhotos(_ photos: [VkPhoto])
}

protocol VkApiFeedsDelegate {
    
    func returnFeeds(_ feeds: [VkFeed])
}

protocol VkApiCommentsDelegate {
    
    func returnComments(_ comments: [VkComment])
}


class AlamofireService {
    
    static let instance = AlamofireService()
    private init(){}

    
    // //Друзья
    func getFriends(delegate: VkApiFriendsDelegate) {
        let method = "friends.get"
        let fullRow = "\(GlobalConstants.vkApi)\(method)"
        let params: Parameters = [
            "access_token": Session.instance.token,
            "fields": "id,nickname,photo_100",
            "v": "3.0",
        ]
        
        Alamofire.request(fullRow, method: .get, parameters: params)
            .responseJSON { response in
                delegate.returnFriends(
                    VkResponseParser.instance.parseFriends(
                        result: response.result))
                
        }
    }
    
    
    // //Группы
    func getGroups(delegate: VkApiGroupsDelegate) {
        let method = "groups.get"
        let fullRow = "\(GlobalConstants.vkApi)\(method)"//&v5.87
        let params: Parameters = [
            "access_token": Session.instance.token,
            "fields": "id,name",
            "extended": "1",
            "v": "3.0",
            "count":"50"
        ]
        
        Alamofire.request(fullRow, method: .get, parameters: params)
            .responseJSON { response in
                delegate.returnGroups(
                    VkResponseParser.instance.parseGroups(
                        result: response.result, isSearched: false))
        }
    }
    
    
    func leaveGroup(gid: Int, delegate: VkApiGroupsDelegate) {
        let method = "groups.leave"
        let fullRow = "\(GlobalConstants.vkApi)\(method)"//&v5.87
        let params: Parameters = [
            "access_token": Session.instance.token,
            "group_id": "\(gid)",
            "v": "3.0"
        ]
        
        Alamofire.request(fullRow, method: .get, parameters: params)
            .responseJSON { response in
                if VkResponseParser.instance.parseJoinLeaveGroup(result: response.result) {
                    delegate.returnLeave(gid)
                } else {
                    delegate.returnLeave("В ходе запроса произошла ошибка")
                }
        }
    }
    
    
    func joinGroup(gid: Int, delegate: VkApiGroupsDelegate) {
        let method = "groups.join"
        let fullRow = "\(GlobalConstants.vkApi)\(method)"//&v5.87
        let params: Parameters = [
            "access_token": Session.instance.token,
            "group_id": "\(gid)",
            "v": "3.0"
        ]
        
        Alamofire.request(fullRow, method: .get, parameters: params)
            .responseJSON { response in
                if VkResponseParser.instance.parseJoinLeaveGroup(result: response.result) {
                    delegate.returnJoin(gid)
                } else {
                    delegate.returnJoin("В ходе запроса произошла ошибка")
                }
        }
    }
    
    
    // //Группы Поиск
    func searchGroups(search: String, delegate: VkApiGroupsDelegate) {
        let method = "groups.search"
        let fullRow = "\(GlobalConstants.vkApi)\(method)"//&v5.87
        let params: Parameters = [
            "access_token": Session.instance.token,
            "q": search,
            "extended": "1",
            "sort": "2",
            "v": "3.0"
        ]
        Alamofire.request(fullRow, method: .get, parameters: params)
            .responseJSON { response in
                delegate.returnGroups(
                    VkResponseParser.instance.parseGroups(
                        result: response.result, isSearched: true))
        }
    }
    
    
    func getPhotos(delegate: VkApiPhotosDelegate) {
        let method = "photos.getAll"
        let fullRow = "\(GlobalConstants.vkApi)\(method)"//&v5.87
        
        let params: Parameters = [
            "access_token": Session.instance.token,
            "extended": "1",
            "v": "3.0",
            "count":"100"
        ]
        
        Alamofire.request(fullRow, method: .get, parameters: params)
            .responseJSON { response in
                delegate.returnPhotos(
                    VkResponseParser.instance.parsePhotos(
                        result: response.result))
        }
    }
    
    func getPhotosBy(_ id: Int, delegate: VkApiPhotosDelegate) {
        let method = "photos.getAll"
        let fullRow = "\(GlobalConstants.vkApi)\(method)"//&v5.87
        
        let params: Parameters = [
            "access_token": Session.instance.token,
            "extended": "1",
            "v": "3.0",
            "owner_id":"\(id)",
            "count":"100"//,
            //            "album_id":"saved"
        ]
        
        Alamofire.request(fullRow, method: .get, parameters: params)
            .responseJSON { response in
                delegate.returnPhotos(
                    VkResponseParser.instance.parsePhotos(
                        result: response.result))
        }
    }
    
    
    func getNews(startFrom: String, delegate: VkApiFeedsDelegate) {
        let method = "newsfeed.get"
        let fullRow = "\(GlobalConstants.vkApi)\(method)"
        let params: Parameters = [
            "access_token": Session.instance.token,
            "filters": "post",
            "v": "5.87",
            "count":"20",
            "start_from":"\(startFrom)"
//            "end_time":"\(1)"
        ]
        
        Alamofire.request(fullRow, method: .get, parameters: params)
            .responseJSON { response in
                delegate.returnFeeds(VkResponseParser.instance.parseNews(result: response.result))
        }
    }
    
    
    func getComments(ownerId: Int, postId: Int, delegate: VkApiCommentsDelegate) {
        //delegate: VkApiFeedsDelegate) {
        let method = "wall.getComments"
        let fullRow = "\(GlobalConstants.vkApi)\(method)"
        let params: Parameters = [
            "access_token": Session.instance.token,
            "filters": "post",
            "v": "5.87",
            "count":"50",
            "sort":"desc",
            "need_likes":"1",
            "extended":"1",
            "owner_id":"\(ownerId)",
            "post_id":"\(postId)"
        ]
        
        Alamofire.request(fullRow, method: .get, parameters: params)
            .responseJSON { response in
                print(response.result)
                delegate.returnComments(VkResponseParser.instance.parseComments(result: response.result))
        }
    }
    
}

