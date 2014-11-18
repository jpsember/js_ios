import Foundation
import js_ios

public class IORecorder {
  
  private class func extractClassName(name:String) -> String {
    var basename = name.lastPathComponent
    ASSERT(basename.hasSuffix(".swift"),"missing suffix")
    basename = basename.stringByDeletingPathExtension
    return basename
  }
  
  private class func extractFunctionName(name:String) -> String {
    var out = ""
    let range = name.rangeOfString("(")
    if (range != nil) {
      out = name.substringToIndex(range!.startIndex)
    }
    if (out.isEmpty) {
    	die("can't find function name within \(name)")
    }
    return out
  }
  
  public class func start(replaceIfChanged:Bool = false, _ fileName:String = __FILE__, _ functionName:String = __FUNCTION__) {
    let className = extractClassName(fileName)
    let fnName = extractFunctionName(functionName)
    JSIORecorder.startWithClassName(className, methodName: fnName, replaceIfChanged: replaceIfChanged)
  }
  
  public class func stop() {
    JSIORecorder.stop()
  }
  
}