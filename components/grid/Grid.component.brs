sub init()
  m.top.observeFieldScoped("proceed", "onProceedAnimation")
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

  m.BACKGROUND_CELL_ID = "backgroundCell_"
  m.GAME_CELL_ID = "gameCell_"
  m.ANIMATION_ID = "moveAnimation_"

  fillGrid()
  m.animationQueue = []
  m.movingCells = []
  m.direction = ""
  m.animationCount = 0
  m.currentAnimation = invalid
end sub

sub onProceedAnimation(event)
  isProceed = event.getData()
  if isProceed then proceedAnimation()
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
  'return [{ row: 1, cell: 3 }, { row: 3, cell: 3 }]
  'return [{ row: 2, cell: 3 }, { row: 3, cell: 2 }]
  'return [{ row: 1, cell: 3 }, { row: 3, cell: 1 }]
  'return [{ row: 1, cell: 2 }, { row: 2, cell: 2 }] down
  'return [{ row: 3, cell: 2 }, { row: 3, cell: 3 }, { row: 2, cell: 3 }, { row: 1, cell: 3 }]
  return [{ row: 2, cell: 3 }, { row: 2, cell: 1 }]
  'return [{ row: 2, cell: 0 }, { row: 2, cell: 1 }]
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
      gameCellId = _getGameCellId(coords)

      createBackgroundCell({
        coords: coords,
        height: height,
        width: width,
        translation: [translationX, translationY],
        indexes: { row: i, cell: j }
      })

      m.cellsCoords[i].push({
        id: gameCellId,
        x: translationX,
        y: translationY,
        isEmpty: true,
        row: i,
        cell: j
      })

      createAnimation(coords, gameCellId)
    end for
  end for


  createRandomCells(createRandomCoords(), {
    width: width
    height: height
    color: "#C70000"
  })
  _updateActiveGameCells()
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
    }, true)
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

  ' set empty state for first random cells
  for each cell in randomCells
    backgroundCell = _getElementById(_getBackgroundCellId(cell.row.toStr() + cell.cell.toStr()))
    backgroundCell.callFunc("setEmptyStatus", false)
  end for

  ' collect all empty cells
  for j = 0 to m.gridWrapper.getChildCount() - 1
    child = m.gridWrapper.getChild(j)

    if isValid(child) and child.id.instr(m.BACKGROUND_CELL_ID) <> -1 and child.callFunc("getEmptyStatus") then
      emptyCells.push(child)
    end if
  end for

  return emptyCells
end function

sub createRandomCells(randomCells as dynamic, basicSettings as dynamic)
  if isNotEmptyArray(randomCells) and isNotEmptyObject(basicSettings) then
    emptyCells = getEmptyCells(randomCells)

    for i = 0 to randomCells.Count() - 1
      emptyCell = randomCells[i]
      id = emptyCell.row.toStr() + emptyCell.cell.toStr()
      cellData = _getBackgroundCellData(_getGameCellId(id))
      basicSettings.translation = [cellData.x, cellData.y]
      basicSettings.coords = emptyCell.row.toStr() + emptyCell.cell.toStr()
      basicSettings.indexes = {
        row: emptyCell.row,
        cell: emptyCell.cell
      }
      createGameCell(basicSettings)
    end for
  end if
end sub

sub createAnimation(coords, cellId)
  animation = m.gridWrapper.createChild("Animation")
  animation.id = _getAnimationId(coords)
  animation.duration = 0.25
  animation.repeat = false
  animation.easeFunction = "linear"
  interpolator = animation.createChild("Vector2DFieldInterpolator")
  interpolator.fieldToInterp = Substitute("{0}{1}", cellId, ".translation")
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

function _getCellCoordById(id as string) as dynamic
  for each row in m.cellsCoords
    for each cell in row
      if cell.id = id then return cell
    end for
  end for

  return invalid
end function

