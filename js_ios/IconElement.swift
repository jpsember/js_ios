import Foundation

public class IconElement : NSObject {

  // position this element would like to be at
	public var targetPosition = CGPoint.zero
  public var sprite : GLSprite!
  public var targetScale : CGFloat = 1
  public var currentScale : CGFloat = 1
  
  // current position of element
  private(set) var position = CGPoint.zero
  private var currentPositionDefined = false
  private var velocity = CGPoint.zero
  private var path : HermitePath!
  private var scaleAnimStart = CGFloat(1)
  private var scaleAnimEnd = CGFloat(1)
  
  private(set) var name : String
  private(set) var size : CGPoint
  
  private let PathDurationInSeconds = CGFloat(0.3)

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
    renderSpriteAt(position)
  }
  
  public func renderSpriteAt(position:CGPoint) {
    ASSERT(sprite != nil)
    sprite.scale = currentScale
    let cx = sprite.texture.bounds.width / 2
    let cy = sprite.texture.bounds.height / 2
		let scaledPosition = CGPoint(position.x + cx * (1 - currentScale), position.y + cy * (1 - currentScale))
		sprite.render(scaledPosition)
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
    
    if (!(position == targetPosition && velocity == CGPoint.zero && currentScale == targetScale)) {
      preparePath()
    }
    
    if (path != nil) {
      changed = true
      if (!path.update(PathDurationInSeconds)) {
        setActualPosition(targetPosition)
        currentScale = targetScale
      } else {
        let (pos, vel) = path.evaluateAt(path.parameter)
        self.position = pos
        self.velocity = vel
        currentScale = scaleAnimStart + (scaleAnimEnd - scaleAnimStart) * path.parameter
        path = nil
      }
    }
		return changed
  }
  
  private func preparePath() {
    // If current path exists and is still valid, done
    if (path != nil && path.p2 == targetPosition && scaleAnimEnd == targetScale) {
      return
    }
    path = HermitePath(p1:position, p2:targetPosition, v1:velocity)
    scaleAnimStart = currentScale
    scaleAnimEnd = targetScale
  }
  
}
