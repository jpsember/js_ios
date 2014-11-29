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

	//
	public var containerSize : CGPoint!
  // The size of the default viewport (to restore to if it gets changed)
  public var defaultViewportSize : CGPoint!
	// Projection matrix identifier; changes whenever it's determined a new matrix needs to be constructed
  public var projectionMatrixId = 10
  public var transform : CGAffineTransform = CGAffineTransformIdentity {
		didSet {
			invalidateMatrixId()
		}
	}
  
  private func invalidateMatrixId() {
  	projectionMatrixId += 1
  }
  
}

