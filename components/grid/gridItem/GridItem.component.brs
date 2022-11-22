sub init()
  m.background = m.top.findNode("background")
  m.cellLabel = m.top.findNode("cellLabel")
  m.value = invalid
  m.coords = invalid
  m.indexes = invalid
  m.isEmpty = true
  m.BACKGROUND_COLORS = {
    "2": "#7b5c62",
    "4": "#e07a5f",
    "8": "#4800ff",
    "16": "#004225",
    "32": "#94a88f",
    "64": "#626a4c",
    "128": "#2ad3ff",
    "256": "#6a7865",
    "512": "#5a0441",
    "1024": "#ff3569",
    "2048": "#e08dff"
  }
end sub

sub draw(settings as dynamic)
  if isNotEmptyObject(settings) then
    m.top.id = settings.id

    m.background.update({
      color: settings.color,
      width: settings.width,
      height: settings.height
    })

    m.backgroundBound = m.background.boundingRect()
    m.coords = settings.coords
    if isValid(settings.indexes)
      m.indexes = settings.indexes
      m.indexes.stringValue = settings.indexes.row.toStr() + settings.indexes.cell.toStr()
    end if

    if isInteger(settings.value) then
      m.top.isActive = true
      m.value = settings.value
      m.cellLabel.update({ text: settings.value.toStr() })
      cellLabelBound = m.cellLabel.boundingRect()
      m.cellLabel.translation = [(m.backgroundBound.width - cellLabelBound.width) / 2, (m.backgroundBound.height - cellLabelBound.height) / 2]
    end if

    if m.top.id.instr("gameCell_") <> -1 then m.top.observeFieldScoped("translation", "onTranslationChanged")
  end if

  if m.top.id.instr("backgroundCell_") <> -1 then m.cellLabel.text = m.indexes.stringValue
  if m.top.id.instr("gameCell_") <> -1 then m.cellLabel.text = m.indexes.stringValue
end sub

sub update(data as object)
  m.cellLabel.text = data.text
  _updateCellLabelTranslation()
end sub

sub onTranslationChanged(event)
  translation = event.getData()
  newCoords = m.top.newCoords
  if isInValid(newCoords) then return
  if translation[0] = m.top.newCoords.x and translation[1] = m.top.newCoords.y then
    m.cellLabel.text = m.top.newCoords.row.toStr() + m.top.newCoords.cell.toStr()
    m.top.id = m.top.newCoords.id
  end if
end sub

'private

sub _updateCellLabelTranslation()
  cellLabelBound = m.cellLabel.boundingRect()
  m.cellLabel.update({
    translation: [
      (m.backgroundBound.width - cellLabelBound.width) / 2,
      (m.backgroundBound.height - cellLabelBound.height) / 2
    ]
  })
end sub

'setters

sub setEmptyStatus(status)
  m.isEmpty = status
end sub

sub setIndexes(indexes)
  m.indexes = indexes
  if m.top.id.instr("backgroundCell_") <> -1 then
    m.cellLabel.text = m.indexes.stringValue
  end if
  if m.top.id.instr("gameCell_") <> -1 then
    m.cellLabel.text = m.indexes.stringValue
  end if
end sub

sub updateValue(value)
  m.top.isActive = true
  m.value = value
  m.cellLabel.update({ text: value.toStr() })
  _updateCellLabelTranslation()
end sub

'getters

function getValue()
  return m.value
end function

function getCoords()
  return m.coords
end function

function getIndexes()
  return m.indexes
end function

function getEmptyStatus()
  return m.isEmpty
end function