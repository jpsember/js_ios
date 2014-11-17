import Foundation
import GLKit

public class Texture : NSObject {
 
  private var textureId: GLuint? = nil
  public var width = 0
  public var height = 0
  
  // Load UImage from resource "<name>.png"
  //
  private func loadUImage(name: String) -> UIImage? {
    let url = NSBundle.mainBundle().URLForResource(name, withExtension: "png")
    var err: NSError?
    var imageData = NSData(contentsOfURL:url!, options:NSDataReadingOptions.DataReadingMappedIfSafe, error:&err)
    return UIImage(data: imageData!)
  }
  
  // Load texture's bitmap from a resource '<name>.png'
  //
  public func loadBitmap(name: String) {
    let uImage = loadUImage(name)
    
    var textureSize = CGPoint()
    textureId = GLTools2.installTexture(uImage, size:&textureSize)
    self.width = Int(textureSize.x)
    self.height = Int(textureSize.y)
    GLTools.verifyNoError()
    
    select()
  }

  public func select() {
		glBindTexture(GLenum(GL_TEXTURE_2D), textureId!);
  }

}
