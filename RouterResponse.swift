//
//  RouterResult.swift
//  router
//
//  Created by Samuel Kallner on 11/4/15.
//  Copyright © 2015 IBM. All rights reserved.
//

import net
import sys

public class RouterResponse {
    let response: ServerResponse
    
    public var error: Error?
    
    init(response: ServerResponse) {
        self.response = response
    }
    
    public func end() throws -> RouterResponse {
        try response.end()
        return self
    }
    
    public func end(str: String) throws -> RouterResponse {
        try send(str)
        try end()
        return self
    }
    
    public func send(str: String) throws -> RouterResponse {
        try response.writeString(str)
        return self
    }
    
    public func status(status: Int) -> RouterResponse {
        response.status = status
        return self
    }
    
    public func status(status: HttpStatusCode) -> RouterResponse {
        response.statusCode = status
        return self
    }
    
    public func sendStatus(status: Int) throws -> RouterResponse {
        self.status(status)
        if  let statusText = Http.statusCodes[status] {
            try send(statusText)
        }
        else {
            try send(String(status))
        }
        return self

    }
    
    public func sendStatus(status: HttpStatusCode) throws -> RouterResponse {
        self.status(status)
        try send(Http.statusCodes[status.rawValue]!)
        return self

    }
    
    public func getHeader(key: String) -> String? {
        return response.getHeader(key)
    }
    
    public func getHeaders(key: String) -> [String]? {
        return response.getHeaders(key)
    }
    
    public func setHeader(key: String, value: String) {
        response.setHeader(key, value: value)
    }
    
    public func setHeader(key: String, value: [String]) {
        response.setHeader(key, value: value)
    }
    
    public func removeHeader(key: String) {
        response.removeHeader(key)
    }
    
    public func redirect(path: String) throws -> RouterResponse {
        return try redirect(.MOVED_TEMPORARILY, path: path)
    }
    
    public func redirect(status: HttpStatusCode, path: String) throws -> RouterResponse {
        try redirect(status.rawValue, path: path)
        return self
    }

    public func redirect(status: Int, path: String) throws -> RouterResponse {
        try self.status(status).location(path).end()
        return self
    }
    
    public func location(path: String) -> RouterResponse {
        var p = path
        if  p == "back" {
            let referrer = getHeader("referrer")
            if  let r = referrer {
                p = r
            }
            else {
                p = "/"
            }
        }
        setHeader("Location", value: p)
        return self
    }
}
