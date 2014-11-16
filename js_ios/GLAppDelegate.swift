import GLKit

@UIApplicationMain // Allows us to omit a main.m file
public class GLAppDelegate : AppDelegate, GLKViewDelegate {
  
  public func glkView(view : GLKView!, drawInRect : CGRect) {
    
    GLTools.verifyNoError()
    
    // A nice green color
    glClearColor(0.0, 0.5, 0.1, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    GLTools.verifyNoError()
    
    let t = Texture()
    var pngName = "sample"
    pngName = "AlphaBall"
    
    t.loadBitmap(pngName)
    
    let vertexShader = Shader.readVertexShader("vertex_shader_texture.glsl")
    let fragmentShader = Shader.readFragmentShader("fragment_shader_texture.glsl")
    let renderer = Renderer()
    
    renderer.surfaceCreated(Point(view.bounds.size))
    let spriteContext = GLSpriteContext(transformName:Renderer.transformNameDeviceToNDC(), tintMode:false )
    
    let tw = CGRectMake(0,0,CGFloat(t.width),CGFloat(t.height))
    let spriteProgram = GLSpriteProgram(context: spriteContext, texture: t, window: tw)
    spriteProgram.setPosition(20,y:20)
    spriteProgram.render()
    GLTools.verifyNoError()
  }
  
  override public func buildView() -> UIView {
    let view = GLView(frame:self.window!.bounds)
    view.delegate = self
    return view
  }
  
}