'move functions
function moveDown(direction = "down" as string)
  m.animationQueue = []
  m.direction = direction
  gameNodes = getSpecificNodesById(m.GAME_CELL_ID)
  cells = []

  for each gameNode in gameNodes
    cells.push(_getCellCoordById(gameNode.id))
  end for

  cellsAnimationData = filterCells(cells)
  cellsAnimationData.SortBy("activeCellIndex")

  for each cellAnimationData in cellsAnimationData

    cellAnimationData.activeCells.SortBy("row")
    cellAnimationData.activeCells.Reverse()

    for each activeCell in cellAnimationData.activeCells
      toCell = getToCell(activeCell, cellAnimationData.path)
      if isValid(activeCell) and isValid(toCell) then
        'check
        'm.cellsCoords[activeCell.row][activeCell.cell].isEmpty = true
        'm.cellsCoords[toCell.row][toCell.cell].isEmpty = false

        animationNode = _getElementById(_getAnimationId(activeCell.row.toStr() + activeCell.cell.toStr()))
        interpolator = animationNode.getChild(0)
        interpolator.update({
          key: [0.0, 1.0],
          keyValue: [[activeCell.x, activeCell.y], [toCell.x, toCell.y]]
        })

        data = {
          animation: animationNode,
          fromCell: activeCell,
          toCell: toCell
        }

        m.animationQueue.push(data)
      end if
    end for
  end for

  proceedAnimation()
end function

function getToCell(activeCell as dynamic, cells as dynamic) as dynamic
  if isInvalid(activeCell) and isEmptyArray(cells) return invalid

  if isDownKeyPressed()
    for i = cells.Count() - 1 to 0 step -1
      if cells[i].isEmpty then
        cells[i].isEmpty = false
        return cells[i]
      end if
    end for
  else if isUpKeyPressed() then
    for i = cells.Count() - 1 to 0 step -1
      if cells[i].isEmpty then
        cells[i].isEmpty = false
        return cells[i]
      end if
    end for
  else if isRightKeyPressed() then
    for i = 0 to cells.Count() - 1
      if cells[i].isEmpty then
        cells[i].isEmpty = false
        return cells[i]
      end if
    end for
  else if isLeftKeyPressed()
    for i = cells.Count() - 1 to 0 step -1
      if cells[i].isEmpty then
        cells[i].isEmpty = false
        return cells[i]
      end if
    end for
  end if

  return invalid
end function

function isDownKeyPressed() as boolean
  return m.direction = "down"
end function

function isUpKeyPressed() as boolean
  return m.direction = "up"
end function

function isRightKeyPressed() as boolean
  return m.direction = "right"
end function

function isLeftKeyPressed() as boolean
  return m.direction = "left"
end function

