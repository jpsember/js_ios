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
  
  convenience init(size:CGPoint,hasAlpha:Bool,withRepeat:Bool,context:String = "unknown") {
    self.init()
    
    var textureId : GLuint = 0
      
    glGenTextures(1, &textureId)
    
    Texture.allocId(textureId,context:"Texture.init, context '\(context)'")
    
    let format = hasAlpha ? GLint(GL_RGBA) : GLint(GL_RGB)
        
    glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
    
    glTexImage2D( GLenum(GL_TEXTURE_2D),
        0,
        format,
        GLsizei(size.x), GLsizei(size.y),
        0,
        GLenum(format),
        GLenum(GL_UNSIGNED_BYTE),
        UnsafePointer<Void>(nil))
        
    // Set up parameters for this particular texture
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR);
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR);
        
    let wrapType = withRepeat ? GLint(GL_REPEAT) : GLint(GL_CLAMP_TO_EDGE)
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), wrapType);
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), wrapType);
        
    // Unbind existing texture... we're done with it
    glBindTexture(GLenum(GL_TEXTURE_2D), 0);
    
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
