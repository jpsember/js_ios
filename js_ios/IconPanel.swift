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

  // Find which icon, if any, is at a touch location;
  // if found, returns (rowIndex, elementIndex, offset, iconFlag); else (-1,-1,false,nil)
  // If elementIndex == row.count, iconFlag is false and offset is nil; else
  //  offset = element position - touch location
  //
  public func findTouchedIcon(event:TouchEvent, omitPadding:Bool) -> (Int, Int, Bool, CGPoint!) {
    let (rowIndex,position) = rowContainingPoint(event.locationRelativeToView(self))
    var elementIndex = -1
    var iconFlag = false
    var offset : CGPoint? = nil
    if (rowIndex >= 0) {
      let row = rows[rowIndex]
      elementIndex = row.elementAt(position,omitPadding:omitPadding)
      if elementIndex >= 0 {
        iconFlag = elementIndex < row.count
        if iconFlag {
          let element = row.getElement(elementIndex)
          offset = CGPoint.difference(position,element.position)
        }
      }
    }
    return (rowIndex,elementIndex,iconFlag,offset)
  }
  
	// Private properties and methods
  
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
  
  // Operation for moving an icon
  //
  public class MoveIconOperation : TouchOperation {
    
    // Public overrides of TouchOperation methods
    
    public override func start(event : TouchEvent) {
      let (rowIndex,elementIndex,iconFlag,touchOffset) = iconPanel.findTouchedIcon(event,omitPadding:true)
      if (!iconFlag) {
        warning("unexpected")
        cancel()
        return
      }
      originalRowIndex = rowIndex
      originalElementIndex = elementIndex
      activeRowIndex = rowIndex
      activeElementIndex = elementIndex
     	self.touchOffset = touchOffset
      
      let row = iconPanel.row(rowIndex)
      dragElement = row.removeElement(elementIndex)
      let newElement = IconElement("",CGPoint(dragElement.size.x,20))
      insertElement(activeRowIndex,activeElementIndex,newElement)
      
      super.start(event)
    }
    
    public override func cancel() {
      if (!running) {
        return
      }
      removeElement(activeRowIndex,activeElementIndex)
      updateDragElementPositionForRow(originalRowIndex)
      insertElement(originalRowIndex,originalElementIndex,dragElement)
    }
    
    public override func complete() {
      unimp("simulate cancel for test purposes")
      removeElement(activeRowIndex,activeElementIndex)
      // TODO: it may end up being clipped to the row bounds; maybe disable clipping for IconRows
      updateDragElementPositionForRow(activeRowIndex)
      insertElement(activeRowIndex,activeElementIndex,dragElement)
      super.complete()
    }
    
    public override func processEvent(event: TouchEvent) {
      if (event.type == .Up) {
        complete()
        return
      }
      
      dragEvent = event
      
      let (newRowIndex,newElementIndex,iconFlag,_) = iconPanel.findTouchedIcon(event,omitPadding:false)
      if (newRowIndex != activeRowIndex) {
        // Remove gap, if one exists
        removeElement(activeRowIndex,activeElementIndex)
        activeElementIndex = -1
        activeRowIndex = newRowIndex
      }
      
      if (activeRowIndex >= 0 && newElementIndex != activeElementIndex) {
        // Don't allow user to attempt to move last element in a row to its right
        if activeElementIndex == iconPanel.row(activeRowIndex).count - 1 && newElementIndex > activeElementIndex {
          return
        }
        removeElement(activeRowIndex,activeElementIndex)
        activeElementIndex = -1
        
        if newElementIndex >= 0 {
          let newElement = IconElement("",CGPoint(dragElement.size.x,20))
          insertElement(activeRowIndex,newElementIndex,newElement)
        }
        activeElementIndex = newElementIndex
      }
    }
    
    public override func updateCursor(location: CGPoint) {
      let sprite = dragElement.sprite
      let loc = CGPoint.difference(dragEvent.absoluteLocation,touchOffset)
      dragCursorPosition = loc
      sprite.render(loc)
    }
    
    public override var description : String {
      return "MoveIConOperation(activeRow/Element \(activeRowIndex)/\(activeElementIndex) original \(originalRowIndex)/\(originalElementIndex))"
    }
    
    
    // Construct an operation, if possible, for a DOWN event in an IconPanel
    // Returns operation, or nil
    //
    private class func constructForTouchEvent(event:TouchEvent, _ iconPanel:IconPanel) -> MoveIconOperation! {
      var ret : MoveIconOperation! = nil
      let (_,_,iconFlag,_) = iconPanel.findTouchedIcon(event,omitPadding:true)
      if iconFlag {
        ret = MoveIconOperation(iconPanel)
      }
      return ret
    }
    
    private init(_ iconPanel:IconPanel) {
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
    private var activeElementIndex : Int = -1
    private var activeRowIndex : Int = -1
    private var touchOffset = CGPoint.zero
    private var dragCursorPosition : CGPoint!
    private var dragEvent : TouchEvent!
    private var dragElement : IconElement!
    private var originalRowIndex : Int = -1
    private var originalElementIndex : Int = -1
  }
  
}
