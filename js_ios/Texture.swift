import Foundation
import GLKit

public class Texture : NSObject {
 
  private var textureId: GLuint? = nil
  public var width = 0
  public var height = 0
  public var hasAlpha = false
  
  public var bounds: CGRect {
    return CGRectMake(0,0,CGFloat(width),CGFloat(height))
  }
  
  // Constructor
  // 
  init(_ pngName:String) {
    super.init()
    loadBitmap(pngName)
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
    let (textureId,textureSize,hasAlpha) = GLTools.installTexture(uImage!)
   	self.textureId = textureId
    self.width = Int(textureSize.x)
    self.height = Int(textureSize.y)
    self.hasAlpha = hasAlpha
    GLTools.verifyNoError()
  }

  // Make this the active OpenGL texture
  //
  public func select() {
		glBindTexture(GLenum(GL_TEXTURE_2D), textureId!);
    
    // We must set the wrapping / clamping options for each individual texture.
    
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLint(GL_REPEAT))
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLint(GL_REPEAT))
    
    glTexParameteri(GLenum(GL_TEXTURE_2D),GLenum(GL_TEXTURE_MAG_FILTER),GL_LINEAR)
    glTexParameteri(GLenum(GL_TEXTURE_2D),GLenum(GL_TEXTURE_MIN_FILTER),GL_LINEAR)
  }

}
