import GLKit
import OpenGLES

public class ViewManager : NSObject, GLKViewDelegate {
  
  public init(bounds : CGRect) {
    self.bounds = bounds
    super.init()
    
    buildBaseView()
  }
  
  private var bounds : CGRect

  // The UIView that contains the manager's views
  //
  private(set) var baseUIView : UIView!
  
  // The root view in the manager hierarchy
  //
  public var rootView : View!
  
  private func buildBaseView() {
    let view = OurGLKView(frame:bounds)
    view.delegate = self
    baseUIView = view
  }
  
  // Manager's GLKViewDelegate; ideally would be private
  //
  public func glkView(view : GLKView!, drawInRect : CGRect) {
    Texture.processDeleteList()
    
    // Clear the GLKView 
    glClearColor(0.0, 0.5, 0.1, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    GLTools.verifyNoError()
    GLTools.initializeOpenGLState()
    
    prepareGraphics(view.bounds.ptSize)
    
    // If a root view is defined, plot it
    if rootView == nil {
    	warning("no root view has been defined for ViewManager")
      return
    }
    
    let containerSize = self.bounds.ptSize
		let containerOrigin = CGPoint.zero
  	plotAux(containerSize,containerOrigin,rootView)
  }
  
  private func plotAux(containerSize:CGPoint, _ parentOrigin:CGPoint, _ view:View) {
  	view.plot(containerSize,parentOrigin)
    let thisOrigin = CGPoint.sum(parentOrigin,view.bounds.origin)
    for v in view.children {
    	plotAux(containerSize,thisOrigin,v)
    }
  }
  
  private var renderer : Renderer!
  private var preparedViewSize = CGPoint.zero

  private func prepareGraphics(viewSize : CGPoint) {
    // If previous size undefined, or different than new, invalidate old graphic elements
    if (preparedViewSize == viewSize) {
      return
    }
    preparedViewSize = viewSize
    if (renderer == nil) {
      renderer = Renderer()
    }
    renderer.surfaceCreated(CGPoint(preparedViewSize))
 		invalidateAllViews()
  }

  private func invalidateAllViews() {
    if (rootView != nil) {
    	invalidateSubtree(rootView)
    }
  }
  
  private func invalidateSubtree(rootView : View) {
    rootView.invalidate()
    for v in rootView.children {
      invalidateSubtree(v)
    }
  }
  
  // Our subclass of GLKView
  
  private class OurGLKView: GLKView  {
    
    private override init(frame:CGRect) {
      let c = EAGLContext(API:EAGLRenderingAPI.OpenGLES2)
      super.init(frame:frame, context:c)
    }
    
    private required init(coder decoder: NSCoder) {
      super.init(coder: decoder)
    }
    
  }

}
