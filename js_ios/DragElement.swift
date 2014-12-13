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
  
  // LogicProtocol method: animate icon according to hover state (translation, scaling)
  //
  public func updateLogic() {
    if !active {
      return
    }
    
    if (hoverPath != nil) {
      if hoverPath.update(hoverBumpPathDuration) {
        ViewManager.sharedInstance().setNeedsDisplay()
        dragElement.currentScale = scaleStart + (scaleEnd - scaleStart) * hoverPath.parameter
      } else {
        hoverPath = nil
      }
    }
  }
  
  // Start a drag sequence
  //
  public func startDrag(event : TouchEvent, element : IconElement, touchOffset : CGPoint) {
    self.dragLocation = event
    self.dragElement = element
    scaleStart = element.currentScale
    scaleEnd = 1.5
    self.touchOffset = touchOffset
    
    hoverPath = HermitePath(p1:CGPoint.zero, p2:CGPoint(0,hoverBumpVerticalOffset))
  }
  
  // Update drag sequence
  //
  public func updateDrag(event : TouchEvent) {
    if !active {
      return
    }
    
    dragLocation = event
  }
  
  // Stop drag sequence (if one is occurring) 
  //
  public func stopDrag(event : TouchEvent? = nil) {
    if !active {
      return
    }
    dragElement = nil
  }

  public func updateCursor() {
    if !active {
      return
    }
    
    let sprite = dragElement.sprite
    var loc = CGPoint.difference(dragLocation.absoluteLocation,touchOffset)
    loc.add(hoverPath.position)
    dragCursorPosition = loc
    dragElement.renderSpriteAt(loc)
  }

  public var active : Bool {
    get {
      return dragElement != nil
    }
  }
  
  private var dragCursorPosition : CGPoint!
  private var dragElement : IconElement!
  private var hoverPath : HermitePath!
  private var scaleStart : CGFloat = 1.0
  private var scaleEnd : CGFloat = 1.0
  private var touchOffset = CGPoint.zero
  private var dragLocation : TouchEvent!
  private let hoverBumpPathDuration = CGFloat(0.2)
  private let hoverBumpVerticalOffset = CGFloat(18)
  
  private struct S {
    static var singleton : DragElement!
  }
  
  private override init() {
    super.init()
  }

}
