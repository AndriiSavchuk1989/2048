sub init()
  m.background = m.top.findNode("background")
  m.button = m.top.findNode("button")
  m.button.callFunc("draw")

  m.top.observeFieldScoped("focusedChild", "onFocusChanged")
end sub

sub onFocusChanged()
  m.button.setFocus(true)
end sub

function onKeyEvent(key, press) as boolean
  if not press then
    return false
  end if

  if key = "up" then
    m.button.setFocus(true)
    return true
  end if

  if key = "down" then
    m.button.setFocus(true)
    return true
  end if

  return false
end function