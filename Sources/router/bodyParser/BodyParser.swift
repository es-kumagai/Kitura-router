//
//  BodyParser.swift
//  router
//
//  Created by Ira Rosen on 29/11/15.
//  Copyright © 2015 IBM. All rights reserved.
//

// import SwiftyJSON

import sys
import net
import ETSocket

import Foundation

public class BodyParser : RouterMiddleware {
  private static let BUFFER_SIZE = 2000

  public init() {}

  public func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    request.body = BodyParser.parse(request, contentType: request.serverRequest.headers["Content-Type"])
    next()
  }

  public class func parse(message: ETReader, contentType: String?) -> ParsedBody? {
    if let contentType = contentType {
      do {

        //if ContentType.isType(contentType, typeDescriptor: "json") {
        //    let bodyData = try readBodyData(message)
        //    let json = JSON(data: bodyData)
        //   if json != JSON.null {
        //       return ParsedBody(json: json)
        //   }
        //}
        if ContentType.isType(contentType, typeDescriptor: "urlencoded") {
          let bodyData = try readBodyData(message)
          var parsedBody = [String:String]()
          var success = true
          if let bodyAsString: String = String(data: bodyData, encoding: NSUTF8StringEncoding) {

            let bodyAsArray = bodyAsString.bridge().componentsSeparatedByString("&")
            for element in bodyAsArray {
              let elementPair = element.bridge().componentsSeparatedByString("=")
              if elementPair.count == 2 {
                parsedBody[elementPair[0]] = elementPair[1]
              }
              else {
                success = false
              }
            }
            if success && parsedBody.count > 0 {
              return ParsedBody(urlEncoded: parsedBody)
            }
          }
        }
        // There was no support for the application/json MIME type
        else if (ContentType.isType(contentType, typeDescriptor: "text/*") ||
          ContentType.isType(contentType, typeDescriptor: "application/json")) {
          let bodyData = try readBodyData(message)
          if let bodyAsString: String = String(data: bodyData, encoding: NSUTF8StringEncoding) {
            return ParsedBody(text:  bodyAsString)
          }
        }
      }
      catch {
        // response.error = error
      }
    }

    return nil
  }

  public class func readBodyData(reader: ETReader) throws -> NSMutableData {
    let bodyData = NSMutableData()

    var length = try reader.readData(bodyData)
    while length != 0 {
      length = try reader.readData(bodyData)
    }
    return bodyData
  }

}

public class ParsedBody {
  // private var jsonBody: JSON?
  private var urlEncodedBody: [String:String]?
  private var textBody: String?

  //public init (json: JSON) {
  //    jsonBody = json
  //}

  public init (urlEncoded: [String:String]) {
    urlEncodedBody = urlEncoded
  }

  public init (text: String) {
    textBody = text
  }

  //public func asJson() -> JSON? {
  //    return jsonBody
  //}

  public func asUrlEncoded() -> [String:String]? {
    return urlEncodedBody
  }

  public func asText() -> String? {
    return textBody
  }
}