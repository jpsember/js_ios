import Foundation

// TODO: Figure out how to have class-level constants
let PADDING = CGFloat(5)

public typealias TextureProvider = (String, CGPoint) -> Texture

public class IconRow : NSObject {

  private var elements = Array<IconElement> ()
  
  private(set) var panel : IconPanel
  
  // Bounds relative to IconPanel origin
  private(set) var bounds : CGRect
  
  // locations of vertical boundaries between icons, forming a partition of the row's bounding rectangle.
  // There are n+1 partitions for n icons; the last partition is always the width of the row
  
  private var rowPartition = Array<CGFloat> ()

  private var modified  = false
  
  public init(_ panel:IconPanel, bounds:CGRect) {
    self.panel = panel
  	self.bounds = bounds
    super.init()
  }
  
  public func addElement(element: IconElement) {
  	elements.append(element)
    modified = true
  }
  
  public var count : Int {
    get {
      return elements.count
    }
  }
  
  public func insert(element: IconElement, atIndex: Int) {
    elements.insert(element, atIndex: atIndex)
    modified = true
  }
  
  public func removeElement(index:Int) -> IconElement {
    modified = true
    return elements.removeAtIndex(index)
  }

  // Update the elements' positions; return true if any of them have moved
  //  
  public func updateElements() -> Bool {
    layout()
    var changes = false
    for e in elements {
      if e.update() {
        changes = true
      }
    }
    return changes
  }
  
  // Determine which element, if any, is at a location;
  // returns index of element, or -1; may return n, where n is the number of elements
  //
  // If omitPadding is true, restricts target region to be sprite's bounding rectangle,
  // which varies by sprite heights and omits the padding between adjacent sprites.
  // Otherwise, expands each region to be the height of the IconRow, and to be flush with the
  // regions to each side
  //
  public func elementAt(location:CGPoint,omitPadding:Bool) -> Int {
    if (!omitPadding) {
      if (!bounds.contains(location)) {
        return -1
      }
      let xRel = location.x - bounds.x
      var slot = -1
      for (i,x) in enumerate(rowPartition) {
        if (xRel < x) {
          slot = i
          break
        }
      }
      return slot
    }
    
    for (i,e) in enumerate(elements) {
      let r = CGRect(origin:e.position,size:e.size)
      if r.contains(location) {
        return i
      }
    }
    return -1
  }
  
  public func getElement(index : Int) -> IconElement {
    return elements[index]
  }
  
  // Layout elements according to their target positions
  //
  private func layout() {
    if !modified {
      return
    }
  	let targetPos = calcTargetElementPositions()
    for (i,e) in enumerate(elements) {
      let pos = targetPos[i]
      e.targetPosition = pos
    }
    modified = false
  }
  
  // Determine element positions given current elements
  //
  private func calcTargetElementPositions() -> Array<CGPoint> {
    
    rowPartition.removeAll()
    
    var elemPos = Array<CGPoint>()
    
    if elements.count > 0 {
	    var totalWidth = totalElementWidth()
      totalWidth += PADDING * CGFloat(elements.count)
    
      var x = (bounds.width - totalWidth) / 2
      for var i = 0; i < elements.count; i++ {
				let e = elements[i]
        let pos = CGPoint(x + PADDING/2, bounds.yMid - e.size.y/2)
        elemPos.append(pos)
        x += PADDING + e.size.x
        rowPartition.append(x)
      }
    }
		rowPartition.append(bounds.width)
    return elemPos
  }
  
  private func totalElementWidth() -> CGFloat {
  	var w = CGFloat(0)
    for e in elements {
    	w += e.size.x
    }
    return w
  }
  
  // Plot elements in their current positions
  //
  public func plotElements() {
    for e in elements {
      e.render(panel.textureProvider)
    }
  }

}

