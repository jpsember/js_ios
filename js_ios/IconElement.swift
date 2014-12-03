import Foundation

public class IconElement : NSObject {

  public var position = CGPoint.zero
  public var velocity = CGPoint.zero
  
  public var size : CGPoint {
    get {
  		return sprite.texture.bounds.ptSize
    }
  }
  
  public let sprite : GLSprite
  
  public init(_ sprite : GLSprite) {
  	self.sprite = sprite
    super.init()
  }

  public override var description : String {
    return "IconElement(pos:\(position) \(sprite.texture)"
  }
  

}
