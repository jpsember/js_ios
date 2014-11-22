import Foundation
import UIKit

// These are debug-only convenience methods for converting various objects to strings.
// We rely on swift's ability to handle overloaded functions (though we should be
// on the lookout for dramatic increases in compile time; this was happening before)

public func d(rect:CGRect) -> String {
  return JSDebugTools.dRect(rect)
}

public func d(point:CGPoint) -> String {
  return JSDebugTools.dPoint(point)
}

public func d(value:Double,_ format:String? = nil) -> String {
  return JSDebugTools.dDouble(value)
}

public func d(value:CGFloat,_ format:String? = nil) -> String {
  return JSDebugTools.dDouble(Double(value))
}

public func d(value:Float,_ format:String? = nil) -> String {
  return JSDebugTools.dDouble(Double(value))
}

public func d(value:Bool) -> String {
  return JSDebugTools.dBoolean(value)
}

public func d(image:UIImage) -> String {
  return JSDebugTools.dImage(image)
}

public func exitApp() {
  JSBase.exitApp()
}

