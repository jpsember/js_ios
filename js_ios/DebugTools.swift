import Foundation
import UIKit

// These are debug-only convenience methods for converting various objects to strings.
// We rely on swift's ability to handle overloaded functions (though we should be
// on the lookout for dramatic increases in compile time; this was happening before)

public func d(rect:CGRect) -> String {
  return DebugTools.dRect(rect)
}

public func d(point:CGPoint) -> String {
  return DebugTools.dPoint(point)
}

public func d(value:Double,_ format:String? = nil) -> String {
  return DebugTools.dDouble(value)
}

public func d(value:CGFloat,_ format:String? = nil) -> String {
  return DebugTools.dDouble(Double(value))
}


// These methods are placed within a class, so they're accessible to objective c code

public class DebugTools : NSObject {
  
  public class func dRect(rect:CGRect) -> String {
    return rect.description
  }
  
  public class func dPoint(point:CGPoint) -> String {
    return point.description
  }

  public class func dDouble(value:Double,format:String? = nil) -> String {
    let f = format ?? "%8.2f "
    return NSString(format:f,value)
  }

}
