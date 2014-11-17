import Foundation
import GLKit
import OpenGLES
import UIKit

public class GLTools : NSObject {

  private struct S {
    static var programId: GLuint = 0
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
      warning("OpenGL error #\(err)")
      die("OpenGL error! Number \(err)")
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
  
}
