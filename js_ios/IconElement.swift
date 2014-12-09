import Foundation

public class IconElement : NSObject {

  // position this element would like to be at
	public var targetPosition = CGPoint.zero
  public var sprite : GLSprite!
  
  // current position of element
  private(set) var position = CGPoint.zero
  private var currentPositionDefined = false
  private var velocity = CGPoint.zero
  private var path : HermitePath!
  private var pathParameter = CGFloat(0)
  private(set) var name : String
  private(set) var size : CGPoint
  
  // If name is empty, treats as a 'gap' placeholder (no sprite)
  //
  public init(_ name : String, _ size: CGPoint) {
    self.name = name
    self.size = size
    super.init()
  }

  // Set element's actual position; clears velocity to zero, and disposes of any path
  //
  public func setActualPosition(position:CGPoint) {
  	self.position = position
    self.velocity = CGPoint.zero
    path = nil
  }
  
  private let pathDuration = CGFloat(2)
  
  public override var description : String {
    return "IconElement(\(name) pos:\(position) target:\(targetPosition) currposdef:\(currentPositionDefined))"
  }

  public var isEmpty : Bool {
    get {
      return name.isEmpty
    }
  }
  
  public func render(textureProvider : TextureProvider) {
    if (isEmpty) {
      return
    }
    if (sprite == nil) {
      let texture = textureProvider(name,size)
      sprite = GLSprite(texture:texture, window:texture.bounds, program:nil)
    }
    sprite.render(position)
  }
  
  // Update position of element to move it towards its desired position;
  // returns true if it has moved
  //
  public func update() -> Bool {
    var changed = false
    if (!currentPositionDefined) {
      setActualPosition(targetPosition)
      currentPositionDefined = true
      changed = true
    }
    
    let origPosition = position
    
    if (!(position == targetPosition && velocity == CGPoint.zero)) {
      preparePath()
    }
    
    if (path != nil) {
      pathParameter += pathDuration / Ticker.sharedInstance().ticksPerSecond
      if (pathParameter >= 1.0) {
        setActualPosition(targetPosition)
      } else {
        let (pos, vel) = path.evaluateAt(pathParameter)
        self.position = pos
        self.velocity = vel
      }
    }
		changed = changed || (position != origPosition)
    return changed
  }
  
  private func preparePath() {
    // If current path exists and is still valid, done
    if (path != nil && path.p2 == targetPosition) {
      return
    }
    path = HermitePath(pt1:position, pt2:targetPosition, v1:velocity, v2:CGPoint.zero)
    pathParameter = 0
  }
  
}
