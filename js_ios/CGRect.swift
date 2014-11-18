import Foundation

import UIKit

public func == (lhs: CGRect, rhs: CGRect) -> Bool {
  return lhs.x == rhs.x && lhs.y == rhs.y && lhs.width == rhs.width && lhs.height == rhs.height
}

extension CGRect :  Printable {
  
  public init(_ x:CGFloat, _ y:CGFloat, _ width:CGFloat, _ height:CGFloat) {
    self.origin = CGPoint(x,y)
    self.size = CGSize(width:width,height:height)
  }
  
  public init(_ pt1:CGPoint, _ pt2:CGPoint) {
    self.origin = CGPoint(min(pt1.x,pt2.x),min(pt1.y,pt2.y))
    self.size = CGSize(width:max(pt1.x,pt2.x) - self.origin.x, height:max(pt1.y,pt2.y) - self.origin.y)
  }
  
  public var x: CGFloat {
    get {
      return self.origin.x
    }
    set {
      self.origin.x = newValue
    }
  }
  
  public var y: CGFloat {
    get {
      return self.origin.y
    }
    set {
      self.origin.y = newValue
    }
  }
  
  public var width: CGFloat {
    get {
      return self.size.width
    }
    set {
      self.size.width = newValue
    }
  }
  
  public var height: CGFloat {
    get {
      return self.size.height
    }
    set {
      self.size.height = newValue
    }
  }

  public var xMid: CGFloat {
    return x + width/2
  }
  
  public var yMid: CGFloat {
    return y + height/2
	}
  
  public var xMax: CGFloat {
    return x + width
  }
  
  public var yMax: CGFloat {
    return y + height
  }

  public var maxDim: CGFloat {
    return max(width,height)
	}

  public var minDim: CGFloat {
    return min(width,height)
	}

  public var midPoint: CGPoint {
    return CGPoint(x+width/2,y+height/2)
  }
  
  public mutating func setTo(x:CGFloat, _ y:CGFloat, _ width:CGFloat, _ height:CGFloat) {
    self.origin = CGPoint(x,y)
    self.size = CGSize(width:width, height:height)
  }
  
  public mutating func setTo(source : CGRect) {
		setTo(source.x,source.y,source.width,source.height)
	}

  public var description : String {
    return "(x:\(d(x))y:\(d(y))w:\(d(width))h:\(d(height)))"
	}

  public mutating func inset(dx:CGFloat,dy:CGFloat) {
    x += dx
    y += dy
    width -= 2*dx
    height -= 2*dy
	}

  /**
  * Get point for corner of rectangle
  *
  * @param i
  *            corner number (0..3), bottomleft ccw to topleft
  * @return corner
  */
  public func corner(i : Int) -> CGPoint {
    
    switch (i) {
    
    case 0:
      return CGPoint(x,y)
    
    case 1:
      return CGPoint(xMax,y)
    
    case 2:
      return CGPoint(xMax,yMax)
    
    case 3:
      return CGPoint(x,yMax)
      
    default: die("Illegal Argument")
    	return CGPoint.zero
    }
    
  }

  public mutating func include(point : CGPoint) {
    let nx = min(x, point.x)
    let ny = min(y, point.y)
    let nw = max(point.x, xMax) - nx
    let nh = max(point.y, yMax) - ny

    setTo(nx,ny,nw,nh)
  }
  
  public mutating func include(r : CGRect) {
    include(r.corner(0))
    include(r.corner(2))
  }
  
  public func contains(point : CGPoint) -> Bool {
    return x <= point.x && y <= point.y && xMax >= point.x && yMax >= point.y
  }
  
  public func contains(r : CGRect) -> Bool {
    return x <= r.x && y <= r.y && xMax >= r.xMax && yMax >= r.yMax
  }
  
  public mutating func translate(amount : CGPoint) {
  	x += amount.x
    y += amount.y
  }
  
  public static func containingPoints(p1:CGPoint, p2:CGPoint) -> CGRect {
    let m1 = CGPoint(min(p1.x,p2.x), min(p1.y,p2.y))
    let m2 = CGPoint(max(p1.x,p2.x), max(p1.y,p2.y))
    return CGRect(m1.x,m1.y,m2.x-m1.x,m2.y-m1.y)
  }
  
}