function filterCells(cells as dynamic)
  cellsAnimationData = []

  if isEmptyArray(cells) then return invalid

  if isDownKeyPressed() then

    for each cell in cells
      isCellIndexExist = false

      for n = 0 to cellsAnimationData.Count() - 1
        animationData = cellsAnimationData[n]

        if animationData.activeCellIndex = cell.cell
          isCellIndexExist = true
          exit for
        end if
      end for

      rowIndex = cell.row
      cellIndex = cell.cell

      if not isCellIndexExist then
        cellAnimationData = {
          activeCellIndex: cellIndex,
          activeCells: [],
          path: []
        }

        for i = 0 to m.cellsCoords.Count() - 1
          row = m.cellsCoords[i]

          for j = 0 to row.Count() - 1
            if row[j].cell = cellIndex then
              if not row[j].isEmpty then
                cellAnimationData.activeCells.push(row[j])
              end if
              cellAnimationData.path.push(row[j])
            end if
          end for
        end for

        cellsAnimationData.push(cellAnimationData)
      end if
    end for
  else if isUpKeyPressed()

    for each cell in cells
      isCellIndexExist = false

      for n = 0 to cellsAnimationData.Count() - 1
        animationData = cellsAnimationData[n]
        if animationData.activeCellIndex = cell.cell then
          isCellIndexExist = true
          exit for
        end if
      end for

      rowIndex = cell.row
      cellIndex = cell.cell

      if not isCellIndexExist then
        cellAnimationData = {
          activeCellIndex: cellIndex,
          activeCells: [],
          path: []
        }

        for i = m.cellsCoords.Count() - 1 to 0 step -1
          row = m.cellsCoords[i]

          for j = 0 to row.Count() - 1
            if row[j].cell = cellIndex then
              if not row[j].isEmpty then cellAnimationData.activeCells.push(row[j])
              cellAnimationData.path.push(row[j])
            end if
          end for
        end for

        cellsAnimationData.push(cellAnimationData)
      end if
    end for
  else if isLeftKeyPressed() then
    'check
    for each cell in cells
      isRowIndexExist = false

      for n = 0 to cellsAnimationData.Count() - 1
        animationData = cellsAnimationData[n]
        if animationData.activeRowIndex = cell.row
          isRowIndexExist = true
          exit for
        end if
      end for

      rowIndex = cell.row
      cellIndex = cell.cell

      if not isRowIndexExist then
        cellAnimationData = {
          activeRowIndex: rowIndex,
          activeCells: [],
          path: []
        }

        row = m.cellsCoords[rowIndex]

        for i = row.Count() - 1 to 0 step -1
          if not row[i].isEmpty then cellAnimationData.activeCells.push(row[i])
          cellAnimationData.path.push(row[i])
        end for

        cellsAnimationData.push(cellAnimationData)
      end if

    end for
  else if isRightKeyPressed()
    for each cell in cells
      isRowIndexExist = false

      if isNotEmptyArray(cellsAnimationData) then
        for n = 0 to cellsAnimationData.Count() - 1
          animationData = cellsAnimationData[n]
          if animationData.activeRowIndex = cell.row
            isRowIndexExist = true
            exit for
          end if
        end for
      end if

      rowIndex = cell.row
      cellIndex = cell.cell

      if not isRowIndexExist then
        cellAnimationData = {
          activeRowIndex: rowIndex,
          activeCells: [],
          path: []
        }

        row = m.cellsCoords[rowIndex]

        for i = row.Count() - 1 to 0 step -1
          if not row[i].isEmpty then cellAnimationData.activeCells.push(row[i])
          cellAnimationData.path.push(row[i])
        end for

        cellsAnimationData.push(cellAnimationData)
      end if
    end for
  end if

  return cellsAnimationData
end function

function moveUp(direction = "up" as string)
  m.animationQueue = []
  m.direction = direction
  gameNodes = getSpecificNodesById(m.GAME_CELL_ID)
  cells = []

  for each gameNode in gameNodes
    cells.push(_getCellCoordById(gameNode.id))
  end for

  cellsAnimationData = filterCells(cells)

  for each cellAnimationData in cellsAnimationData
    cellAnimationData.activeCells.Reverse()

    for each activeCell in cellAnimationData.activeCells
      fromCell = activeCell
      toCell = getToCell(activeCell, cellAnimationData.path)
      if isValid(fromCell) and isValid(toCell) then

        m.cellsCoords[fromCell.row][fromCell.cell].isEmpty = true
        m.cellsCoords[toCell.row][toCell.cell].isEmpty = false

        animationNode = _getElementById(_getAnimationId(fromCell.row.toStr() + fromCell.cell.toStr()))
        interpolator = animationNode.getChild(0)
        interpolator.update({
          key: [0.0, 1.0],
          keyValue: [[fromCell.x, fromCell.y], [toCell.x, toCell.y]]
        })

        data = {
          animation: animationNode,
          fromCell: fromCell
        }

        m.animationQueue.push(data)
      end if
    end for
  end for

  proceedAnimation()
end function

function getAnimationNodes()
  animations = []

  for i = 0 to m.gridWrapper.getChildCount() - 1
    child = m.gridWrapper.getChild(i)
    if child.id.instr("moveAnimation_") <> -1 then animations.push(child)
  end for

  return animations
end function

function isCurrentlyMoving()
  animationNodes = getAnimationNodes()
  for i = 0 to animationNodes.Count() - 1
    if animationNodes[i].state = "running" return true
  end for

  return false
end function

