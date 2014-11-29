import Foundation
import UIKit

public class Renderer : NSObject {

	public class func sharedInstance() -> Renderer {
		if (S.singleton == nil) {
			S.singleton = Renderer()
		}
		return S.singleton
	}

  // Reset OpenGL state to our default values
  //
  public func resetOpenGLState() {
    glBlendFunc(GLenum(GL_SRC_ALPHA),GLenum(GL_ONE_MINUS_SRC_ALPHA))
  }

  private struct S {
    static var singleton : Renderer!
  }
  
  private override init() {
    super.init()
  }

  // The size of the default viewport (to restore to if it gets changed); this is
  // the size of the ViewManager's GLKView
  public var defaultViewportSize : CGPoint!
  
  public var transform : CGAffineTransform = CGAffineTransformIdentity {
		didSet {
			invalidateMatrixId()
		}
	}
  
  // Projection matrix identifier; changes whenever the transform property has changed
  public var projectionMatrixId = 10
  

  private func invalidateMatrixId() {
  	projectionMatrixId += 1
  }
  
}

