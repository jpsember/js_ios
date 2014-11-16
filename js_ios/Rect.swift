import Foundation

import UIKit

public func == (lhs: Rect, rhs: Rect) -> Bool {
  return lhs.x == rhs.x && lhs.y == rhs.y && lhs.width == rhs.width && lhs.height == rhs.height
}

public struct Rect : Equatable {
  public var x = CGFloat(0)
  public var y = CGFloat(0)
	public var width = CGFloat(0)
  public var height = CGFloat(0)

  public var midX: CGFloat {
    return x + width/2
  }
  
  public var midY: CGFloat {
    return y + height/2
	}
  
  public var endX: CGFloat {
    return x + width
  }
  
  public var endY: CGFloat {
    return y + height
  }

  public var maxDim: CGFloat {
    return max(width,height)
	}

  public var minDim: CGFloat {
    return min(width,height)
	}

  init(_ x:CGFloat, _ y:CGFloat, _ width:CGFloat, _ height:CGFloat) {
    self.x = x
    self.y = y
    self.width = width
    self.height = height
	}

  public mutating func setTo(x:CGFloat, _ y:CGFloat, _ width:CGFloat, _ height:CGFloat) {
    self.x = x
    self.y = y
    self.width = width
    self.height = height
  }
  
  public mutating func setTo(source : Rect) {
		setTo(source.x,source.y,source.width,source.height)
	}

  public var description : String {
    return "\(dump(x)) \(dump(y)) \(dump(width)) \(dump(height)) "
	}

  init(_ pt1:Point, _ pt2:Point) {
    self.x = min(pt1.x,pt2.x)
    self.y = min(pt1.y,pt2.y)
    self.width = max(pt1.x,pt2.x) - self.x
    self.height = max(pt1.y,pt2.y) - self.y
  }

  public mutating func inset(dx:CGFloat,dy:CGFloat) {
    x += dx
    y += dy
    width -= 2*dx
    height -= 2*dy
	}


/*

public boolean contains(Rect r) {
		return x <= r.x && y <= r.y && endX() >= r.endX() && endY() >= r.endY();
}

public void include(Rect r) {
		include(r.topLeft());
		include(r.bottomRight());
}

public void include(Point pt) {
		float ex = endX(), ey = endY();
		x = Math.min(x, pt.x);
		y = Math.min(y, pt.y);
		ex = Math.max(ex, pt.x);
		ey = Math.max(ey, pt.y);
		width = ex - x;
		height = ey - y;
}

public float distanceFrom(Point pt) {
		return MyMath.distanceBetween(pt, nearestPointTo(pt));
}

/**
* Find the nearest point within the rectangle to a query point
*
* @param queryPoint
*/
public Point nearestPointTo(Point queryPoint) {
		return new Point(MyMath.clamp(queryPoint.x, x, endX()), MyMath.clamp(
  queryPoint.y, y, endY()));
}

public void translate(float dx, float dy) {
		x += dx;
		y += dy;
}

public Point midPoint() {
		return new Point(midX(), midY());
}

public boolean contains(Point pt) {
		return x <= pt.x && y <= pt.y && endX() >= pt.x && endY() >= pt.y;
}

public void translate(Point tr) {
		translate(tr.x, tr.y);
}

/**
* Scale x,y,width,height by factor
*
* @param f
*/
public void scale(float f) {
		x *= f;
		y *= f;
		width *= f;
		height *= f;
}

public void snapToGrid(float gridSize) {
		float x2 = endX();
		float y2 = endY();
		x = MyMath.snapToGrid(x, gridSize);
		y = MyMath.snapToGrid(y, gridSize);
		width = MyMath.snapToGrid(x2, gridSize) - x;
		height = MyMath.snapToGrid(y2, gridSize) - y;
}

/**
* Get point for corner of rectangle
*
* @param i
*            corner number (0..3), bottomleft ccw to topleft
* @return corner
*/
public Point corner(int i) {
		Point ret = null;
  
		switch (i) {
    default:
      throw new IllegalArgumentException();
    case 0:
      ret = bottomLeft();
      break;
    case 1:
      ret = bottomRight();
      break;
    case 2:
      ret = topRight();
      break;
    case 3:
      ret = topLeft();
      break;
		}
  
		return ret;
}

public static Rect rectContainingPoints(List<Point> a) {
		if (a.isEmpty())
  throw new IllegalArgumentException();
		Rect r = null;
		for (Point pt : a) {
      if (r == null)
      r = new Rect(pt, pt);
      else
      r.include(pt);
		}
		return r;
}

public static Rect rectContainingPoints(Point s1, Point s2) {
		Point m1 = new Point(Math.min(s1.x, s2.x), Math.min(s1.y, s2.y));
		Point m2 = new Point(Math.max(s1.x, s2.x), Math.max(s1.y, s2.y));
		return new Rect(m1.x, m1.y, m2.x - m1.x, m2.y - m1.y);
}

public boolean intersects(Rect t) {
		return (x < t.endX() && endX() > t.x && y < t.endY() && endY() > t.y);
}

public Point size() {
		return new Point(width, height);
}

public float x, y, width, height;


*/

}