import Foundation
import GLKit

public let DB_TEXTURE = cond(true)

public class Texture : NSObject {
 
  private(set) var textureId : GLuint = 0
  public var width = 0
  public var height = 0
  public var hasAlpha = false
  
  public override var description : String {
    return "(Texture id:\(textureId) size:\(width) x \(height) hasAlpha:\(d(hasAlpha)))"
  }

  public var bounds: CGRect {
    return CGRectMake(0,0,CGFloat(width),CGFloat(height))
  }
  
  private override init() {
    super.init()
  }
  
  // Constructor
  // 
  convenience init(pngName:String) {
   	self.init()
    loadBitmap(pngName)
  }
  
  convenience init(buffer:GLBuffer) {
    self.init(textureId:buffer.textureId,size:buffer.size,hasAlpha:buffer.hasAlpha)
  }
  
  convenience init(textureId:GLuint,size:CGPoint,hasAlpha:Bool) {
    self.init();
    self.textureId = textureId
    self.width = size.ix
    self.height = size.iy
    self.hasAlpha = hasAlpha
  }
  
  // Load UImage from resource "<name>.png"
  //
  private func loadUImage(name: String) -> UIImage? {
    let url = NSBundle.mainBundle().URLForResource(name, withExtension: "png")
    nonNil(url)
    
    var err: NSError?
    var imageData = NSData(contentsOfURL:url!, options:NSDataReadingOptions.DataReadingMappedIfSafe, error:&err)
    return UIImage(data: imageData!)
  }
  
  // Load texture's bitmap from a resource '<name>.png'
  //
  private func loadBitmap(name: String) {
    let uImage = loadUImage(name)
    let (textureId,textureSize,hasAlpha) = GLTools.installTexture(uImage!, contextName:name)
   	self.textureId = textureId
    self.width = Int(textureSize.x)
    self.height = Int(textureSize.y)
    self.hasAlpha = hasAlpha
    GLTools.verifyNoError()
  }

  // Make this the active OpenGL texture
  public func select() {
    ASSERT(textureId  != 0,"tex id is zero")
		glBindTexture(GLenum(GL_TEXTURE_2D), textureId);
  }

  public class func allocId(textureId : GLuint,  context : String = "(unknown context)") {
    if (textureId == 0) {
      return
    }
    if (DB_TEXTURE) {
      puts("=== texture alloc \(textureId), \(context)")
    }
  }
  
  public class func deleteId(textureId : GLuint) {
    if (textureId == 0) {
      return
    }
    if (DB_TEXTURE) {
      puts("=== texture delete \(textureId)")
    }
    
    var textureName = textureId
    glDeleteTextures(1, &textureName)
  }
  
}
