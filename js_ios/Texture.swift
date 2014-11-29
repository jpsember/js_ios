import Foundation
import GLKit

public let DB_TEXTURE = cond(false)

public class Texture : NSObject {
 
  private(set) var textureId : GLuint = 0
  public var width = 0
  public var height = 0
  public var hasAlpha = false
  
  public var size : CGPoint {
    get {
			return CGPoint(width,height)
		}
	}

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
    self.textureId = textureId
    self.width = size.ix
    self.height = size.iy
    self.hasAlpha = hasAlpha

    select()
    
    let format = hasAlpha ? GLint(GL_RGBA) : GLint(GL_RGB)
    
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
    
    _setRepeat(withRepeat)
        
    // Unbind existing texture... we're done with it
    unselect()
  }
  
  private func _setRepeat(repeat:Bool) {
    let wrapType = repeat ? GLint(GL_REPEAT) : GLint(GL_CLAMP_TO_EDGE)
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), wrapType);
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), wrapType);
  }
  
  public func setRepeat(_ repeat:Bool = true) {
    select()
    _setRepeat(repeat)
    // Unbind existing texture... we're done with it
    unselect()
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
		glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
  }

  public func unselect() {
    glBindTexture(GLenum(GL_TEXTURE_2D), 0)
  }
  
  public class func allocId(textureId : GLuint,  context : String = "(unknown context)") {
    if (textureId == 0) {
      return
    }
    Texture.dbMessage("texture alloc \(textureId), \(context)")
  }
  
  deinit {
    Texture.dbMessage("adding \(textureId) to delete list")
    TextureTools.addIdToDeleteList(textureId)
  }
  
  public class func dbMessage(message : String) {
    if (DB_TEXTURE) {
    	puts("=== \(message)")
    }
  }
  
}
