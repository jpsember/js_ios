import Foundation

public class IconElement : NSObject {

  public var position = CGPoint.zero
  public var velocity = CGPoint.zero

  private(set) var name : String
  private(set) var size : CGPoint
  public var sprite : GLSprite!
  
  public init(_ name : String, _ size: CGPoint) {
    self.name = name
    self.size = size
    super.init()
  }

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
  
}
