import Foundation
import GLKit


// -------- Convert this to Obj-c, since it uses low level arrays

public class SWIFTSpriteProgram  : NSObject{

  let texture: Texture
  let textureWindow: Rect
  var position: Point = Point.zero
  let context: GLSpriteContext
  var vertexInfo: [CGFloat]?
  
  init(context: GLSpriteContext, texture:Texture, textureWindow:Rect) {
    self.context = context
    self.texture = texture
    self.textureWindow = textureWindow
    super.init()
    constructVertexInfo()
  }
  
  private func constructVertexInfo() {
    var a = [CGFloat]()
    
    func ap(pt:Point) {
      a.append(pt.x)
      a.append(pt.y)
    }
    
    let textureWidth = Int(textureWindow.width)
    let textureHeight = Int(textureWindow.height)
    
    let p0 = Point(0,0)
    let p2 = Point(textureWidth,textureHeight)
    let p1 = Point(p2.x,p0.y)
    let p3 = Point(p0.x,p2.y)
    
    let t0 = Point(textureWindow.x / CGFloat(texture.width), textureWindow.endY / CGFloat(texture.height))
    let t2 = Point(textureWindow.endX / CGFloat(texture.width), textureWindow.y / CGFloat(texture.height))
    let t1 = Point(t2.x, t0.y);
    let t3 = Point(t0.x, t2.y);
    
    ap(p0);
    ap(t0);
    ap(p1);
    ap(t1);
    ap(p2);
    ap(t2);
    
    ap(p0);
    ap(t0);
    ap(p2);
    ap(t2);
    ap(p3);
    ap(t3);
    
    vertexInfo = a
  }
  
  public func setPosition(x:CGFloat, _ y:CGFloat) {
    position.setTo(x,y)
  }
  
  public func setPosition(pos:Point) {
    setPosition(pos.x,pos.y)
  }
  
  public func render() {
//    
//    context.renderSprite(texture, vertexData:0, //vertexInfo!,
//      dataLength:vertexInfo!.count,
//      CGPointMake(x:position.x, y:position.y));
  }

}
