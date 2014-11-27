import GLKit
import OpenGLES

public class ViewManager : NSObject, GLKViewDelegate {
  
  public init(bounds : CGRect) {
    self.bounds = bounds
    super.init()
    
    buildBaseView()
  }
  
  // The UIView that contains the manager's views
  //
  public var baseUIView : UIView {
    get {
      return _baseView!
    }
  }
  
  // The root view in the manager hierarchy
  //
  public var rootView : View {
    set {
      _rootView = newValue
    }
    get {
      return _rootView!
    }
  }
  
  private var bounds : CGRect
  private var _baseView : GLKView?
  private var _rootView : View?
  
  private func buildBaseView() {
    let view = GLView(frame:bounds)
    view.delegate = self
    _baseView = view
  }
  
  // Manager's GLKViewDelegate; ideally would be private
  //
  public func glkView(view : GLKView!, drawInRect : CGRect) {
    GLTools.verifyNoError()
    Texture.processDeleteList()
    
    // Clear the GLKView 
    glClearColor(0.0, 0.5, 0.1, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    GLTools.verifyNoError()
    GLTools.initializeOpenGLState()
    
    // TODO: allow root view to be non-cachable and perform the above clear & initialization steps
    
    prepareGraphics(view!.bounds.size)
    
    // If a root view is defined, plot it
    if let rv = _rootView {
      rv.plot()
    } else {
    	warning("no root view has been defined for ViewManager")
    }
  }
  
  private var renderer : Renderer?
  private var preparedViewSize  = CGSizeMake(0,0)

  private func prepareGraphics(viewSize : CGSize) {
    // If previous size undefined, or different than new, invalidate old graphic elements
    if (preparedViewSize == viewSize) {
      return
    }
    preparedViewSize = viewSize
    if (renderer == nil) {
      renderer = Renderer()
    }
    renderer!.surfaceCreated(CGPoint(preparedViewSize))
  }

}