function moveRight(direction = "right")
  m.animationQueue = []
  m.direction = direction
  gameNodes = getSpecificNodesById(m.GAME_CELL_ID)
  cells = []

  for each gameNode in gameNodes
    cells.push(_getCellCoordById(gameNode.id))
  end for

  cellsAnimationData = filterCells(cells)

  for each cellAnimationData in cellsAnimationData
    cellAnimationData.activeCells.SortBy("cell")
    cellAnimationData.activeCells.Reverse()
    for each activeCell in cellAnimationData.activeCells
      fromCell = activeCell
      toCell = getToCell(activeCell, cellAnimationData.path)
      if isValid(fromCell) and isValid(toCell) then
        m.cellsCoords[fromCell.row][fromCell.cell].isEmpty = true
        m.cellsCoords[toCell.row][toCell.cell].isEmpty = false

        animationNode = _getElementById(_getAnimationId(fromCell.row.toStr() + fromCell.cell.toStr()))
        interpolator = animationNode.getChild(0)
        interpolator.update({
          key: [0.0, 1.0],
          keyValue: [[fromCell.x, fromCell.y], [toCell.x, toCell.y]]
        })

        data = {
          animation: animationNode,
          fromCell: fromCell
        }

        m.animationQueue.push(data)
      end if
    end for
  end for

  proceedAnimation()
end function

sub showGameNodes(gameNodes)
  for each node in gameNodes
    ? "gameNode "; node
  end for
end sub

sub showCellsCoords(cells)
  for each cell in cells
    ? "cell "; cell
  end for
end sub

function moveLeft(direction = "left")
  m.animationQueue = []
  m.direction = direction
  gameNodes = getSpecificNodesById(m.GAME_CELL_ID)
  cells = []

  for each gameNode in gameNodes
    cells.push(_getCellCoordById(gameNode.id))
  end for

  cellsAnimationData = filterCells(cells)

  for each item in cellsAnimationData
    item.activeCells.SortBy("cell")
  end for

  for each cellAnimationData in cellsAnimationData
    for each activeCell in cellAnimationData.activeCells
      toCell = getToCell(activeCell, cellAnimationData.path)
      if isValid(activeCell) and isValid(toCell) then
        m.cellsCoords[activeCell.row][activeCell.cell].isEmpty = true
        m.cellsCoords[toCell.row][toCell.cell].isEmpty = false

        animationNode = _getElementById(_getAnimationId(activeCell.row.toStr() + activeCell.cell.toStr()))
        interpolator = animationNode.getChild(0)
        interpolator.update({
          key: [0.0, 1.0],
          keyValue: [[activeCell.x, activeCell.y], [toCell.x, toCell.y]]
        })

        data = {
          animation: animationNode,
          fromCell: activeCell,
          toCell: toCell
        }

        'm.animationQueue.push(data)
        animationNode.control = "start"
      end if
    end for
  end for

  'm.animationQueue.Reverse()

  proceedAnimation()
end function

'move functions

function _getGameCellById(row, cell)
  return _getElementById(Substitute("gameCell_{0}{1}", row.toStr(), cell.toStr()))
end function

sub proceedAnimation()
  if isNotEmptyArray(m.animationQueue) then
    for each animation in m.animationQueue

      if isValid(animation) then
        fromCell = animation.fromCell

        if isValid(fromCell) then
          gameCell = _getGameCellById(animation.fromCell.row, animation.fromCell.cell)

          if isValid(gameCell) then
            if isDownKeyPressed() then ? " gameCell "; gameCell
            'gameCell.observeFieldScoped("translation", "_onGameCellTranslationChanged")
            gameCell.newCoords = animation.toCell
            animation = animation.animation
            animation.control = "start"
          end if
        end if
      end if
    end for
  end if
end sub

function getSpecificNodesById(id as string)
  cells = []
  for i = 0 to m.gridWrapper.getChildCount() - 1
    child = m.gridWrapper.getChild(i)
    if isValid(child) and isNotEmptyString(child.id) and child.id.instr(id) <> -1 then cells.push(child)
  end for
  return cells
end function

function getCellCoordsById(id as string)
  for i = 0 to m.cellsCoords.Count() - 1
    row = m.cellsCoords[i]
    for j = 0 to row.Count() - 1
      if isValid(row[j]) and isNotEmptyString(row[j].id) and row[j].id.instr(id) <> -1 then return row[j]
    end for
  end for

  return invalid
end function

