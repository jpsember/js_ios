import Foundation
import UIKit

public class Renderer : NSObject {

  private struct S {
    static var containerSize : CGPoint!
    
    // The size of the default viewport (to restore to if it gets changed)
    static var defaultViewportSize : CGPoint!
    
    static var verticalFlipFlag = false
    
    static var projectionMatrixId = 10
    static var transform : CGAffineTransform!
  }
  
  private class func invalidateMatrixId() {
  	S.projectionMatrixId += 1
  }

  public class func setContainerSize(size:CGPoint) {
    S.containerSize = size
  }
  
  public class func getContainerSize() -> CGPoint {
    return S.containerSize
  }

  public class func setDefaultViewportSize(size:CGPoint) {
    S.defaultViewportSize = size
  }

  public class func getDefaultViewportSize() -> CGPoint {
    return S.defaultViewportSize
  }

  public class func setVerticalFlipFlag(flag : Bool) {
    S.verticalFlipFlag = flag
  }
  
  public class func getVerticalFlipFlag() -> Bool {
    return S.verticalFlipFlag
  }

  /**
	 * Get the projection matrix identifier. This changes each time the
	 * projection matrix changes, and can be used to determine if a previously
	 * cached matrix is valid
	 *
	 * @return id, a positive integer (if surface has been created)
	 */
  public class func getProjectionMatrixId() -> Int {
		return S.projectionMatrixId
  }
  
  public class func setTransform(transform:CGAffineTransform) {
  	invalidateMatrixId()
  	S.transform = transform
  }
  
  public class func getTransform() -> CGAffineTransform {
    return S.transform
  }

  // Reset OpenGL state to our default values
  //
  public class func resetOpenGLState() {
    glBlendFunc(GLenum(GL_SRC_ALPHA),GLenum(GL_ONE_MINUS_SRC_ALPHA))
  }

}

