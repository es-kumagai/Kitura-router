//
//  RegexMatcher.swift
//  icu
//
//  Created by Samuel Kallner on 10/25/15.
//  Copyright © 2015 IBM. All rights reserved.
//

import sys
import Foundation

import pcre2

public class RegexMatcher {
    
    let compiledExpr: COpaquePointer
    let matchData: COpaquePointer
    var matchStr: NSData?
    
    public var matchCount: Int {
        return matchStr != nil ? Int(pcre2_get_ovector_count_8(matchData)) : 0
    }
    
    init(expr: COpaquePointer) {
        compiledExpr = expr
        matchData = pcre2_match_data_create_from_pattern_8(compiledExpr, nil)
    }
    
    deinit {
        pcre2_match_data_free_8(matchData)
    }
    
    public func match(str: String) -> Bool {
        let cStr = StringUtils.toUtf8String(str)
        return cStr != nil ? match(cStr!) : false
    }
    
    public func match(data: NSData) -> Bool {
        var result = false
        matchStr = data
        
        let rc = pcre2_match_8(compiledExpr, UnsafePointer<UInt8>(matchStr!.bytes), matchStr!.length, 0, 0, matchData, nil)
        
        if  rc > 0 {
            result = true
        }
        
        return result
    }
    
    public func getMatchedElement(number: Int) -> String? {
        var result: String? = nil
        if  matchStr != nil {
            let count = pcre2_get_ovector_count_8(matchData)
            if  count >= UInt32(number) {
                let oVector = pcre2_get_ovector_pointer_8(matchData)
                let startIndex = oVector[number*2]
                let endIndex = oVector[number*2+1]
                
                result = NSString(bytes: matchStr!.bytes+startIndex, length: endIndex-startIndex, encoding: NSUTF8StringEncoding)!.bridge() as String?
            }
        }
        return result
    }
    
    public func substitute(str: String, replacement: String, globally: Bool=false) -> (Int, String?) {
        
        let cStr = StringUtils.toUtf8String(str)
        let cRepl = StringUtils.toUtf8String(replacement)
        if  cStr != nil  &&  cRepl != nil  {
            var resultCstr = [UInt8](count: cStr!.length*5, repeatedValue: 0)
        
            let count = substitute(cStr!, replacement: cRepl!, output: &resultCstr, globally: globally)
        
            return (Int(count), String(CString: UnsafePointer<Int8>(resultCstr), encoding: NSUTF8StringEncoding))
        }
        else {
            return (0, nil)
        }
    }
    
    public func substitute(str: NSData, replacement: NSData, inout output: [UInt8], globally: Bool=false) -> Int {
        let options:UInt32 = globally ? PCRE2_SUBSTITUTE_GLOBAL : 0
        var resultLen: size_t = output.count-1
        
        let rc = pcre2_substitute_8(compiledExpr, UnsafePointer<UInt8>(str.bytes), str.length, 0, options, matchData, nil, UnsafePointer<UInt8>(replacement.bytes), replacement.length, &output, &resultLen)
        
        return Int(rc)
    }
}
