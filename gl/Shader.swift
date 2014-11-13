import Foundation
import UIKit
//import OpenGLES


public class Shader {

  public class func readVertexShader(filename : String) -> Shader {
    let shader = Shader(type: Type.Vertex)
    let source = shader.readSource(filename)
		shader.compileSource(source!)
		return shader
  }
  
  public class func readFragmentShader(filename : String) -> Shader {
    let shader = Shader(type: Type.Fragment)
    let source = shader.readSource(filename)
    shader.compileSource(source!)
    return shader
  }

  private var type : Type
  private var shaderId : GLuint?

  private enum Type {
    case Vertex, Fragment
  }
  
  private init(type: Type) {
    self.type = type
  }

  private func compileSource(source: String) {
  	shaderId = glCreateShader(GLenum(self.type == Type.Vertex ? GL_VERTEX_SHADER : GL_FRAGMENT_SHADER))
    ASSERT(shaderId != nil)
    
    // Convert shader string to CString and call glShaderSource to give OpenGL the source for the shader.
    var shaderStringUTF8 = (source as NSString).UTF8String
    var shaderStringLength: GLint = Int32(source.lengthOfBytesUsingEncoding(NSString.defaultCStringEncoding()))
    glShaderSource(shaderId!, 1, &shaderStringUTF8, &shaderStringLength)
    
    GLTools.compileShader(shaderId!)
  }
  
  private func readSource(filename: String) -> String? {
    var error: NSError?
    let url = NSBundle.mainBundle().URLForResource(filename, withExtension:nil)
		let content = String.readFromPath(url!.path!, error:&error)
    ASSERT(content != nil)
    return content
  }
  
  deinit {
    if let shader = shaderId {
    	glDeleteShader(shader)
    }
  }
  
}
