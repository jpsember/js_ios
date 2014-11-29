import Foundation
import UIKit

public typealias Matrix = CGAffineTransform

public class Renderer : NSObject {

  private struct S {
    static var renderer : Renderer!
  }

  public class func sharedInstance() -> Renderer {
    if (S.renderer == nil) {
      S.renderer = Renderer()
    }
    return S.renderer
  }
  
  private override init() {
  	super.init()
  }
  
  public var containerSize : CGPoint!
  
  // The size of the default viewport (to restore to if it gets changed)
  public var defaultViewportSize : CGPoint!
  
  public var verticalFlipFlag = false
  
  private var matrixId = 10
  private var transform : CGAffineTransform!
  
  private func invalidateMatrixId() {
  	matrixId += 1
  }

  /**
	 * Get the projection matrix identifier. This changes each time the
	 * projection matrix changes, and can be used to determine if a previously
	 * cached matrix is valid
	 *
	 * @return id, a positive integer (if surface has been created)
	 */
  public func projectionMatrixId() -> Int {
		// TODO: consider renaming this to 'Surface Id' or something, since in
		// addition to projection matrices,
		// OpenGL programs and shaders are also no longer valid.. or are they
		// only no longer valid when a surface is created as opposed to changed?
		return matrixId
  }
  
  public func setTransform(transform:CGAffineTransform) {
  	invalidateMatrixId()
  	self.transform = transform
  }
  
  public func getTransform() -> CGAffineTransform {
    return transform
  }
  

}

