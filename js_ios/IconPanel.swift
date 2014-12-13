public class IconPanel : View, LogicProtocol {
  
  // Public properties
  
  public var textureProvider : TextureProvider!
  public var rowHeight : CGFloat = 0
  
  // Public methods
  
  public override init() {
    super.init()
    self.touchHandler = ourTouchHandler
    originalPlotHandler = replacePlotHandlerWith(ourPlotHandler)
  }
  
  public func addRow() -> IconRow {
    ASSERT(rowHeight > 0,"must define rowheight")
    
    let rowBounds = CGRect(0,CGFloat(rowCount)*rowHeight,self.bounds.width,rowHeight)
    
    var iconRow = IconRow(self,bounds:rowBounds)
    rows.append(iconRow)
    return iconRow
  }

  // Update the IconPanel model; move icons along their paths, request redraw if necessary
  //
  public func updateLogic() {
    var refreshView = false
    for row in rows {
      if row.updateElements() {
      	refreshView = true
      }
    }
    if refreshView {
      invalidate()
    }
  }

  private func ourPlotHandler(view : View) {
    originalPlotHandler(view)
    for row in rows {
      row.plotElements()
    }
  }
  
  // Private properties and methods
  
  private var originalPlotHandler : PlotHandler!
  
  // Find which icon, if any, is at a touch location; returns nil if none
  //
  private func findTouchedIcon(event:TouchEvent) -> Touch! {
		let position = event.locationRelativeToView(self)
    let rowIndex = rowContainingPoint(position)
    var elementIndex = -1
    var iconFlag = false
    if (rowIndex >= 0) {
      let row = rows[rowIndex]
      elementIndex = row.elementAt(position,omitPadding:true)
      if elementIndex >= 0 {
        let element = row.getElement(elementIndex)
        return Touch(rowIndex: rowIndex, elementIndex: elementIndex, touchOffset: CGPoint.difference(position,element.position))
      }
    }
    return nil
  }
  
  // Find which icon, if any, is at a touch location; if none, returns nil
  //
  private func findTouchedCell(event:TouchEvent) -> Touch! {
		let position = event.locationRelativeToView(self)
    let rowIndex = rowContainingPoint(position)
    if (rowIndex >= 0) {
      let row = rows[rowIndex]
      let elementIndex = row.elementAt(position,omitPadding:false)
      if (elementIndex >= 0) {
      	return Touch(rowIndex:rowIndex, elementIndex:elementIndex)
      }
    }
    return nil
  }
  
  private var rows = Array<IconRow> ()
  
  private var rowCount : Int {
    get {
      return rows.count
    }
  }
  
  private func row(index : Int) -> IconRow {
    return rows[index]
  }
  
  private func ourTouchHandler(event:TouchEvent, view:View) -> Bool {
    if (event.type == .Down) {
      let oper = MoveIconOperation.constructForTouchEvent(event,self)
      if (oper == nil)  {
        return false
      }
      oper.start(event)
      return true
    }
    return false
  }
  
  private func rowContainingPoint(point:CGPoint) -> Int {
    for (index,row) in enumerate(rows) {
      if (row.bounds.contains(point)) {
      	return index
      }
    }
    return -1
  }
  
  // Encompasses information about which icon is under touch location
  //
  internal struct Touch : Printable {
    var rowIndex : Int
    var elementIndex : Int
    var touchOffset : CGPoint
    
    var description : String {
      return "Touch\(rowIndex)/\(elementIndex)"
    }
    
    init(rowIndex:Int, elementIndex:Int, touchOffset:CGPoint = CGPoint.zero) {
      ASSERT(elementIndex >= 0 && rowIndex >= 0)
      
      self.rowIndex = rowIndex
      self.elementIndex = elementIndex
      self.touchOffset = touchOffset
    }
  }

  // Operation for moving an icon
  //
  internal class MoveIconOperation : TouchOperation {
    
    private let hoverBumpPathDuration = CGFloat(0.2)

    override func updateLogic() {
      if (hoverPath != nil) {
        if hoverPath.update(hoverBumpPathDuration) {
          ViewManager.sharedInstance().setNeedsDisplay()
          dragElement.currentScale = scaleStart + (scaleEnd - scaleStart) * hoverPath.parameter
        } else {
          hoverPath = nil
        }
      }
    }

    // Public overrides of TouchOperation methods
    
    override func start(event : TouchEvent) {
      // Ignore the event passed in, since we've already constructed initialTouch from it
      
      activeTouch = initialTouch
      
      let row = iconPanel.row(activeTouch.rowIndex)
      dragElement = row.removeElement(activeTouch.elementIndex)
      let newElement = IconElement("",CGPoint(dragElement.size.x,20))
      insertElement(activeTouch,newElement)
      scaleStart = dragElement.currentScale
      scaleEnd = 1.5
      
      hoverPath = HermitePath(p1:CGPoint.zero, p2:CGPoint(0,18))
      
      super.start(event)
    }
    
    override func cancel() {
      if (!running) {
        return
      }
      dragElement.targetScale = 1.0
      removeElement(activeTouch)
      updateDragElementPositionForRow(initialTouch)
      insertElement(initialTouch,dragElement)
    }
    
    override func complete() {
      unimp("simulate cancel for test purposes")
      removeElement(activeTouch)
      dragElement.targetScale = 1.0
      updateDragElementPositionForRow(activeTouch)
      insertElement(activeTouch,dragElement)
      super.complete()
    }
    
    override func processEvent(event: TouchEvent) {
      if (event.type == .Up) {
        complete()
        return
      }
      
      // Store the event in case we later plot a cursor icon
      dragEvent = event
      
      let touchedCell = iconPanel.findTouchedCell(event)
      
      if (touchedCell == nil || (activeTouch != nil && touchedCell.rowIndex != activeTouch.rowIndex)) {
        // Remove gap, if one exists
        removeElement(activeTouch)
        activeTouch = nil
      }
      
      if (touchedCell == nil) {
        return
      }
      
      if (activeTouch == nil || touchedCell.elementIndex != activeTouch.elementIndex) {
        // Don't allow user to attempt to move last element in a row to its right
        if activeTouch != nil {
          if (activeTouch.elementIndex == iconPanel.row(touchedCell.rowIndex).count - 1
            && touchedCell.elementIndex > activeTouch.elementIndex) {
          	return
        	}
        }
        
        removeElement(activeTouch)
        
        activeTouch = touchedCell
        let newElement = IconElement("",CGPoint(dragElement.size.x,20))
        insertElement(activeTouch,newElement)
      }
    }
    
    override func updateCursor(location: CGPoint) {
      let sprite = dragElement.sprite
      var loc = CGPoint.difference(dragEvent.absoluteLocation,initialTouch.touchOffset)
      loc.add(hoverPath.position)
      dragCursorPosition = loc
      dragElement.renderSpriteAt(loc)
    }
    
    // Construct an operation, if possible, for a DOWN event in an IconPanel
    // Returns operation, or nil
    //
    private class func constructForTouchEvent(event:TouchEvent, _ iconPanel:IconPanel) -> MoveIconOperation! {
      var ret : MoveIconOperation! = nil
      let touchedIcon = iconPanel.findTouchedIcon(event)
      if touchedIcon != nil {
        ret = MoveIconOperation(iconPanel,touchedIcon)
      }
      return ret
    }
    
    private init(_ iconPanel:IconPanel, _ initialTouch:Touch) {
      self.initialTouch = initialTouch
      self.iconPanel = iconPanel
      super.init()
    }
    
    private func removeElement(touch:Touch!) {
      if (touch == nil) {
        return
      }
      let row = iconPanel.row(touch.rowIndex)
      if (touch.elementIndex < row.count) {
        row.removeElement(touch.elementIndex)
      }
    }
    
    private func insertElement(touch:Touch!, _ newElement:IconElement) {
      if (touch == nil) {
        return
      }
      let row = iconPanel.row(touch.rowIndex)
      row.insert(newElement, atIndex: touch.elementIndex)
    }
    
    private func updateDragElementPositionForRow(touch:Touch!) {
      if touch == nil || dragCursorPosition == nil {
        return
      }
      let pos = CGPoint.difference(dragCursorPosition,iconPanel.absolutePosition)
      dragElement.setActualPosition(pos)
    }
    
    private var iconPanel : IconPanel
    // Touch associated with initial Down event
    private var initialTouch : Touch
    private var dragElement : IconElement!
    private var activeTouch : Touch!
    private var dragCursorPosition : CGPoint!
    private var dragEvent : TouchEvent!
    private var hoverPath : HermitePath!
    private var scaleStart : CGFloat = 0
    private var scaleEnd : CGFloat = 0
    
  }
  
}
