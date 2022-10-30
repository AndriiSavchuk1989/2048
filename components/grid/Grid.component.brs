sub init()
  m.cellsCoords = invalid


  m.background = m.top.findNode("background")
  m.gridWrapper = m.top.findNode("gridWrapper")
  m.top.observeFieldScoped("focusedChild", "onFocusChange")
  m.top.setFocus(true)

  m.background.width = 720
  m.background.height = 720
  m.background.color = "#80877B"
  m.background.translation = [(1920 - 720) / 2, (1080 - 720) / 2]
  m.gridWrapper.width = 720
  m.gridWrapper.height = 720
  m.gridWrapper.translation = [(1920 - 720) / 2, (1080 - 720) / 2]
  m.gridWrapper.color = "#CBDCCB"

  m.DEFAULT_COLUMNS = 4
  m.DEFAULT_ROWS = 4
  m.DEFAULT_CELL_WIDTH = 160
  m.DEFAULT_CELL_HEIGHT = 160
  m.DEFAULT_CELL_PADDING = 16

  fillGrid()
  m.listeners = []
end sub

sub onFocusChange(event)
  if m.top.hasFocus() then
    m.gridWrapper.setFocus(true)
  end if
end sub


sub setupGrid(gridSettings as dynamic)
  if isNotEmptyObject(gridSettings) then
    prepareSpecificGrid(gridSettings)
  else
    ? "4x4 grid";
    fillGrid()
  end if
end sub

sub prepareSpecificGrid(settings as object)
  ? "specificGrid"; settings
end sub

function getRandomCell() as integer
  return Rnd(3)
end function

function getRandomRow() as integer
  return Rnd(3)
end function

function createRandomCoords()
  rnd1 = getRandomRow()
  rnd2 = getRandomCell()

  rnd3 = getRandomRow()
  rnd4 = getRandomCell()

  while rnd1 = rnd3
    rnd3 = getRandomRow()
  end while

  'return [{ row: rnd1, cell: rnd2 }, { row: rnd3, cell: rnd4 }]
  return [{ row: 0, cell: 0 }, { row: 1, cell: 0 }]
end function

sub fillGrid(width = m.DEFAULT_CELL_WIDTH as integer, height = m.DEFAULT_CELL_HEIGHT as integer, rows = m.DEFAULT_COLUMNS as integer, columns = m.DEFAULT_ROWS as integer)
  m.cellsCoords = []

  for i = 0 to rows - 1
    m.cellsCoords.push([])

    for j = 0 to columns - 1
      paddingY = 16
      paddingX = 16
      translationX = paddingX + paddingX * j + width * j
      translationY = paddingY + paddingY * i + height * i
      coords = i.toStr() + j.toStr()
      createBackgroundCell({
        coords: coords,
        height: height,
        width: width,
        translation: [translationX, translationY],
        indexes: { row: i, cell: j }
      })
      m.cellsCoords[i].push({ id: Substitute("gameCell_{0}", coords), x: translationX, y: translationY, isEmpty: true, row: i, cell: j })
      createAnimation(coords, m.cellsCoords[i][j].id)
    end for
  end for


  createRandomCells(createRandomCoords(), {
    width: width
    height: height
    color: "#C70000"
  })
  updateEmptyStatus()
end sub

sub updateCellsEmptyStatus(cellId as string)
  for each row in m.cellsCoords
    for each cell in row
      if cell.id = cellId then
        cell.isEmpty = not cell.isEmpty
      end if
    end for
  end for
end sub

sub createBackgroundCell(settings as dynamic)
  if isNotEmptyObject(settings) then
    backgroundCell = m.gridWrapper.createChild("GridItemComponent")
    translation = settings.translation
    backgroundCell.callFunc("draw", {
      id: "backgroundCell_" + settings.coords
      width: settings.width,
      height: settings.height,
      color: "#00FFEC",
      coords: translation,
      indexes: settings.indexes,
      isEmpty: true
    })
    backgroundCell.update({
      translation: translation
    })
  end if
end sub

sub createGameCell(settings as dynamic, value = 2 as integer)
  gameCell = m.gridWrapper.createChild("GridItemComponent")
  gameCellId = "gameCell_" + settings.coords
  translation = settings.translation
  gameCell.callFunc("draw", {
    id: gameCellId,
    width: settings.width,
    height: settings.height,
    color: "#C70000",
    value: value,
    coords: settings.translation,
    indexes: settings.indexes
  })
  gameCell.update({
    translation: translation
  })
