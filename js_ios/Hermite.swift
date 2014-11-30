import Foundation

// See p. 483, Foley, van Dam et al, 2nd edition

public class HermitePath : NSObject {
  
  private(set) var p1 : CGPoint
  private(set) var p2 : CGPoint
  private(set) var v1 : CGPoint
  private(set) var v2 : CGPoint

  /*
	 * Construct hermite path from one point to another
	 * > pt1, pt2  start and finish points
	 * > v1, v2    velocities at start, finish points, in pixels per second
	 */
  public init(pt1:CGPoint, pt2:CGPoint, v1:CGPoint, v2:CGPoint) {
    self.p1 = pt1
    self.p2 = pt2
    self.v1 = v1
    self.v2 = v2
  }
  
  // Evalulate position and velocity along path, given parameter t (0..1);
  // returns (position, velocity)
  //
  public func evaluateAt(t:CGFloat) -> (CGPoint, CGPoint) {
    return (positionAt(t), velocityAt(t))
  }
  
  // Evalulate position along path, given parameter t (0..1);
  //
  public func positionAt(t:CGFloat) -> CGPoint {
  
    let t2 : CGFloat = t * t
		let t3 : CGFloat = t2 * t
  
		let c2 : CGFloat = -2 * t3 + 3 * t2
		let c1 : CGFloat = -c2 + 1
		let c3 : CGFloat = t3 - 2 * t2 + t
		let c4: CGFloat = t3 - t2
  
    let px : CGFloat = c1 * p1.x + c2 * p2.x + c3 * v1.x + c4 * v2.x
    let py : CGFloat = c1 * p1.y + c2 * p2.y + c3 * v1.y + c4 * v2.y
    return CGPoint(px,py)
  }
  
  // Evalulate velocity along path, given parameter t (0..1);
  public func velocityAt(t:CGFloat) -> CGPoint {
    let t2 : CGFloat = t * t
		
    let c1 : CGFloat = 6 * t2 - 6 * t
    let c2 : CGFloat = -c1
    let c3 : CGFloat  = 3 * t2 - 4 * t + 1
    let c4 : CGFloat  = 3 * t2 - 2 * t
    
    let vx : CGFloat = c1 * p1.x + c2 * p2.x + c3 * v1.x + c4 * v2.x
    let vy : CGFloat = c1 * p1.y + c2 * p2.y + c3 * v1.y + c4 * v2.y
    return CGPoint(vx,vy)
  }
  
}
