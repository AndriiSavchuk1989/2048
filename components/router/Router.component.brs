sub init()
  m.history = []
end sub

sub navigateTo(gamePath as dynamic) as dynamic
  if isNotEmptyString(gamePath) then getGameScreen(gamePath)

  return invalid
end sub

sub getGameScreen(path as string) as dynamic
  ? "path "; path
  cleanUp()
  if path = "2048" then
    m.screen = CreateObject("roSGNode", "GridComponent")
    screen = {
      path: path,
      componentName: "GridComponent",
      component: m.screen
    }

    m.history.push(screen)
    m.screen.callFunc("setupGrid")
    m.top.insertChild(m.screen, 0)
    m.screen.setFocus(true)
  else if path = "start_page" then
    m.screen = CreateObject("roSGNode", "StartPageComponent")
    screen = {
      path: path,
      componentName: "StartPageComponent",
      component: m.screen
    }

    m.history.push(screen)
    m.top.insertChild(m.screen, 0)
    m.screen.setFocus(true)
  end if
end sub

sub cleanUp()
  if isValid(m.screen) then
    m.top.removeChild(m.screen)
    m.screen = invalid
  end if
end sub