end sub

function getEmptyCells(randomCells as dynamic)
  emptyCells = []

  for each cell in randomCells
    specificId = cell.cell.toStr() + cell.row.toStr()
    for i = 0 to m.gridWrapper.getChildCount() - 1
      child = m.gridWrapper.getChild(i)
      id = Substitute("backgroundCell_{0}", specificId)
      if isValid(child) and isNotEmptyString(child.id) and child.id.instr(id) <> -1 then emptyCells.push(child)
    end for
  end for

  return emptyCells
end function

sub createRandomCells(randomCells as dynamic, basicSettings as dynamic)
  if isNotEmptyArray(randomCells) and isNotEmptyObject(basicSettings) then
    emptyCells = getEmptyCells(randomCells)

    for i = 0 to randomCells.Count() - 1
      emptyCell = emptyCells[i]
      basicSettings.translation = emptyCell.translation
      basicSettings.coords = Right(emptyCell.id, 2)
      cellIndexes = Right(emptyCell.id, 2)
      basicSettings.indexes = { row: Left(cellIndexes, 1).toInt(), cell: Right(cellIndexes, 1).toInt() }
      createGameCell(basicSettings)
    end for
  end if
end sub

sub createAnimation(coords, cellId)
  animation = m.gridWrapper.createChild("Animation")
  animation.id = "moveAnimation_" + coords
  animation.duration = 1
  animation.repeat = false
  animation.easeFunction = "linear"
  interpolator = animation.createChild("Vector2DFieldInterpolator")
  interpolator.fieldToInterp = Substitute("{0}{1}", cellId, ".translation")
end sub

sub showCellCoords(coords)
  for i = 0 to coords.Count() - 1
    for j = 0 to coords[i].Count() - 1
    end for
  end for
end sub

sub updateEmptyStatus()
  gameCells = []

  for i = 0 to m.gridWrapper.getChildCount() - 1
    child = m.gridWrapper.getChild(i)
    if isValid(child) then
      indexes = child.callFunc("getIndexes")
      cellId = child.id
      if cellId.instr("gameCell_") <> -1 then
        gameCells.push(child.callFunc("getIndexes"))
      end if
    end if
  end for

  for j = 0 to gameCells.Count() - 1
    strValue = gameCells[j].stringValue

    for k = 0 to m.gridWrapper.getChildCount() - 1
      child = m.gridWrapper.getChild(k)
      if child.id.instr(Substitute("backgroundCell_{0}", strValue)) <> -1 then
        updateCellsEmptyStatus(child.id)
        child.callFunc("setEmptyStatus", not child.callFunc("getEmptyStatus"))
      end if
    end for
  end for
end sub

sub move(direction as string)
end sub

'move functions
function getNewCellUp(rowIndex as integer, cellIndex as integer) as dynamic
  for i = 0 to m.cellsCoords.Count() - 1
    if i < rowIndex and m.cellsCoords[i][cellIndex].isEmpty then
      return m.cellsCoords[i][cellIndex]
    end if
  end for

  return invalid
end function

function getNewCellDown(rowIndex as integer, cellIndex as integer)
  for i = m.cellsCoords.Count() - 1 to 0 step -1
    if i > rowIndex and m.cellsCoords[i][cellIndex].isEmpty then
      return m.cellsCoords[i][cellIndex]
    end if
  end for

  return invalid
end function

function getNewCellRight(rowIndex as integer, cellIndex as integer) as dynamic
  for i = m.cellsCoords[rowIndex].Count() - 1 to cellIndex step -1
    if i > cellIndex and m.cellsCoords[rowIndex][i].isEmpty then return m.cellsCoords[rowIndex][i]
  end for

  return invalid
end function

function getNewCellLeft(rowIndex as integer, cellIndex as integer) as dynamic
  for i = 0 to m.cellsCoords[rowIndex].Count() - 1
    if i < cellIndex and m.cellsCoords[rowIndex][i].isEmpty then return m.cellsCoords[rowIndex][i]
  end for

  return invalid
end function

