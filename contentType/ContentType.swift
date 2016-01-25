/**
 * Copyright IBM Corporation 2015
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

public class ContentType {
    
    // For now the MIME types are specified in
    private static let TYPES_PATH: [String] = [
        "Sources/router/contentType/types.json",
        "Packages/Phoenix/Sources/router/contentType/types.json",
        "./types.json"]
    
    
    private static var extToContentType = [String:String]()
    
    /**
    * Attempt to load data from the filesystem in order from the following paths
    **/
    public class func loadDataFromFile (paths: [String]) -> NSData? {
        
        for path in paths {
            
            let data = NSData(contentsOfFile: path)
            
            if data != nil {
                return data
            }
        }
        
        return nil
        
    }
    
    
    /**
    * The following function loads the MIME types from an external file
    **/
    public class func initialize () {
        
        let contentTypesData = loadDataFromFile(TYPES_PATH)
        
        guard let ct = contentTypesData else {
            print("Could not find a MIME types file")
            return
        }
        
        do {
            
            // MARK: Linux Foundation will return an Any instead of an AnyObject
            // Need to test if this breaks the Linux build.
            let jsonData = try NSJSONSerialization.JSONObjectWithData(ct,
                options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            
            guard jsonData != nil else {
                print ("JSON could not be parsed")
                return
            }
                
            for (contentType, exts) in jsonData! {
                    
                let e = exts as! [String]
                for ext in e {
                 
                    extToContentType[ext] = contentType as? String

                }
            }
                
            
        } catch {
                
            print("Error reading \(TYPES_PATH)")
            return
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
    
}
