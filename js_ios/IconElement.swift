import Foundation

public class IconElement : NSObject {

  public var position = CGPoint.zero
  public var velocity = CGPoint.zero
  
  public var size : CGPoint {
    get {
  		return sprite.texture.bounds.ptSize
    }
  }
  
  private let sprite : GLSprite
  
  public init(sprite : GLSprite) {
  	self.sprite = sprite
    super.init()
  }

}
