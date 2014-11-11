import GLKit

@UIApplicationMain // Allows us to omit a main.m file
public class GLAppDelegate : JSAppDelegate, GLKViewDelegate {
    
    public func glkView(view : GLKView!, drawInRect : CGRect) {
        // A nice green color
        glClearColor(0.0, 0.5, 0.1, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    override public func buildView() -> UIView {
        let view = JSGLView(frame:self.window!.bounds)
        view.delegate = self
        return view
    }
    
}
