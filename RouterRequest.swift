//
//  RouterRequest.swift
//  router
//
//  Created by Samuel Kallner on 11/4/15.
//  Copyright © 2015 IBM. All rights reserved.
//

import io
import net

public class RouterRequest: Reader {
    let serverRequest: ServerRequest
    let parsedUrl: UrlParser
    
    public internal(set) var route: String?
    
    public var originalUrl: String {
        return serverRequest.urlString
    }
    
    public var url: String
    
    
    public var headers: [String:String] { return serverRequest.headers }
    public var params: [String:String] = [:]
    public var queryParams: [String:String] { return parsedUrl.queryParams }
    public var userInfo: [String: AnyObject] = [:]

    public internal(set) var body: ParsedBody? = nil
    
    init(request: ServerRequest) {
        serverRequest = request
        parsedUrl = UrlParser(url: serverRequest.url, isConnect: false)
        url = String(serverRequest.urlString)
    }
    
    public func readBuffer(inout buffer: [UInt8]) throws -> Int {
        return try serverRequest.readBuffer(&buffer)
    }
    
    public func readString() throws -> String? {
        return try serverRequest.readString()
    }
}
