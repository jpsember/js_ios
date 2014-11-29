import Foundation
import GLKit
import OpenGLES
import UIKit

public func dHex(value:GLenum) -> String {
  return dHex(Int(value))
}

public class GLTools : NSObject {

  private struct S {
    static var programId: GLuint = 0
    static var fboStack = [GLuint]()
  }

  private class func verifyNoProgramError(programId:GLuint, objectParameter:GLenum) {
    var sResultCode: GLint = GLint()
    glGetProgramiv(programId, objectParameter, &sResultCode);
		if (sResultCode == GL_FALSE) {
      die("OpenGL error! Problem with program (parameter \(objectParameter))")
		}
  }

  public class func verifyNoError() {
    let err = glGetError()
    if (err != 0) {
      let message : String = "OpenGL error #\(dHex(err) )"
      warning(message)
      die(message)
    }
  }
  
  public class func verifyFrameBufferStatus() {
  	var status:GLenum
  	status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
    
    if (status != GLenum(GL_FRAMEBUFFER_COMPLETE)) {
      var message = "glCheckFrameBufferStatus is \(dHex(Int(status)))"
      var cause = ""
      switch(status) {
      case GLenum(GL_FRAMEBUFFER_UNSUPPORTED):
       	cause = "FBO unsupported"
      case GLenum(GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT):
        cause = "Not all framebuffer attachment points are framebuffer attachment complete"
      case GLenum(GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS):
        cause = "incomplete dimensions"
      case GLenum(GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT):
        cause = "No images are attached to the framebuffer"
      default:
        cause = "unknown"
      }
      message += " : " + cause
    	die(message)
    }
  }
  
  public class func compileShader(shaderHandle:GLuint) {
    glCompileShader(shaderHandle)
    var compileSuccess: GLint = GLint()
    glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileSuccess)
    if (compileSuccess == GL_FALSE) {
      die("OpenGL errror! Problem compiling shader")
    }
  }

  public class func convertColorToOpenGL(color: UIColor) -> [GLfloat] {
  	var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
  	color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
  	return [GLfloat(red),GLfloat(green),GLfloat(blue),GLfloat(alpha)]
  }

  /**
	 * Create a program; die if unsuccessful
	 *
	 * @return program id
	 */
  public class func createProgram() -> GLuint {
		let programId = glCreateProgram()
		if (programId == 0) {
  		die("OpenGL error! Unable to create program")
    }
		return programId
  }
  
  /**
	 * Link a program; die if unsuccessful
	 */
  public class func linkProgram(programId: GLuint) {
		glLinkProgram(programId)
    verifyNoProgramError(programId, objectParameter:GLenum(GL_LINK_STATUS));
  }
  
  /**
	 * Validate a program; die if unsuccessful
	 */
  public class func validateProgram(programId: GLuint) {
		glValidateProgram(programId);
  	verifyNoProgramError(programId, objectParameter:GLenum(GL_VALIDATE_STATUS));
  }
  
  
  /**
	 * Specify program to use in subsequent calls to getProgramLocation()
	 */
  public class func setProgram(programId: GLuint) {
		S.programId = programId;
  }

  /**
	 * Get location of attribute or uniform within program; die if not found.
	 * Program id must have been previously set via setProgram()
	 *
	 * @param attributeOrUniformName
	 *            name; must have prefix 'a_' or 'u_'
	 * @return
	 */
  public class func getProgramLocation(attributeOrUniformName: String) -> Int {
		var location = -1
		if (attributeOrUniformName.hasPrefix("a_")) {
  		location = Int(glGetAttribLocation(S.programId, attributeOrUniformName))
		} else if (attributeOrUniformName.hasPrefix("u_")) {
  		location = Int(glGetUniformLocation(S.programId, attributeOrUniformName))
    } else {
  		die("unsupported prefix: \(attributeOrUniformName)")
    }
    if (location < 0) {
  		die("OpenGL error! No attribute/uniform found: \(attributeOrUniformName)")
    }
		return location;
  }
  
  // Install UIImage as OpenGL texture; return texture id, and size
  //
  public class func installTexture(image:UIImage, contextName:String = "unknown") -> (GLuint,CGPoint,Bool) {
    
    let error:NSErrorPointer = nil
    let options = [GLKTextureLoaderOriginBottomLeft : true]
    
    let textureInfo = GLKTextureLoader.textureWithCGImage(image.CGImage,options:options,error:error)
    ASSERT(error == nil,"failed to install texture; \(error)")
    Texture.allocId(textureInfo.name,context:"GLToolsAux.installTexture name '\(contextName)'")
  	let alphaInfo = textureInfo.alphaState
    let hasAlpha = (alphaInfo != GLKTextureInfoAlphaState.None)
    return (textureInfo.name,CGPoint(CGFloat(textureInfo.width),CGFloat(textureInfo.height)),hasAlpha)
  }

  public class func pushNewFrameBuffer() -> GLuint {
   	verifyNoError()
  	var fboHandleOld : GLint = 0
  	glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &fboHandleOld)
    verifyNoError()
		S.fboStack.append(GLuint(fboHandleOld))
  
    var fboHandleNew : GLuint = 0
  	glGenFramebuffers(1, &fboHandleNew)
    verifyNoError()
  	glBindFramebuffer(GLenum(GL_FRAMEBUFFER),fboHandleNew)
   	verifyNoError()
    return fboHandleNew
  }
  
  public class func popFrameBuffer() {
    ASSERT(S.fboStack.count > 0,"frame buffer stack is empty")
    
    var fboHandleOld : GLint = 0
    glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &fboHandleOld)
    
    let fboHandle : GLuint = S.fboStack.removeLast()
   	glBindFramebuffer(GLenum(GL_FRAMEBUFFER),fboHandle)
   	verifyNoError()
    verifyFrameBufferStatus()
    var fboHandleOldAsUInt = GLuint(fboHandleOld)
    glDeleteFramebuffers(1, &fboHandleOldAsUInt)
    
  }
  
  // Round an integer up, if necessary, so it's a power of two
  public class func smallestPowerOfTwoScalar(value : Int) -> Int {
    ASSERT(value >= 1)
    var ret = 1
    while (ret < value) {
      ret *= 2
    }
		return ret
  }
  
  // Round a size up, if necessary, so it's a power of two in each dimension
  public class func smallestPowerOfTwo(size : CGPoint) -> CGPoint {
  	return CGPoint(smallestPowerOfTwoScalar(size.ix),smallestPowerOfTwoScalar(size.iy))
  }

  // Dump an OpenGL transformation matrix, which is an array of 16 CGFloats
  public class func dumpTransform(m:UnsafePointer<CGFloat>) -> String {
    let f = "%8.4f  "
    var s = ""
    for var i = 0; i < 16; i++ {
      if (i % 4 == 0) {
        s += "[ "
      }
      let j = (i % 4) * 4 + (i / 4)
      s += d(m[j],f)
      if (i % 4 == 3) {
        s += "]\n"
      }
    }
   	return s
  }

}
