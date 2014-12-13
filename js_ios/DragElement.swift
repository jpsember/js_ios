import Foundation

// Class that encapsulates logic and display associated with an icon being dragged
// by the user
//
public class DragElement : NSObject, LogicProtocol {

  public class func sharedInstance() -> DragElement {
    if (S.singleton == nil) {
      S.singleton = DragElement()
    }
    return S.singleton
  }
  
  private(set) var element : IconElement!
  private(set) var touchEvent : TouchEvent!
  private(set) var cursorPosition = CGPoint(0)
  
  private let HoverBumpPathDuration = CGFloat(0.2)
  private let HoverBumpVerticalOffset = CGFloat(18)
	private let HoverTargetScale = CGFloat(1.5)
  
  // LogicProtocol method: animate icon according to hover state (translation, scaling)
  //
  public func updateLogic() {
    if !active {
      return
    }
    
    if (hoverPath != nil) {
      if hoverPath.update(HoverBumpPathDuration) {
        ViewManager.sharedInstance().setNeedsDisplay()
        element.currentScale = scaleStart + (scaleEnd - scaleStart) * hoverPath.parameter
      } else {
        hoverPath = nil
      }
    }
  }
  
  // Start a drag sequence
  //
  public func startDrag(event : TouchEvent, element : IconElement, touchOffset : CGPoint) {
    self.touchEvent = event
    self.element = element
    scaleStart = element.currentScale
    scaleEnd = HoverTargetScale
    self.touchOffset = touchOffset
    
    hoverPath = HermitePath(p1:CGPoint.zero, p2:CGPoint(0,HoverBumpVerticalOffset))
  }
  
  // Update drag sequence
  //
  public func updateDrag(event : TouchEvent) {
    if !active {
      return
    }
    
    touchEvent = event
  }
  
  // Stop drag sequence (if one is occurring) 
  //
  public func stopDrag(_ event : TouchEvent? = nil) {
    if !active {
      return
    }
    element.targetScale = 1.0
    element = nil
  }

  public func updateCursor() {
    if !active {
      return
    }
    
    let sprite = element.sprite
    var loc = CGPoint.difference(touchEvent.absoluteLocation,touchOffset)
    loc.add(hoverPath.position)
    cursorPosition = loc
    element.renderSpriteAt(loc)
  }

  public var active : Bool {
    get {
      return element != nil
    }
  }
  
  private var hoverPath : HermitePath!
  private var scaleStart : CGFloat = 1.0
  private var scaleEnd : CGFloat = 1.0
  private var touchOffset = CGPoint.zero
  
  private struct S {
    static var singleton : DragElement!
  }
  
  private override init() {
    super.init()
  }

}
