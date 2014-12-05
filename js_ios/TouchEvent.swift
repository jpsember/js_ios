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
  // This is the location in the root view, in OpenGL space (origin bottom left)
  private (set) var absoluteLocation : CGPoint
  
  public init(_ type : TouchEventType, _ absoluteLocation : CGPoint) {
    self.type = type
    self.absoluteLocation = absoluteLocation
    super.init()
  }
  
  public override var description : String {
    return "TouchEvent \(type):\(absoluteLocation)"
  }
  
  // Get location of event relative to a particular view's origin
  //
  public func locationRelativeToView(view:View) -> CGPoint {
  	return CGPoint.difference(absoluteLocation,view.absolutePosition)
  }
}
