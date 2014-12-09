public class IconPanel : View {
  
  // Public properties
  
  public var textureProvider : TextureProvider!
  public var rowHeight : CGFloat = 0
  public var rowPlotHandler : PlotHandler!
  
  // Public methods
  
  public override init() {
    super.init()
    self.touchHandler = ourTouchHandler
    unimp("how to automatically register panel for updating with each tick, but without causing memory leak")
  }
  
  public func addRow() -> IconRow {
    ASSERT(rowHeight > 0,"must define rowheight")
    
    var iconRow = IconRow(self)
    iconRow.size = CGPoint(self.bounds.width,rowHeight)
    iconRow.position = CGPoint(0,CGFloat(rowCount) * rowHeight)
    if (rowPlotHandler != nil) {
      iconRow.plotHandler = rowPlotHandler
    }
    rows.append(iconRow)
    add(iconRow)
    return iconRow
  }

  // Update the IconPanel model; move icons along their paths, request redraw if necessary
  //
  public func updateLogic() {
    for row in rows {
      row.updateElements()
    }
  }

  // Private properties and methods
  
  // Find which icon, if any, is at a touch location; returns nil if none
  //
  private func findTouchedIcon(event:TouchEvent) -> Touch! {
    let (rowIndex,position) = rowContainingPoint(event.locationRelativeToView(self))
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
  
  // Find which icon, if any, is at a touch location; if none, touch row and element indexes are both -1
  //
  private func findTouchedCell(event:TouchEvent) -> Touch {
    let (rowIndex,position) = rowContainingPoint(event.locationRelativeToView(self))
    var elementIndex = -1
    if (rowIndex >= 0) {
      let row = rows[rowIndex]
      elementIndex = row.elementAt(position,omitPadding:false)
    }
    return Touch(rowIndex:rowIndex, elementIndex:elementIndex)
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
  
  private func rowContainingPoint(point:CGPoint) -> (Int,CGPoint!) {
    for (index,row) in enumerate(rows) {
      if (row.bounds.contains(point)) {
      	return (index,CGPoint.difference(point,row.bounds.origin))
      }
    }
    return (-1,nil)
  }
  
  // Encompasses information about which icon is under touch location
  //
  internal struct Touch {
    var rowIndex : Int
    var elementIndex : Int
    var touchOffset : CGPoint
    
    init(rowIndex:Int, elementIndex:Int, touchOffset:CGPoint = CGPoint.zero) {
      self.rowIndex = rowIndex
      self.elementIndex = elementIndex
      self.touchOffset = touchOffset
    }
  }

  // Operation for moving an icon
  //
  internal class MoveIconOperation : TouchOperation {
    
    // Public overrides of TouchOperation methods
    
    override func start(event : TouchEvent) {
      // Ignore the event passed in, since we've already constructed initialTouch from it
      
      activeRowIndex = initialTouch.rowIndex
      activeElementIndex = initialTouch.elementIndex
      
      let row = iconPanel.row(activeRowIndex)
      dragElement = row.removeElement(activeElementIndex)
      let newElement = IconElement("",CGPoint(dragElement.size.x,20))
      insertElement(activeRowIndex,activeElementIndex,newElement)
      
      super.start(event)
    }
    
    override func cancel() {
      if (!running) {
        return
      }
      removeElement(activeRowIndex,activeElementIndex)
      updateDragElementPositionForRow(initialTouch.rowIndex)
      insertElement(initialTouch.rowIndex,initialTouch.elementIndex,dragElement)
    }
    
    override func complete() {
      unimp("simulate cancel for test purposes")
      removeElement(activeRowIndex,activeElementIndex)
      // TODO: it may end up being clipped to the row bounds; maybe disable clipping for IconRows
      updateDragElementPositionForRow(activeRowIndex)
      insertElement(activeRowIndex,activeElementIndex,dragElement)
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
      
      if (touchedCell.rowIndex != activeRowIndex) {
        // Remove gap, if one exists
        removeElement(activeRowIndex,activeElementIndex)
        activeElementIndex = -1
        activeRowIndex = touchedCell.rowIndex
      }
      
      if (activeRowIndex >= 0 && touchedCell.elementIndex != activeElementIndex) {
        // Don't allow user to attempt to move last element in a row to its right
        if activeElementIndex == iconPanel.row(activeRowIndex).count - 1 && touchedCell.elementIndex > activeElementIndex {
          return
        }
        removeElement(activeRowIndex,activeElementIndex)
        activeElementIndex = -1
        
        activeElementIndex = touchedCell.elementIndex
        if activeElementIndex >= 0 {
          let newElement = IconElement("",CGPoint(dragElement.size.x,20))
          insertElement(activeRowIndex,activeElementIndex,newElement)
        }
      }
    }
    
    override func updateCursor(location: CGPoint) {
      let sprite = dragElement.sprite
      let loc = CGPoint.difference(dragEvent.absoluteLocation,initialTouch.touchOffset)
      dragCursorPosition = loc
      sprite.render(loc)
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
    
    private func removeElement(rowIndex:Int, _ elementIndex:Int) {
      if (rowIndex < 0) {
        return
      }
      let row = iconPanel.row(rowIndex)
      if (elementIndex < 0) {
        return
      }
      if (elementIndex < row.count) {
        row.removeElement(elementIndex)
      }
    }
    
    private func insertElement(rowIndex:Int, _ elementIndex:Int, _ newElement:IconElement) {
      if (rowIndex < 0) {
        return
      }
      let row = iconPanel.row(rowIndex)
      ASSERT(elementIndex >= 0)
      row.insert(newElement, atIndex: elementIndex)
    }
    
    private func updateDragElementPositionForRow(rowIndex:Int) {
      if rowIndex < 0 || dragCursorPosition == nil {
        return
      }
      let row = iconPanel.row(rowIndex)
      let pos = CGPoint.difference(dragCursorPosition,row.absolutePosition)
      dragElement.setActualPosition(pos)
    }
    
    private var iconPanel : IconPanel
    // Touch associated with initial Down event
    private var initialTouch : Touch
    private var dragElement : IconElement!
    private var activeElementIndex : Int = -1
    private var activeRowIndex : Int = -1
    private var dragCursorPosition : CGPoint!
    private var dragEvent : TouchEvent!
  }
  
}
