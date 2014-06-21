//
//  FileManagerModel.swift
//  DiningHallApp
//
//  Created by Connor on 6/20/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import Foundation

class FileManagerModel
{
    var documentsDir: String
    var fileManager: NSFileManager
  
    init()
    {
        fileManager = NSFileManager.defaultManager()
        documentsDir = NSHomeDirectory().stringByAppendingPathComponent("Documents")
    }
    
    func writeFile(contents: String, fileName: String)
    {
        let filePath = documentsDir.stringByAppendingPathComponent(fileName)
        
        var errPointer: NSError?
        contents.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: &errPointer)
        
        if let error = errPointer
        {
            println("Failed to write to file: " + error.localizedDescription)
        }
    }
    
    func readFile(fileName: String) -> String?
    {
        let filePath = documentsDir.stringByAppendingPathComponent(fileName)
        
        //Return if file does not exist
        if !fileManager.fileExistsAtPath(filePath)
        {
            println("Credentials file has not yet been created.")
            return nil
        }
        
        //Do read
        var errPointer: NSError?
        var contents = NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: &errPointer)
        
        //Fail on error
        if let error = errPointer
        {
            println("Failed to read file: " + error.localizedDescription)
            return nil
        }
        
        return contents
    }
    
    func deleteFile(fileName: String)
    {
        let filePath = documentsDir.stringByAppendingPathComponent(fileName)
        
        var bad: NSError?
        fileManager.removeItemAtPath(filePath, error: &bad)
        
        if let error = bad
        {
            println("Failed to delete file: " + error.localizedDescription)
        }
    }
}