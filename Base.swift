import Foundation

func puts(message: String!) {
  if let msg = message {
    JSBase.logString(msg + "\n")
  }
}

func ASSERT(condition: Bool,_ message:String = "") {
  if (condition) {
    return
  }
  var msg = message
  if (msg.isEmpty) {
    msg = "(unknown cause)"
  }
  JSBase.dieWithMessage(msg)
}
  
func warning(_ message: String = "", file: String = __FILE__, line: Int = __LINE__) {
  let str = String(file)
  let fileAndLine = JSBase.descriptionForPath(file, lineNumber:Int32(line))
  JSBase.oneTimeReport(fileAndLine, message:message, reportType:"warning      ")
}

