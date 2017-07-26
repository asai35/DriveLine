//
//  WebserviceUtil.swift
//  Code Clobber
//
//  Created by Abdul Wahib.
//  Copyright © 2017 CodeClobber. All rights reserved.
//

import Foundation
import AFNetworking

class WebserviceUtil {
    // MARK: Get Methods
    class func callGet(httpRequest url: String, params: [String: Any]?, success: @escaping ((Any?)) -> Void ,failure: @escaping ((Error)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        manager.responseSerializer.acceptableContentTypes?.insert("text/xml")
        
        manager.get(
            url,
            parameters: params,
            progress: nil,
            success: { (task, response) in
                success(response)
        }) { (task, error) in
            failure(error)
        }
    }
    
    class func callGet(httpRequest url: String, header: [String: String],params: [String: Any]?, success: @escaping ((Any?)) -> Void ,failure: @escaping ((Error)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        for (k,v) in header {
            manager.requestSerializer.setValue(v, forHTTPHeaderField: k)
        }
        
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        manager.responseSerializer.acceptableContentTypes?.insert("text/xml")
        
        manager.get(
            url,
            parameters: params,
            progress: nil,
            success: { (task, response) in
                success(response)
        }) { (task, error) in
            failure(error)
        }
    }
    
    // MARK: Post Methods
    class func callPost(httpRequest url: String, params: [String: Any]?, success: @escaping ((Any?)) -> Void ,failure: @escaping ((Error)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        manager.responseSerializer.acceptableContentTypes?.insert("text/xml")
        
        manager.post(
            url,
            parameters: params,
            progress: nil,
            success: { (task, response) -> Void in
                success(response)
        }) { (task, error) -> Void in
            failure(error)
        }
        
    }
    
    class func callPost(httpRequest url: String, header: [String: String], params: [String: Any]?, success: @escaping ((Any?)) -> Void ,failure: @escaping ((Error)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        for (k,v) in header {
            manager.requestSerializer.setValue(v, forHTTPHeaderField: k)
        }
        
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        manager.responseSerializer.acceptableContentTypes?.insert("text/xml")
        
        manager.post(
            url,
            parameters: params,
            progress: nil,
            success: { (task, response) -> Void in
                success(response)
        }) { (task, error) -> Void in
            failure(error)
        }
        
    }
    
    class func callPost(jsonRequest url: String, params: [String: Any]?, success: @escaping ((Any?)) -> Void ,failure: @escaping ((Error)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        manager.responseSerializer.acceptableContentTypes?.insert("text/xml")
        
        manager.post(
            url,
            parameters: params,
            progress: nil,
            success: { (task, response) -> Void in
                success(response)
        }) { (task, error) -> Void in
            failure(error)
        }
        
    }
    
    class func callPost(jsonRequest url: String, header: [String: String], params: [String: Any]?, success: @escaping ((Any?)) -> Void ,failure: @escaping ((Error)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        for (k,v) in header {
            manager.requestSerializer.setValue(v, forHTTPHeaderField: k)
        }
        
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        manager.responseSerializer.acceptableContentTypes?.insert("text/xml")
        
        manager.post(
            url,
            parameters: params,
            progress: nil,
            success: { (task, response) -> Void in
                success(response)
        }) { (task, error) -> Void in
            failure(error)
        }
        
    }
    
    // MARK: Multipart Methods
    class func callPostMultipartData(httpRequest url: String, params: [String: Any], video:Data, videoParam vname: String?,  success: @escaping ((Any?)) -> Void , failure: @escaping ((Error)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        manager.responseSerializer.acceptableContentTypes?.insert("text/xml")
        
        manager.post(
            url,
            parameters: params,
            constructingBodyWith: { (formData) -> Void in
                var videoname = vname
                if videoname == nil {
                    videoname = "video"
                }
                videoname = "video"
                
                if video.isEmpty != true{
                    formData.appendPart(withFileData: video  , name: videoname!, fileName: "video.mov", mimeType: "video/quicktime")
                }
        },
            progress: nil,
            success: { (task, response) -> Void in
                success(response)
        })
        { (task, error) -> Void in
            failure(error)
        }
    }
    
    // MARK: Multipart Methods
    class func callPostMultipartData(httpRequest url: String, params: [String: Any],image: UIImage?, imageParam iname: String?, success: @escaping ((Any?)) -> Void , failure: @escaping ((Error)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        manager.responseSerializer.acceptableContentTypes?.insert("text/xml")
        
        manager.post(
            url,
            parameters: params,
            constructingBodyWith: { (formData) -> Void in
                var imagename = iname
                if imagename == nil {
                    imagename = "image"
                }
                if let img = image {
                    if let data = UIImageJPEGRepresentation(img, 0.0) {
                        formData.appendPart(withFileData: data, name: imagename!, fileName: "photo.jpg", mimeType: "image/jpeg")
                    }
                }else {
                    if let data = UIImageJPEGRepresentation(UIImage(), 0.0) {
                        formData.appendPart(withFileData: data, name: imagename!, fileName: "photo.jpg", mimeType: "image/jpeg")
                    }
                }
        },
            progress: nil,
            success: { (task, response) -> Void in
                success(response)
        })
        { (task, error) -> Void in
            failure(error)
        }
    }
    
    class func callPostMultipartData(jsonRequest url: String, params: [String: Any],image: UIImage?, imageParam name: String?,success: @escaping ((Any?)) -> Void , failure: @escaping ((Error)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
//        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
//        manager.responseSerializer.acceptableContentTypes?.insert("text/xml")
//        
        manager.post(
            url,
            parameters: params,
            constructingBodyWith: { (formData) -> Void in
                var name = name
                if name == nil {
                    name = "image"
                }
                if let img = image {
                    if let data = UIImageJPEGRepresentation(img, 0.0) {
                        formData.appendPart(withFileData: data, name: name!, fileName: "photo.jpg", mimeType: "image/jpeg")
                    }
                }else {
                    if let data = UIImageJPEGRepresentation(UIImage(), 0.0) {
                        formData.appendPart(withFileData: data, name: name!, fileName: "photo.jpg", mimeType: "image/jpeg")
                    }
                }

        },
            progress: nil,
            success: { (task, response) -> Void in
                success(response)
        })
        { (task, error) -> Void in
            failure(error)
        }
    }
    
    class func callPostMultipartData(jsonRequest url: String, params: [String: Any],video:
        Data, imageParam name: String?,success: @escaping ((Any?)) -> Void , failure: @escaping ((Error)->Void)) {
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
//        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
//        manager.responseSerializer.acceptableContentTypes?.insert("text/xml")
        
        manager.post(
            url,
            parameters: params,
            constructingBodyWith: { (formData) -> Void in
                var name = name
                if name == nil {
                    name = "video"
                }
                formData.appendPart(withFileData: video  , name: name!, fileName: "video.mov", mimeType: "video/quicktime")
        },
            progress: nil,
            success: { (task, response) -> Void in
                success(response)
        })
        { (task, error) -> Void in
            failure(error)
        }
    }
    
    class func callPostMultipartData(httpRequest url: String, params: [String: Any],video:
        Data, imageParam name: String?,success: @escaping ((Any?)) -> Void , failure: @escaping ((Error)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
//        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
//        manager.responseSerializer.acceptableContentTypes?.insert("text/xml")
        
        manager.post(
            url,
            parameters: params,
            constructingBodyWith: { (formData) -> Void in
                var name = name
                if name == nil {
                    name = "video"
                }
                formData.appendPart(withFileData: video  , name: name!, fileName: "video.mov", mimeType: "video/quicktime")
        },
            progress: nil,
            success: { (task, response) -> Void in
                success(response)
        })
        { (task, error) -> Void in
            failure(error)
        }
    }
    
    // MARK: Check Methods
    class func isStatusOk(json: NSDictionary) -> Bool {
        var status = false
        
        if let code = json[ResponseConstant.Param.STATUS] as? String, code == ResponseConstant.Code.OK {
            status = true
        }
        
        return status
    }
}


// Templetes

// POST Request Without Header
//let params = [
//    URLConstant.Param.NAME: name,
//    URLConstant.Param.EMAIL: email,
//    URLConstant.Param.PASSWORD: password
//]
//WebserviceUtil.callPost(jsonRequest: URLConstant.API.SIGN_UP, params: params, success: { (response) in
//    if let json = response as? NSDictionary {
//        if WebserviceUtil.isStatusOk(json: json) {
//            
//        }else {
//            if let message = json[ResponseConstant.Param.MESSAGE] as? String{
//                UIUtil.showToast(message: message.capitalized)
//            }
//        }
//        print(json)
//    }
//}) { (error) in
//    UIUtil.hideProcessing()
//    print(error.localizedDescription)
//}
