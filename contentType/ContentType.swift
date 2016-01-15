//
//  ContentType.swift
//  router
//
//  Created by Ira Rosen on 29/11/15.
//  Copyright © 2015 IBM. All rights reserved.
//

public class ContentType {
    
    private static var extToContentType = [String:String]()
        
    public class func initialize () {
        for (contentType, exts) in rawTypes {
            for ext in exts {
                extToContentType[ext] = contentType
            }
        }
    }
    
    
    public class func contentTypeForExtension (ext: String) -> String? {
        return extToContentType[ext]
    }
    
    
    public class func isType (messageContentType: String, typeDescriptor: String) -> Bool {
        let type = typeDescriptor.lowercaseString
        let typeAndSubtype = messageContentType.bridgeTo().componentsSeparatedByString(";")[0].lowercaseString
        
        if typeAndSubtype == type {
            return true
        }
        
        // typeDescriptor is file extension
        if typeAndSubtype == extToContentType[type] {
            return true
        }
        
        // typeDescriptor is a shortcut
        let normalizedType = normalizeType(type)
        if typeAndSubtype == normalizedType {
            return true
        }
        
        // the types match and the subtype in typeDescriptor is "*"
        let messageTypePair = typeAndSubtype.bridgeTo().componentsSeparatedByString("/")
        let normalizedTypePair = normalizedType.bridgeTo().componentsSeparatedByString("/")
        if messageTypePair.count == 2 && normalizedTypePair.count == 2
            && messageTypePair[0] == normalizedTypePair[0] && normalizedTypePair[1] == "*" {
            return true
        }
        return false
    }
    
    
    private class func normalizeType (type: String) -> String {
        switch type {
        case "urlencoded":
            return "application/x-www-form-urlencoded"
        case "multipart":
            return "multipart/*"
        case "json":
            return "application/json"
            // TODO: +json?
//            if (type[0] === '+') {
//                // "+json" -> "*/*+json" expando
//                type = '*/*' + type
//            }
        default:
            return type
        }
    }
    
    
    private static var rawTypes = [
        "text/plain": ["txt","text","conf","def","list","log","in","ini"],
        "text/html": ["html", "htm"],
        "text/css": ["css"],
        "text/csv": ["csv"],
        "text/xml": [],
        "text/javascript": [],
        "text/markdown": [],
        "text/x-markdown": ["markdown","md","mkd"],
        
        "application/json": ["json","map"],
        "application/x-www-form-urlencoded": [],
        "application/xml": ["xml","xsl","xsd"],
        "application/javascript": ["js"],
        
        "image/bmp": ["bmp"],
        "image/png": ["png"],
        "image/gif": ["gif"],
        "image/jpeg": ["jpeg","jpg","jpe"],

    ]
    


}
