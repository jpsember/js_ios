import GLKit
import OpenGLES

public class ViewManager : NSObject, GLKViewDelegate {
  
  public init(bounds : CGRect) {
    self.bounds = bounds
    super.init()
    
    buildBaseView()
  }
  
  public var baseView : UIView {
    get {
      return _baseView!
    }
  }
  
  private var bounds : CGRect
  private var _baseView : GLKView?
  
  private func buildBaseView() {
    let view = GLView(frame:bounds)
    view.delegate = self
    _baseView = view
  }
  
  public func glkView(view : GLKView!, drawInRect : CGRect) {
    GLTools.verifyNoError()
    Texture.processDeleteList()
    
    // A nice green color
    glClearColor(0.0, 0.5, 0.1, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    GLTools.verifyNoError()
    GLTools.initializeOpenGLState()
  }
  
}