function onKeyEvent(key, press) as boolean
  if not press then
    return false
  else 'if not isCurrentlyMoving() and isEmptyArray(m.animationQueue)
    if key = "up" then
      moveUp()
      return true
    end if

    if key = "down" then
      moveDown()
      return true
    end if

    if key = "right" then
      moveRight()
      return true
    end if

    if key = "left" then
      moveLeft()
      return true
    end if

    if key = "OK" then
      showActiveGameCells()
      showActiveGameNodes()
      showRunningAnimation()
      foo()
      return true
    end if
  end if

  return false
end function

sub showActiveGameCells()
  active = _getActiveGameCells()
  for each cell in active
    ? "active "; cell
  end for
end sub

sub showActiveGameNodes()
  for i = 0 to m.gridWrapper.getChildCount() - 1
    child = m.gridWrapper.getChild(i)
    if child.id.instr(m.GAME_CELL_ID) <> -1 then ? "game node "; child
  end for
end sub

sub showRunningAnimation()
  for i = 0 to m.gridWrapper.getChildCount() - 1
    child = m.gridWrapper.getChild(i)
    if child.id.instr(m.ANIMATION_ID) <> -1 and child.state = "running" then ? "animation node "; child
  end for
end sub

sub foo()
  m.animationQueue[0].animation.control = "start"
end sub

'private methods

function _getGameCellId(indexId as string)
  return _getElementId("gameCell_{0}", indexId)
end function

function _getBackgroundCellId(indexId as string)
  return _getElementId("backgroundCell_{0}", indexId)
end function

function _getAnimationId(indexId as string)
  return _getElementId("moveAnimation_{0}", indexId)
end function

function _getElementId(partialId as string, indexId as string)
  return Substitute(partialId, indexId)
end function

function _getElementById(id as string) as dynamic
  for i = 0 to m.gridWrapper.getChildCount() - 1
    if m.gridWrapper.getChild(i).id = id then return m.gridWrapper.getChild(i)
  end for

  return invalid
end function

function _getActiveGameCells() as object
  activeGameCells = []
  for i = 0 to m.cellsCoords.Count() - 1
    row = m.cellsCoords[i]
    for j = 0 to row.Count() - 1
      cell = row[j]
      if not cell.isEmpty then
        activeGameCells.push(cell)
      end if
    end for
  end for

  return activeGameCells
end function

sub _updateActiveGameCells()
  m.activeGameCells = []

  for i = 0 to m.gridWrapper.getChildCount() - 1
    child = m.gridWrapper.getChild(i)
    if child.id.instr("gameCell_") <> -1 then
      m.activeGameCells.push(child.id)
    end if
  end for

  tempArray = []
  for each id in m.activeGameCells

    for each row in m.cellsCoords
      for each cell in row
        cell.isEmpty = true
        if cell.id = id then
          tempArray.push(cell)
        end if
      end for
    end for
  end for

  for each item in tempArray
    item.isEmpty = false
  end for

  for each tempCell in tempArray
    for each row in m.cellsCoords
      for each cell in row
        if cell.id = tempCell.id then
          cell = tempCell
        end if
      end for
    end for
  end for
end sub

function _getBackgroundCellData(id as string)
  for i = 0 to m.cellsCoords.Count() - 1
    row = m.cellsCoords[i]

    for j = 0 to row.Count() - 1
      cell = row[j]
      if cell.id = id then return cell
    end for
  end for
end function

function isTargetNodeExist(targetNode as dynamic) as boolean
  if isInvalid(targetNode) then return false

  for each node in m.movingCells
    if node.id = targetNode.id then return true
  end for

  return false
end function

function getCellDataByXY(x as integer, y as integer) as dynamic
  for each row in m.cellsCoords
    for each cell in row
      if cell.x = x and cell.y = y then return cell
    end for
  end for
  return invalid
end function

