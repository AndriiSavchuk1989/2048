sub init()
  m.background = m.top.findNode("background")
  m.cellLabel = m.top.findNode("cellLabel")
  m.value = invalid
  m.coords = invalid
  m.indexes = invalid
  m.isEmpty = true
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
      m.value = settings.value
      m.cellLabel.update({ text: settings.value.toStr() })
      cellLabelBound = m.cellLabel.boundingRect()
      m.cellLabel.translation = [(m.backgroundBound.width - cellLabelBound.width) / 2, (m.backgroundBound.height - cellLabelBound.height) / 2]
    end if
  end if
end sub

sub update(data as object)
  m.cellLabel = data.text
  cellLabelBound = m.cellLabel.boundingRect()
  m.cellLabel.update({
    translation: [
      (m.backgroundBound.width - cellLabelBound.width) / 2,
      (m.backgroundBound.height - cellLabelBound.background.height) / 2
    ]
  })
end sub

'setters

sub setEmptyStatus(status)
  m.isEmpty = status
end sub

sub setIndexes(indexes)
  m.indexes = indexes
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