import Foundation

public enum TouchEventType : String, Printable {
  case Down = "Down"
  case Drag = "Drag"
  case Up = "Up"
  
  public var description : String {
				get {
          return self.rawValue
				}
  }
  
}

public class TouchEvent : NSObject {
  
  private (set) var type : TouchEventType
  // This should be the location in the current view's OpenGL coordinate system (origin is bottom right)
  private (set) var location : CGPoint
  
  public init(_ type : TouchEventType, _ location : CGPoint) {
    self.type = type
    self.location = location
    super.init()
  }
  
  public override var description : String {
    return "TouchEvent \(type):\(location)"
  }
}
