import Foundation
import UIKit

public typealias Matrix = CGAffineTransform

public class Renderer : NSObject {

  private var transformMap = [String:CGAffineTransform]()
  private var deviceSize: Point?
  private var matrixId = 10
  private var surfaceId = 10

  public class func transformNameDeviceToNDC() -> String {
    return "device->ndc"
  }
  
  private func invalidateMatrixId() {
  	matrixId += 1
  }

  public func surfaceCreated(viewSizeInPixels : Point) {
    surfaceId += 1
    
    deviceSize = viewSizeInPixels
    invalidateMatrixId()
    constructTransforms()
    
    SpriteContext.prepare(self)
  }
  
  /**
	 * Construct transformation matrices for the current surface. Default
	 * implementation throws out any old transforms, and generates
	 * TRANSFORM_NAME_DEVICE_TO_NDC which converts from device space to
	 * normalized device coordinates (see
	 * https://github.com/jpsember/geometry/issues/22)
	 *
	 * Here's a summary of the coordinate spaces:
	 *
	 * <pre>
	 *
	 *  algorithm space : this maps a fixed virtual coordinate system
	 *      (e.g. 1000 x 1200) to the device, no matter its size or
	 *      orientation (origin at bottom left)
	 *
	 *  device space : origin at bottom left, this corresponds to pixels
	 *
	 *  normalized device coordinates : the coordinate system that OpenGL
	 *     uses
	 *
	 *  view space : the coordinate system of an Android View; like device
	 *     space, but has its origin in the top left
	 *
	 * </pre>
	 */
  private func constructTransforms() {
    transformMap.removeAll()
    addTransform(Renderer.transformNameDeviceToNDC(),buildDeviceToNDCProjectionMatrix());
  }
  
  /**
	 * Get the projection matrix identifier. This changes each time the
	 * projection matrix changes, and can be used to determine if a previously
	 * cached matrix is valid
	 *
	 * @return id, a positive integer (if surface has been created)
	 */
  public func projectionMatrixId() -> Int {
		// TODO: consider renaming this to 'Surface Id' or something, since in
		// addition to projection matrices,
		// OpenGL programs and shaders are also no longer valid.. or are they
		// only no longer valid when a surface is created as opposed to changed?
		return matrixId
  }

  /**
	 * Construct matrix to transform from device coordinates to OpenGL's
	 * normalized device coordinates (-1,-1 ... 1,1)
	 */
  private func buildDeviceToNDCProjectionMatrix() -> CGAffineTransform  {
    let w = deviceSize!.x
    let h = deviceSize!.y
  	let sx = 2 / w
  	let sy = 2 / h
    
    let scale = CGAffineTransformMakeScale(sx, sy)
    let translate = CGAffineTransformMakeTranslation(-w/2,-h/2)
    let result = CGAffineTransformConcat(translate,scale)
    
    return result
  }
  
  /**
	 * Add a transformation matrix
	 *
	 * @param name
	 *            unique name for the matrix
	 * @param transform
	 *            the matrix
	 */
  public func addTransform(name: String, _ transform: CGAffineTransform) {
//    puts("adding transform \(name):\n\(transform)")
    transformMap[name] = transform
  }

  public func getTransform(key: String) -> CGAffineTransform {
    if let m = transformMap[key] {
      return m
    }
    die("transform map contains no key '\(key)'")
    return transformMap[key]!
  }
  

}

