
public class IconPanel : View {
  
  public var textureProvider : TextureProvider!
  public var rowHeight : CGFloat = 0
  public var rowPlotHandler : PlotHandler!
  
  private var rows = Array<IconRow> ()
  
  public var rowCount : Int {
    get {
      return rows.count
    }
  }
  
  public func getRow(index : Int) -> IconRow {
    return rows[index]
  }
  
  public func addRow() -> IconRow {
    ASSERT(rowHeight > 0,"must define rowheight")
    
    var iconRow = IconRow(CGPoint(self.bounds.width,rowHeight))
    iconRow.position = CGPoint(0, CGFloat(rowCount) * rowHeight)
    if (rowPlotHandler != nil) {
      iconRow.plotHandler = rowPlotHandler
    }
    iconRow.textureProvider = textureProvider
    rows.append(iconRow)
    add(iconRow)
    return iconRow
  }
  
  // Layout each row 
  //
  public func layoutRows() {
    for row in rows {
      row.layout()
    }
  }

}

