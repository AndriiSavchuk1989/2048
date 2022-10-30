sub init()
  m.deviceInfo = CreateObject("roDeviceInfo")

  initRouter()

  m.global.router.callFunc("navigateTo", "start_page")
end sub

sub initRouter()
  deviceInfo = CreateObject("roDeviceInfo")
  m.global.update({
    router: m.top.findNode("router")
    screenSize: deviceInfo.GetDisplaySize()
  }, true)
end sub
