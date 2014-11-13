import Foundation
import UIKit

public struct SpriteContextGlobals {
//  var renderer :
  public static var normalContext : SpriteContext? = nil
}


public class SpriteContext {

  private let positionComponentCount = 2
  private let textureComponentCount = 2
  private let totalComponents = 4
  
  private let transformName: String
  private var tintColor: [Float]?
  private var tintMode: Bool
  
  private var s = SpriteContextGlobals() //<< pseudo class var
  
  
  private var preparedProjectionMatrixId = 0
  private var preparedSurfaceId = 0
  private var programObjectId = 0
  private var positionLocation = 0
  private var textureCoordinateLocation = 0
  private var matrixLocation = 0
  private var spritePositionLocation = 0
  private var vertexShader: Shader?
  private var fragmentShader: Shader?
  private var colorLocation = 0
  
//  private static OurGLRenderer sRenderer;
//  private static SpriteContext sNormalContext;

  public init(transformName: String, tintMode: Bool = false) {
  	self.transformName = transformName
    self.tintMode = tintMode
    if (tintMode) {
      tintColor = [0,0,0,0]
    }
  }
  
  public func setTintColor(color: UIColor) {
		ASSERT(tintMode)
		tintColor = GLTools.convertColorToOpenGL(color)
  }

  private func prepareShaders() {
    // How do we...
//    let context = s.normalContext
    
		vertexShader = Shader.readVertexShader("vertex_shader_texture.glsl")
    fragmentShader = Shader.readFragmentShader(tintMode ? "fragment_shader_mask.glsl" : "fragment_shader_texture.glsl")
  }
  

}

/*

public class SpriteContext {


  public void renderSprite(GLTexture mTexture, FloatBuffer vertexData,
  Point mPosition) {
		activateProgram();
  
		prepareProjection();
  
		glUniform2f(mSpritePositionLocation, mPosition.x, mPosition.y);
  
		if (mTintMode) {
  // Send one vec4 (the second parameter; this was a gotcha)
  glUniform4fv(mColorLocation, 1, mTintColor, 0);
		}
  
		mTexture.select();
  
		GLTools.verifyNoError();
		vertexData.position(0);
		int stride = TOTAL_COMPONENTS * BYTES_PER_FLOAT;
  
		glVertexAttribPointer(mPositionLocation, POSITION_COMPONENT_COUNT,
  GL_FLOAT, false, stride, vertexData);
		glEnableVertexAttribArray(mPositionLocation);
  
		vertexData.position(POSITION_COMPONENT_COUNT);
		glVertexAttribPointer(mTextureCoordinateLocation,
  TEXTURE_COMPONENT_COUNT, GL_FLOAT, false, stride, vertexData);
		glEnableVertexAttribArray(mTextureCoordinateLocation);
		glDrawArrays(GL_TRIANGLES, 0, 6);
		GLTools.verifyNoError();
  }
  
  /**
	 * Must be called by onSurfaceCreated()
	 *
	 * @param context
	 */
  public static void prepare(OurGLRenderer renderer) {
		sRenderer = renderer;
  
		sNormalContext = new SpriteContext(
  OurGLRenderer.TRANSFORM_NAME_DEVICE_TO_NDC, false);
  }
  
  private void prepareShaders() {
		Context context = sRenderer.context();
		mVertexShader = GLShader.readVertexShader(context,
  R.raw.vertex_shader_texture);
		mFragmentShader = GLShader.readFragmentShader(context,
  mTintMode ? R.raw.fragment_shader_mask
  : R.raw.fragment_shader_texture);
  }
  
  /**
	 * Select this context's OpenGL program. Also, prepares the program (and
	 * associated shaders) if it hasn't already been done. We don't do this in
	 * the constructor, since it must be done within the OpenGL thread
	 */
  protected void activateProgram() {
		int currentSurfaceId = sRenderer.surfaceId();
		if (currentSurfaceId != mPreparedSurfaceId) {
  mPreparedSurfaceId = currentSurfaceId;
  prepareShaders();
  prepareProgram();
		}
  
		glUseProgram(mProgramObjectId);
  }
  
  private void prepareProgram() {
		mProgramObjectId = GLTools.createProgram();
		glAttachShader(mProgramObjectId, mVertexShader.getId());
		glAttachShader(mProgramObjectId, mFragmentShader.getId());
		GLTools.linkProgram(mProgramObjectId);
		GLTools.validateProgram(mProgramObjectId);
		prepareAttributes();
  }
  
  private void prepareAttributes() {
		GLTools.setProgram(mProgramObjectId);
		mPositionLocation = GLTools.getProgramLocation("a_Position");
		mSpritePositionLocation = GLTools
  .getProgramLocation("u_SpritePosition");
		mTextureCoordinateLocation = GLTools
  .getProgramLocation("a_TexCoordinate");
		mMatrixLocation = GLTools.getProgramLocation("u_Matrix");
  
		if (mTintMode) {
  mColorLocation = GLTools.getProgramLocation("u_InputColor");
		}
  }
  
  /**
	 * Convenience methods to calculate index of matrix element from row-major,
	 * 3x3 matrix
	 *
	 * @param row
	 * @param col
	 * @return
	 */
  private static int i3(int row, int col) {
		return row * 3 + col;
  }
  
  private void prepareProjection() {
		int currentProjectionMatrixId = sRenderer.projectionMatrixId();
		if (currentProjectionMatrixId == mPreparedProjectionMatrixId)
  return;
		mPreparedProjectionMatrixId = currentProjectionMatrixId;
  
		// Transform 2D screen->NDC matrix to a 3D version
		float v3[] = new float[9];
		sRenderer.getTransform(mTransformName).getValues(v3);
  
		float v4[] = new float[16];
		v4[i4(0, 0)] = v3[i3(0, 0)];
		v4[i4(0, 1)] = v3[i3(0, 1)];
		v4[i4(0, 2)] = 0;
		v4[i4(0, 3)] = v3[i3(0, 2)];
  
		v4[i4(1, 0)] = v3[i3(1, 0)];
		v4[i4(1, 1)] = v3[i3(1, 1)];
		v4[i4(1, 2)] = 0;
		v4[i4(1, 3)] = v3[i3(1, 2)];
  
		v4[i4(2, 0)] = 0;
		v4[i4(2, 1)] = 0;
		v4[i4(2, 2)] = 1;
		v4[i4(2, 3)] = 0;
  
		v4[i4(3, 0)] = v3[i3(2, 0)];
		v4[i4(3, 1)] = v3[i3(2, 1)];
		v4[i4(3, 2)] = 0;
		v4[i4(3, 3)] = v3[i3(2, 2)];
  
		glUniformMatrix4fv(mMatrixLocation, 1, false, v4, 0);
  }
  
  /**
	 * Convenience methods to calculate index of matrix element from
	 * column-major, 4x4 matrix
	 *
	 * @param row
	 * @param col
	 * @return
	 */
  private static int i4(int row, int col) {
		return col * 4 + row;
  }
  
  public static SpriteContext normalContext() {
		return sNormalContext;
  }
}
*/