sub moveUp(gameCells as dynamic)
  for i = 0 to gameCells.Count() - 1
    gameCell = gameCells[i]
    gameCell.isEmpty = true
    rowIdx = gameCell.row
    cellIdx = gameCell.cell
    newCell = getNewCellUp(rowIdx, cellIdx)

    if isValid(newCell) then
      newCell.isEmpty = false
      for j = 0 to m.gridWrapper.getChildCount() - 1
        animation = m.gridWrapper.getChild(j)

        if animation.id.instr(Substitute("moveAnimation_{0}{1}", rowIdx.toStr(), cellIdx.toStr())) <> -1 then
          cellFrom = getCellCoordsById(Substitute("{0}{1}", rowIdx.toStr(), cellIdx.toStr()))
          interpolator = animation.getChild(0)
          interpolator.key = [0.0, 1.0]
          interpolator.keyValue = [[cellFrom.x, cellFrom.y], [newCell.x, newCell.y]]
          animation.control = "start"

          gameCell = _getCellById(Substitute("gameCell_{0}{1}", rowIdx.toStr(), cellIdx.toStr()))
          if isValid(gameCell) then
            gameCell.observeFieldScoped("translation", "_onGameCellTranslationChanged")
          end if
        end if
      end for
    end if
  end for
end sub

sub moveDown(gameCells as dynamic)
  for i = 0 to gameCells.Count() - 1
    gameCell = gameCells[i]
    gameCell.isEmpty = true
    rowIdx = gameCell.row
    cellIdx = gameCell.cell
    newCell = getNewCellDown(rowIdx, cellIdx)

    if isValid(newCell) then
      newCell.isEmpty = false

      for j = 0 to m.gridWrapper.getChildCount() - 1
        animation = m.gridWrapper.getChild(j)

        if animation.id.instr(Substitute("moveAnimation_{0}{1}", rowIdx.toStr(), cellIdx.toStr())) <> -1 then
          cellFrom = getCellCoordsById(Substitute("{0}{1}", rowIdx.toStr(), cellIdx.toStr()))
          interpolator = animation.getChild(0)
          interpolator.key = [0.0, 1.0]
          interpolator.keyValue = [[cellFrom.x, cellFrom.y], [newCell.x, newCell.y]]
          animation.control = "start"

          gameCell = _getCellById(Substitute("gameCell_{0}{1}", rowIdx.toStr(), cellIdx.toStr()))
          if isValid(gameCell) then
            gameCell.observeFieldScoped("translation", "_onGameCellTranslationChanged")
          end if
        end if
      end for
    end if
  end for
end sub

sub moveRight(gameCells as dynamic)
  for i = 0 to gameCells.Count() - 1
    gameCell = gameCells[i]
    gameCell.isEmpty = true
    rowIdx = gameCell.row
    cellIdx = gameCell.cell
    newCell = getNewCellRight(rowIdx, cellIdx)

    if isValid(newCell) then
      newCell.isEmpty = false

      for j = 0 to m.gridWrapper.getChildCount() - 1
        animation = m.gridWrapper.getChild(j)

        if animation.id.instr(Substitute("moveAnimation_{0}{1}", rowIdx.toStr(), cellIdx.toStr())) <> -1 then
          cellFrom = getCellCoordsById(Substitute("{0}{1}", rowIdx.toStr(), cellIdx.toStr()))
          interpolator = animation.getChild(0)
          interpolator.key = [0.0, 1.0]
          interpolator.keyValue = [[cellFrom.x, cellFrom.y], [newCell.x, newCell.y]]
          animation.control = "start"

          gameCell = _getCellById(Substitute("gameCell_{0}{1}", rowIdx.toStr(), cellIdx.toStr()))
          if isValid(gameCell) then
            gameCell.observeFieldScoped("translation", "_onGameCellTranslationChanged")
          end if
        end if
      end for
    end if
  end for
end sub

