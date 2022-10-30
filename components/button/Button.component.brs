sub init()
  m.background = m.top.findNode("background")
  m.buttonText = m.top.findNode("buttonText")

  m.BUTTON_TEXT = "START"
  m.BUTTON_PADDINGS = {
    vertical: 10,
    horizontal: 15
  }
  m.BUTTON_BACKGROUND = "#FFF300"

  m.BUTTON_FOCUSED_STYLE = {
    text: {
      color: "#FB00FF"
    }
    background: {
      color: "#0042FF"
    }
  }

  m.BUTTON_INITIAL_STYLE = {
    text: {
      color: "#E0FF00"
    }
    background: {
      color: "#00FFB2"
    }
  }
  m.top.observeFieldScoped("focusedChild", "onFocusChanged")
end sub

sub draw()
  m.buttonText.text = m.BUTTON_TEXT
  buttonTextBound = m.buttonText.boundingRect()


  m.background.width = buttonTextBound.width + 2 * m.BUTTON_PADDINGS.horizontal
  m.background.height = buttonTextBound.height + 2 * m.BUTTON_PADDINGS.vertical
  applyButtonStyle(false)
  backgroundBound = m.background.boundingRect()

  m.background.translation = [(1920 - backgroundBound.width) / 2, (1080 - backgroundBound.height) / 2]
  m.buttonText.translation = [(backgroundBound.width - buttonTextBound.width) / 2, (backgroundBound.height - buttonTextBound.height) / 2]
end sub

sub applyInitialStyle()
  m.background.update(m.BUTTON_INITIAL_STYLE.background)
  m.buttonText.update(m.BUTTON_INITIAL_STYLE.text)
end sub

sub applyFocusedStyle()
  m.background.update(m.BUTTON_FOCUSED_STYLE.background)
  m.buttonText.update(m.BUTTON_FOCUSED_STYLE.text)
end sub

sub applyButtonStyle(isInFocus as boolean)
  ? "isInFocus "; isInFocus
  if isInFocus then
    applyFocusedStyle()
  else
    applyInitialStyle()
  end if
end sub

function onKeyEvent(key, press) as boolean
  if not press then
    return false
  end if

  if key = "OK" then
    m.global.router.callFunc("navigateTo", "2048")
    return true
  end if

  return false
end function

'listeners
sub onFocusChanged()
  ? "focus changed"
  applyButtonStyle(m.top.hasFocus())
end sub
