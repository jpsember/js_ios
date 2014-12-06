import Foundation

public class IconElement : NSObject {

  // current position of element
  public var position = CGPoint.zero
  private var currentPositionDefined = false
  
  public var velocity = CGPoint.zero
  
  // position this element would like to be at
	public var targetPosition = CGPoint.zero
  
  private var path : HermitePath!
  private var pathParameter = CGFloat(0)
  
  private(set) var name : String
  private(set) var size : CGPoint
  public var sprite : GLSprite!
  
  public init(_ name : String, _ size: CGPoint) {
    self.name = name
    self.size = size
    super.init()
  }

  private let pathDuration = CGFloat(2)
  
  public override var description : String {
    return "IconElement(\(name) pos:\(position))"
  }

  public func render(textureProvider : TextureProvider) {
    if (sprite == nil) {
      let texture = textureProvider(name,size)
      sprite = GLSprite(texture:texture, window:texture.bounds, program:nil)
    }
    sprite.render(position)
  }
  
  public func update() -> Bool {
    var changed = false
    
    if (!currentPositionDefined) {
			position = targetPosition
      currentPositionDefined = true
      changed = true
    }
    
    let origPosition = position
    
    if (position != targetPosition || velocity != CGPoint.zero) {
      preparePath()
    }
    
    if (path != nil) {
      pathParameter += pathDuration / Ticker.sharedInstance().ticksPerSecond
      if (pathParameter >= 1.0) {
        position = targetPosition
        velocity = CGPoint.zero
      } else {
        
        let (pos, vel) = path.evaluateAt(pathParameter)
        position = pos
        velocity = vel
      }
    }
    changed = changed || (position != origPosition)
    return changed
  }
  
  private func preparePath() {
    // If current path exists and is still valid, done
    if (path != nil) {
      if (path.p2 == targetPosition) {
        return
      }
      path = nil
    }
    path = HermitePath(pt1:position, pt2:targetPosition, v1:velocity, v2:CGPoint.zero)
    pathParameter = 0
  }
  
  
}
