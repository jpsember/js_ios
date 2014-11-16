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
  
  // Plot UImage to a context; return (width, height, CGContext)
  //
  private func plotUImage(bgImage: UIImage) -> (Int,Int,CGContext!) {
    let width = UInt(bgImage.size.width)
    let height = UInt(bgImage.size.height)
    
    let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
    
    let context = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, bitmapInfo)
    
		var rect = CGRectMake(0, 0, CGFloat(width), CGFloat(height))
    CGContextDrawImage(context, rect, bgImage.CGImage)
    
    return (Int(width),Int(height),context)
  }
  
  // Load texture's bitmap from a resource '<name>.png'
  //
  public func loadBitmap(name: String) {
    puts("attempting to load \(name)")
  	let uImage = loadUImage(name)
    puts("loaded \(name): \(uImage)")
    
    // Draw UIImage to CGContext
    let (width,height,context) = plotUImage(uImage!)
    self.width = width
    self.height = height
    
    // Create GL Texture
    var texture: GLuint = 0;
    glGenTextures(GLsizei(1), &texture);
    GLTools.verifyNoError()
    
    glBindTexture(GLenum(GL_TEXTURE_2D), texture);
    GLTools.verifyNoError()
    
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR);
    
    glTexImage2D(
      GLenum(GL_TEXTURE_2D),
      GLint(0),
      GL_RGBA,
      GLsizei(width),
      GLsizei(height),
      GLint(0),
      GLenum(GL_RGBA),
      GLenum(GL_UNSIGNED_BYTE),
      CGBitmapContextGetData(context))
    
    GLTools.verifyNoError()
    
    textureId = texture
  }

  public func select() {
		glBindTexture(GLenum(GL_TEXTURE_2D), textureId!);
  }

}
