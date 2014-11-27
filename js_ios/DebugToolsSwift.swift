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
  return DebugTools.dDouble(Double(value), format:format)
}

public func d(value:Int,_ format:String? = nil) -> String {
  return DebugTools.dInt(value)
}

public func d(value:Float,_ format:String? = nil) -> String {
  return DebugTools.dDouble(Double(value))
}

public func d(value:Bool) -> String {
  return DebugTools.dBoolean(value)
}

public func d(image:UIImage) -> String {
  return DebugTools.dImage(image)
}

public func dHex(value:Int) -> String {
  return NSString(format:"%x ",value)
}

public func dBits(value:Int) -> String {
  return DebugTools.dBits(value)
}

public func exitApp() {
  JSBase.exitApp()
}

public func dInts(array:UnsafePointer<Int>,length:Int) -> String {
  return DebugTools.dInts(array,length:length)
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
  
  public class func dInt(value:Int,format:String? = nil) -> String {
    let f = format ?? "%5d "
    return NSString(format:f,value)
  }

  public class func dBoolean(value:Bool) -> String {
    return value ? "T" : "F"
  }

  public class func dFloats(floats:UnsafePointer<Float>, length:Int) -> String {
    var s = ""
    for i in 0..<length {
      s += d(floats[i])
      if ((i+1) % 4 == 0) {
      	s += "\n"
      }
    }
	  return s
  }
  
  public class func dInts(ints:UnsafePointer<Int>, length:Int) -> String {
    var s = ""
    for i in 0..<length {
      s += d(ints[i])
      if ((i+1) % 4 == 0) {
        s += "\n"
      }
    }
    return s
  }

  public class func dBytes(array:UnsafePointer<UInt8>,length:Int) -> String {
    var s = ""
    for i in 0..<length {
      s += String(format:"%02x",array[i])
      if ((i+1)%4 == 0) {
      	if ((i+1)%32 == 0) {
        	s += "\n"
        } else {
          s += " "
				}
      }
    }
    return s
  }
  
  public class func dBits(value:Int) -> String {
    var s = ""
    var bitPrinted = false
    for var bitNumber = 32-1; bitNumber >= 0; bitNumber-- {
      let bit = (value & (1 << bitNumber)) != 0
      if (bit || bitNumber == 4-1) {
        bitPrinted = true
      }
      if (bitPrinted) {
        s += bit ? "1" : "."
        if (bitNumber != 0 && bitNumber % 4 == 0) {
          s += " "
        }
      }
    }
    return s
  }
  
  public class func dImage(image:UIImage) -> String {
  	let spriteImage = image.CGImage
	  let data = CGDataProviderCopyData(CGImageGetDataProvider(spriteImage))
    let pixels = CFDataGetBytePtr(data)
	  let length = CFDataGetLength(data);
  	let dumpedLength = min(length, 32*4);
    var s = "UIImage \(Int(image.size.width)) x \(Int(image.size.height)):\n"
    s += dBytes(pixels,length:dumpedLength)
    return s
  }

}