function _onGameCellTranslationChanged(event)
  targetNode = event.getRoSGNode()
  data = event.getData()

  if isValid(targetNode) then

    indexes = targetNode.callFunc("getIndexes")
    targetAnimationNode = _getElementById(_getAnimationId(indexes.row.toStr() + indexes.cell.toStr()))


    currentPosX = targetNode.translation[0]
    currentPosY = targetNode.translation[1]
    interpolator = targetAnimationNode.getChild(0)
    newPosX = interpolator.keyValue[1][0]
    newPosY = interpolator.keyValue[1][1]


    if currentPosX = newPosX and currentPosY = newPosY then
      m.previousTargetNode = targetNode
      if isDownKeyPressed() then ? " m.previousTargetNode "; m.previousTargetNode
      targetAnimationNode.control = "stop"
      targetNode.unObserveFieldScoped("translation")
      shifted = m.animationQueue.Shift()
      'if isDownKeyPressed() then
      '? "shifted from"; shifted.fromCell
      '? "shifted to "; shifted.toCell
      '?' "m.currentAnimation "; m.currentAnimation
      ' end if
      if shifted.toCell.x = newPosX and shifted.toCell.y = newPosY
        rowCoord = shifted.toCell.row.toStr()
        cellCoord = shifted.toCell.cell.toStr()
        stringValue = rowCoord + cellCoord

        targetNode.id = Substitute("gameCell_{0}{1}", rowCoord, cellCoord)
        targetNode.callFunc("setIndexes", { row: shifted.toCell.row, cell: shifted.toCell.cell, stringValue: stringValue })

        backgroundCell = _getElementById(Substitute("backgroundCell_{0}{1}", rowCoord, cellCoord))
        backgroundCell.callFunc("setEmptyStatus", not backgroundCell.callFunc("getEmptyStatus"))

        oldBackgroundCell = _getElementById(Substitute("backgroundCell_{0}{1}", indexes.row.toStr(), indexes.cell.toStr()))
        oldBackgroundCell.callFunc("setEmptyStatus", not oldBackgroundCell.callFunc("getEmptyStatus"))
      end if
      _updateActiveGameCells()
      proceedAnimation()
    end if
  end if
end function

function isMergeCells(row as integer, cell as integer)
  currentCell = _getElementById(Substitute("backgroundCell_{0}{1}", row.toStr(), cell.toStr()))
  currentGameCell = _getElementById(Substitute("gameCell_{0}{1}", row.toStr(), cell.toStr()))

  nextRowCoord = row
  nextCellCoord = cell
  if m.direction = "down" then
    nextRowCoord += 1
  else if m.direction = "up" then
    nextRowCoord -= 1
  else if m.direction = "right" then
    nextCellCoord += 1
  else if m.direction = "left" then
    nextCellCoord -= 1
  end if

  nextCell = _getElementById(Substitute("backgroundCell_{0}{1}", nextRowCoord.toStr(), nextCellCoord.toStr()))
  nextGameCell = _getElementById(Substitute("gameCell_{0}{1}", nextRowCoord.toStr(), nextCellCoord.toStr()))

  isValidBackgroundCells = isValid(nextCell) and isValid(currentCell)
  isValidGameCells = isValid(nextGameCell) and isValid(currentGameCell)

  if isValidBackgroundCells and isValidGameCells then
    currentGameCellValue = currentGameCell.callFunc("getValue")
    nextGameCellValue = nextGameCell.callFunc("getValue")

    if currentGameCellValue = nextGameCellValue then
      currentPos = currentGameCell.translation
      newPos = nextGameCell.translation

      currentAnimation = _getElementById(Substitute("moveAnimation_{0}{1}", row.toStr(), cell.toStr()))
      interpolator = currentAnimation.getChild(0)
      interpolator.key = [0.0, 1.0]
      interpolator.keyValue = [[currentPos[0], currentPos[1]], [newPos[0], newPos[1]]]

      if isNotEmptyArray(m.animationQueue) then
        interpolator = m.animationQueue[0].animation.getChild(0)
        nextRow = m.cellsCoords[row][cell]
        interpolator.keyValue = [interpolator.keyValue[0], [nextRow.x, nextRow.y]]
      end if

      currentGameCell.isActive = false
      m.gridWrapper.removeChild(currentGameCell)
      nextGameCell.callFunc("updateValue", currentGameCellValue + nextGameCellValue)
    end if
  end if
end function
