import Foundation

func puts(message: String!) {
  if let msg = message {
    JSBase.logString(msg + "\n")
  }
}

func die(_ message:String = "") {
  var msg = message
  if (msg.isEmpty) {
    msg = "(unknown cause)"
  }
  JSBase.dieWithMessage(msg)
}

func ASSERT(condition: Bool,_ message:String = "") {
  if (condition) {
    return
  }
  die(message)
}
  
func warning(_ message: String = "", file: String = __FILE__, line: Int = __LINE__) {
  let str = String(file)
  let fileAndLine = JSBase.descriptionForPath(file, lineNumber:Int32(line))
  JSBase.oneTimeReport(fileAndLine, message:message, reportType:"warning      ")
}

func check(error: NSError?) {
  if let  e = error  {
    ASSERT(false,"Error! \(e)")
  }
}

