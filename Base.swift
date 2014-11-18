import Foundation
import UIKit
// Why is compiling suddenly very slow?

public func puts(message: String!) {
  if let msg = message {
    JSBase.logString(msg + "\n")
  }
}

public func die(_ message:String = "") {
  var msg = message
  if (msg.isEmpty) {
    msg = "(unknown cause)"
  }
  JSBase.dieWithMessage(msg)
}

public func ASSERT(condition: Bool,_ message:String = "") {
  if (condition) {
    return
  }
  die(message)
}
  
public func warning(_ message: String = "", file: String = __FILE__, line: Int = __LINE__) {
  let str = String(file)
  let fileAndLine = JSBase.descriptionForPath(file, lineNumber:Int32(line))
  JSBase.oneTimeReport(fileAndLine, message:message, reportType:"warning      ")
}

public func check(error: NSError?) {
  if let  e = error  {
    ASSERT(false,"Error! \(e)")
  }
}

// WARNING: if you attempt to dump(0), compiler slows down to a crawl
public func dump(doubleValue:Double,  format:String = "7.2f") -> String {
	return NSString(format:"%\(format)",doubleValue)
}

public func dump(CGFloatValue:CGFloat, format:String = "7.2f") -> String {
  return dump(Double(CGFloatValue), format:format)
}



