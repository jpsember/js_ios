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
    
    select()
  }

  // Make this the active OpenGL texture
  //
  public func select() {
		glBindTexture(GLenum(GL_TEXTURE_2D), textureId!);
  }

}
