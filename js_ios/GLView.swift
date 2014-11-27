import GLKit
import OpenGLES

public class GLView: GLKView, GLKViewDelegate {
  
  override public var description: String {
    return "frame=\(self.frame)"
  }
  
  // Factory constructor
  public class func build(#frame:CGRect) -> GLView {
    return GLView(frame:frame)
  }
  
  public override init(frame:CGRect) {
    let c = EAGLContext(API:EAGLRenderingAPI.OpenGLES2)
    super.init(frame:frame, context:c)
    delegate = self
  }
  
  public required init(coder decoder: NSCoder) {
    super.init(coder: decoder)
  }
  
  public func glkView(view : GLKView!, drawInRect : CGRect) {
    // A nice green color
    glClearColor(0.0, 0.5, 0.1, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
  }
  
}
