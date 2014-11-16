// Class callable from obj-c

import Foundation

public class A : NSObject {

  public var myProperty : String?
  
  public func doSomething(message: String) -> Int {
    puts("Property \(myProperty); message \(message)")
    return 5
  }
  
  
}