sub moveLeft(gameCells as dynamic)
  for i = 0 to gameCells.Count() - 1
    gameCell = gameCells[i]
    gameCell.isEmpty = true
    rowIdx = gameCell.row
    cellIdx = gameCell.cell
    newCell = getNewCellLeft(rowIdx, cellIdx)

    if isValid(newCell) then
      newCell.isEmpty = false
      for j = 0 to m.gridWrapper.getChildCount() - 1
        animation = m.gridWrapper.getChild(j)

        if animation.id.instr(Substitute("moveAnimation_{0}{1}", rowIdx.toStr(), cellIdx.toStr())) <> -1 then
          cellFrom = getCellCoordsById(Substitute("{0}{1}", rowIdx.toStr(), cellIdx.toStr()))
          interpolator = animation.getChild(0)
          interpolator.key = [0.0, 1.0]
          interpolator.keyValue = [[cellFrom.x, cellFrom.y], [newCell.x, newCell.y]]
          animation.control = "start"

          gameCell = _getCellById(Substitute("gameCell_{0}{1}", rowIdx.toStr(), cellIdx.toStr()))
          if isValid(gameCell) then
            gameCell.observeFieldScoped("translation", "_onGameCellTranslationChanged")
          end if
        end if
      end for
    end if
  end for
end sub

function getEmptyCells1()
  emptyCells = []
  for each row in m.cellsCoords
    for each cell in row
      if cell.isEmpty then emptyCells.push()
    end for
  end for
end function

function getGameCells(id = "gameCell_" as string)
  length = m.gridWrapper.getChildCount()
  cells = []
  for i = 0 to length - 1
    child = m.gridWrapper.getChild(i)
    if child.id.instr(id) <> -1 then cells.push(child.callFunc("getIndexes"))
  end for
  return cells
end function

function getCellCoordsById(id as string)
  for i = 0 to m.cellsCoords.Count() - 1
    row = m.cellsCoords[i]
    for j = 0 to row.Count() - 1
      if row[j].id.instr(id) <> -1 then return row[j]
    end for
  end for
end function

function onKeyEvent(key, press) as boolean
  if not press then
    return false
  else
    gameCells = getGameCells()

    if key = "up" then
      moveUp(gameCells)
      return true
    end if

    if key = "down" then
      moveDown(gameCells)
      return true
    end if

    if key = "right" then
      gameCells.Reverse()
      moveRight(gameCells)
      return true
    end if

    if key = "left" then
      moveLeft(gameCells)
      return true
    end if
  end if

  return false
end function

'private methods

function _getCellById(id as string) as dynamic
  for i = 0 to m.gridWrapper.getChildCount() - 1
    if m.gridWrapper.getChild(i).id = id then return m.gridWrapper.getChild(i)
  end for

  return invalid
end function

function _onGameCellTranslationChanged(event)
  targetNode = event.getRoSGNode()

  if isValid(targetNode) then
    indexes = targetNode.callFunc("getIndexes")
    targetAnimationNode = _getCellById(Substitute("moveAnimation_{0}{1}", indexes.row.toStr(), indexes.cell.toStr()))

    if isValid(targetAnimationNode) then

      currentPosX = targetNode.translation[0]
      currentPosY = targetNode.translation[1]

      interpolator = targetAnimationNode.getChild(0)
      if isNotEmptyArray(interpolator.keyValue) then
        newPosX = interpolator.keyValue[1][0]
        newPosY = interpolator.keyValue[1][1]

        if currentPosX = newPosX and currentPosY = newPosY then
          targetNode.unObserveFieldScoped("translation")

          for i = 0 to m.cellsCoords.Count() - 1
            row = m.cellsCoords[i]
            for j = 0 to row.Count() - 1
              cell = row[j]

              if cell.x = newPosX and cell.y = newPosY then
                targetNode.id = Substitute("gameCell_{0}{1}", i.toStr(), j.toStr())
                targetNode.callFunc("setIndexes", { row: i, cell: j, stringValue: i.toStr() + j.toStr() })
                backgroundCell = _getCellById(Substitute("backgroundCell_{0}{1}", i.toStr(), j.toStr()))
                backgroundCell.callFunc("setEmptyStatus", not backgroundCell.callFunc("getEmptyStatus"))
                m.cellsCoords[i][j].isEmpty = false


                oldBackgroundCell = _getCellById(Substitute("backgroundCell_{0}{1}", indexes.row.toStr(), indexes.cell.toStr()))
                oldBackgroundCell.callFunc("setEmptyStatus", not oldBackgroundCell.callFunc("getEmptyStatus"))
                m.cellsCoords[indexes.row][indexes.cell].isEmpty = true
              end if
            end for
          end for
        end if
      end if
    end if
  end if
end function
