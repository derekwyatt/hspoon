-------------------------------------------------------------------
-- Globals
-------------------------------------------------------------------
hs.window.animationDuration = 0

-------------------------------------------------------------------
-- Events
--
-- I just use this to explore some possibilities, but have never 
-- actually done anything with it, so all it does "for real" is 
-- return false
-------------------------------------------------------------------
-- theEventTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
--   if e:getKeyCode() == 105 then
--     print("Received keydown event: " .. e:getKeyCode())
--     hs.caffeinate.startScreensaver()
--     return true
--   else
--     return false
--   end
-- end)
-- theEventTap:start()

-------------------------------------------------------------------
-- ControlEscape
--
-- Neat little plug to allow me to use the CONTROL key (which is
-- actually my CAPSLOCK key, after mapping it using the standard
-- Mac keyboard preferences) to mimic the ESCAPE key.
-------------------------------------------------------------------
-- theControlEscape = hs.loadSpoon('ControlEscape')
-- theControlEscape:start()

-------------------------------------------------------------------
-- Vim Mode
--
-- Not sure I like this one... but I'm still trying it out.
-------------------------------------------------------------------

-- vim = hs.loadSpoon('VimMode')
-- 
-- hs.hotkey.bind({'ctrl'}, ';', function()
--   vim:enter()
-- end)

-------------------------------------------------------------------
-- Window Layouts
-------------------------------------------------------------------

lg = hs.logger.new('windowmgr', 'debug')
function getScreen(name)
  screen = hs.screen.findByName(name)
  if screen == nil then
    lg:i("Screen for {} was nil. Defaulting to LCD", name)
    screen = hs.screen.findByName("LCD")
  end

  return screen
end

-- These are just convenient names for layouts. We can use numbers
-- between 0 and 1 for defining 'percentages' of screen real estate
-- so 'right30' is the window on the right of the screen where the
-- vertical split (x-axis) starts at 70% of the screen from the
-- left, and is 30% wide.
--
-- And so on...
units = {
  right30       = { x = 0.70, y = 0.00, w = 0.30, h = 1.00 },
  right70       = { x = 0.30, y = 0.00, w = 0.70, h = 1.00 },
  left70        = { x = 0.00, y = 0.00, w = 0.70, h = 1.00 },
  left30        = { x = 0.00, y = 0.00, w = 0.30, h = 1.00 },
  top50         = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 },
  bot50         = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },
  bot80         = { x = 0.00, y = 0.20, w = 1.00, h = 0.80 },
  bot87         = { x = 0.00, y = 0.20, w = 1.00, h = 0.87 },
  bot90         = { x = 0.00, y = 0.20, w = 1.00, h = 0.90 },
  upright30     = { x = 0.70, y = 0.00, w = 0.30, h = 0.50 },
  botright30    = { x = 0.70, y = 0.50, w = 0.30, h = 0.50 },
  upleft70      = { x = 0.00, y = 0.00, w = 0.70, h = 0.50 },
  botleft70     = { x = 0.00, y = 0.50, w = 0.70, h = 0.50 },
  right70top80  = { x = 0.70, y = 0.00, w = 0.30, h = 0.80 },
  middletall    = { x = 0.25, y = 0.00, w = 0.55, h = 1.00 },
  maximum       = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },
  center        = { x = 0.05, y = 0.05, w = 0.90, h = 0.90 }
}

-- There is a 'layout' plugin but it was more difficult for me to
-- understand than it was for me to just write my own, so this is
-- my definitions for defining the layouts for all of the apps
-- that I tend to use.
layouts = {
  work = {
    { appname = 'Slack',         app = 'Slack.app',             unit = units.center,  screen = "LCD" },
    { appname = 'Outlook',       app = 'Microsoft Outlook.app', unit = units.maximum, screen = "LCD" },
    { appname = 'zoom.us',       app = 'zoom.us.app',           unit = units.maximum, screen = "LCD" },
    { appname = 'VimR',          app = 'VimR.app',              unit = units.left70,  screen = "Dell" },
    { appname = 'iTerm2',        app = 'iTerm.app',             unit = units.right30, screen = "Dell" },
    { appname = 'Google Chrome', app = 'Google Chrome.app',     unit = units.left70,  screen = "Dell" },
    { appname = 'Signal',        app = 'Signal.app',            unit = units.center,  screen = "Dell" },
  },
  -- Same as above but flip screens
  alternatework = {
    { appname = 'Slack',         app = 'Slack.app',             unit = units.center,  screen = "Dell" },
    { appname = 'Outlook',       app = 'Microsoft Outlook.app', unit = units.maximum, screen = "Dell" },
    { appname = 'zoom.us',       app = 'zoom.us.app',           unit = units.maximum, screen = "Dell" },
    { appname = 'VimR',          app = 'VimR.app',              unit = units.left70,  screen = "LCD" },
    { appname = 'iTerm2',        app = 'iTerm.app',             unit = units.right30, screen = "LCD" },
    { appname = 'Google Chrome', app = 'Google Chrome.app',     unit = units.left70,  screen = "LCD" },
    { appname = 'Signal',        app = 'Signal.app',            unit = units.center,  screen = "LCD" },
  }
}

-- Tells me whether or not the machine running Hammerspoon is
-- my work machine or not
function isWorkMachine()
  local allNames = hs.host.names()
  for i=1,#allNames do
    if allNames[i]:match('^cawl') then
      return true
    end
  end
  return false
end

-- Takes a layout definition (e.g. 'layouts.work') and iterates through
-- each application definition, laying it out as speccified
-- lg = hs.logger.new('mine', 'debug')
function runLayout(layout)
  for i = 1,#layout do
    local t = layout[i]
    lg:i("layout = ", t.name, " + ", t.app)
    local screen = nil
    local app = hs.application.find(t.appname)
    lg:i("app[1] = ", app)
    if app == nil then
      lg:i("opening ", t.app)
      hs.application.open(t.app)
    end
    local appWins = hs.application.find(t.appname):allWindows()
    lg:i("appWins = ", appWins)
    if appWins ~= nil then
      for k,win in pairs(appWins) do
        lg:i("moving win {} to unit {}", win, t.unit)
        win:move(t.unit)
        if t.screen ~= nil then
          lg:i("moving win {} to screen {}", win, t.screen)
          win:moveToScreen(getScreen(t.screen))
        end
      end
    end
  end
end

function swapZoomApp()
  local app = hs.application.find('zoom')
  if app ~= nil then
    local dell = getScreen("Dell")
    local lcd = getScreen("LCD")
    local wins = app:allWindows()
    for k,w in pairs(wins) do
      if w:screen():name() == dell:name() then
        w:moveToScreen(lcd)
      else
        w:moveToScreen(dell)
      end
    end
  end
end

-- All of the mappings for moving the window of the 'current' application
-- to the right spot. Tries to map 'vim' keys as much as possible, but
-- deviates to a 'visual' representation when that's not possible.
mash = { 'shift', 'ctrl', 'cmd' }
hs.hotkey.bind(mash, 'l', function() hs.window.focusedWindow():move(units.right30,    nil, true) end)
hs.hotkey.bind(mash, 'h', function() hs.window.focusedWindow():move(units.left70,     nil, true) end)
hs.hotkey.bind(mash, 'k', function() hs.window.focusedWindow():move(units.top50,      nil, true) end)
hs.hotkey.bind(mash, 'j', function() hs.window.focusedWindow():move(units.bot50,      nil, true) end)
hs.hotkey.bind(mash, ']', function() hs.window.focusedWindow():move(units.upright30,  nil, true) end)
hs.hotkey.bind(mash, '[', function() hs.window.focusedWindow():move(units.upleft70,   nil, true) end)
hs.hotkey.bind(mash, ';', function() hs.window.focusedWindow():move(units.botleft70,  nil, true) end)
hs.hotkey.bind(mash, "'", function() hs.window.focusedWindow():move(units.botright30, nil, true) end)
hs.hotkey.bind(mash, 'm', function() hs.window.focusedWindow():move(units.maximum,    nil, true) end)
hs.hotkey.bind(mash, 'i', function() hs.window.focusedWindow():move(units.middletall, nil, true) end)
hs.hotkey.bind(mash, 'c', function() hs.window.focusedWindow():move(units.center,     nil, true) end)

hs.hotkey.bind(mash, '0', function() runLayout(layouts.work) end)
hs.hotkey.bind(mash, '9', function() runLayout(layouts.alternatework) end)
hs.hotkey.bind(mash, '1', function() hs.window.focusedWindow():moveToScreen(getScreen("LCD")) end)
hs.hotkey.bind(mash, '2', function() hs.window.focusedWindow():moveToScreen(getScreen("Dell")) end)
hs.hotkey.bind(mash, 'z', function() swapZoomApp() end)

-------------------------------------------------------------------
-- Key Remapper
--
-- Doesn't work.
-------------------------------------------------------------------

-- local function pressFn(mods, key)
-- 	if key == nil then
-- 		key = mods
-- 		mods = {}
-- 	end
-- 
-- 	return function() hs.eventtap.keyStroke(mods, key, 1000) end
-- end
-- 
-- local function remap(mods, key, pressFn)
-- 	hs.hotkey.bind(mods, key, pressFn, nil, pressFn)	
-- end

-------------------------------------------------------------------
-- Deep Work
--
-- Some functions that will disable notifications for a specified
-- number of minutes, setting a timer that will enable them once
-- it completes
-------------------------------------------------------------------

deepWorkTimer = nil
deepAvoidanceApps = {
  { name = "Microsoft Outlook", app = "Microsoft Outlook.app" },
  { name = "Slack", app = "Slack.app" },
  { name = "Signal", app = "Signal.app" }
}

function enableDoNotDisturb()
  local dt = os.date("!%Y-%m-%d %H:%M:%S +000")
  local output, status, typ, rc = hs.execute("defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean true")
  if rc == 0 then
    local output, status, typ, rc = hs.execute("defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturbDate -date '" .. dt .. "'")
    if rc == 0 then
      local output, status, typ, rc = hs.execute("killall NotificationCenter")
      return output, status, typ, rc
    else
      return output, status, typ, rc
    end
  else
    return output, status, typ, rc
  end
end

function disableDoNotDisturb()
  local output, status, typ, rc = hs.execute("defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean false")
  if rc == 0 then
    local output, status, typ, rc = hs.execute("killall NotificationCenter")
    return output, status, typ, rc
  else
    return output, status, typ, rc
  end
end

function displayAlertDialog(msg)
  -- local screen = hs.screen.mainScreen():currentMode()
  -- local width = screen["w"]
  hs.dialog.blockAlert("Deep Work Alert", msg)
end

function resumeNotifications()
  if deepWorkTimer ~= nil and deepWorkTimer:running() then
    deepWorkTimer:stop()
  end
  deepWorkTimer = nil
  local output, status, typ, rc = disableDoNotDisturb()
  if rc ~= 0 then
    displayAlertDialog("Failed to start notifications: " .. output)
  end
end

function openDeepAvoidanceApps()
  for i = 1,#deepAvoidanceApps do
    local app = hs.application.open(deepAvoidanceApps[i].app)
  end
  runLayout(layouts.work)
end

function killDeepAvoidanceApps()
  for i = 1,#deepAvoidanceApps do
    local app = hs.application.get(deepAvoidanceApps[i].name)
    if app ~= nil then
      app:kill()
    end
  end
end

function stopNotifcations(minutes)
  local output, status, typ, rc = enableDoNotDisturb()
  if rc ~= 0 then
    displayAlertDialog("Failed to stop notifications: " .. output)
  else
    deepWorkTimer = hs.timer.doAfter(minutes * 60, function()
      hs.dialog.blockAlert("Deep Work", "Time to be interrupted.")
      resumeNotifications()
      openDeepAvoidanceApps()
      return 0
    end)
  end
end

function interrogateDeepWorkTimer()
  if deepWorkTimer == nil then
    displayAlertDialog("Deep Work timer isn't running")
  else
    local secs = math.floor(deepWorkTimer:nextTrigger() % 60)
    local mins = math.floor(deepWorkTimer:nextTrigger() / 60)
    displayAlertDialog(string.format("%02d:%02d left for deep work", mins, secs))
  end
end

function deepwork()
  local code, mins = hs.dialog.textPrompt("How many minutes for deep work?", "", "90", "OK", "Cancel")
  if code == "OK" then
    resumeNotifications()
    local minNumber = tonumber(mins)
    if minNumber == nil then
      displayAlertDialog(string.format("'%s' is not a valid number of minutes", mins))
    else
      stopNotifcations(minNumber)
      killDeepAvoidanceApps()
    end
  end
end

-------------------------------------------------------------------
-- Launcher
--
-- This is the awesome. The other stuff is all cool, but this is the
-- thing I love the most because it reduces the amount of time I
-- spend with the mouse, and is far more deterministic than trying
-- to use cmd+tab.
--
-- The idea here is to have a MODE-BASED app launching and app
-- switching system. Traditional Mac philosophy (and Emacs :D)
-- would have us contort our hands into crazy combinations of keys
-- to manipulate the state of the machine, which is a serious pain
-- in the ass. Using Hammerspoon we can avoid that.
--
-- * ctrl+k gets us into "launch mode"
-- * In "launch mode" the keyboard changes so that each key can now
--   have a new meaning. For example, the 'v' key is now responsible
--   for either launching or switching to VimR
-- * You can then map whatever you like to whatever function you'd
--   like to invoke.
--
-- It's just a big pile of awesome.
-------------------------------------------------------------------

-- We need to store the reference to the alert window
appLauncherAlertWindow = nil

-- This is the key mode handle
launchMode = hs.hotkey.modal.new({}, nil, '')

-- Leaves the launch mode, returning the keyboard to its normal
-- state, and closes the alert window, if it's showing
function leaveMode()
  if appLauncherAlertWindow ~= nil then
    hs.alert.closeSpecific(appLauncherAlertWindow, 0)
    appLauncherAlertWindow = nil
  end
  launchMode:exit()
end

function toggleApp(app, bundleId)
  instance = hs.application.find(bundleId)
  if instance ~= nil then
    if instance:isHidden() then
      instance:unhide()
      instance:setFrontmost()
    elseif not instance:isFrontmost() then
      instance:setFrontmost()
    else
      instance:hide()
    end
  else
    hs.application.open(app)
  end
  leaveMode()
end

-- So simple, so awesome.
function switchToApp(app)
  hs.application.open(app)
  leaveMode()
end

function visibleWindowsTo(dir)
  local wins = nil
  if dir == "east" then
    wins = hs.window.focusedWindow():windowsToEast()
  elseif dir == "west" then
    wins = hs.window.focusedWindow():windowsToWest()
  elseif dir == "north" then
    wins = hs.window.focusedWindow():windowsToNorth()
  elseif dir == "south" then
    wins = hs.window.focusedWindow():windowsToSouth()
  end
  local result = {}
  if wins ~= nil then
    for k,w in pairs(wins) do
      if w:isVisible() then
        lg:i(w, " is visible")
        result[#result+1] = w
      end
    end
  end

  return result
end

function focusWindow(wins)
  if wins ~= nil then
    local ordered = hs.window.orderedWindows()
    for i,w in pairs(ordered) do
      lg:i("1: ", w)
      for j,w2 in pairs(wins) do
        lg:i("2: ", w2)
        if w == w2 then
          w:focus()
          leaveMode()
          return
        end
      end
    end
  end
  leaveMode()
end

-- Enters launch mode. The bulk of this is geared toward
-- showing a big ugly window that can't be ignored; the
-- keyboard is now in launch mode.
function hotkeyFunc()
  launchMode:enter()
  appLauncherAlertWindow = hs.alert.show('App Launcher Mode', {
    strokeColor = hs.drawing.color.x11.orangered,
    fillColor = hs.drawing.color.x11.cyan,
    textColor = hs.drawing.color.x11.black,
    strokeWidth = 20,
    radius = 30,
    textSize = 128,
    fadeInDuration = 0,
    atScreenEdge = 2
  }, 'infinite')
end
hs.hotkey.bind({ 'ctrl' }, 'k', hotkeyFunc)
hs.hotkey.bind({ 'ctrl' }, 'space', hotkeyFunc)

-- When in launch mode, hitting ctrl+space again leaves it
launchMode:bind({ 'ctrl' }, 'k', function() leaveMode() end)
launchMode:bind({ 'ctrl' }, 'space', function() leaveMode() end)

launchMode:bind({ 'ctrl' }, 'l',  function() focusWindow(visibleWindowsTo("east")) end)
launchMode:bind({ 'ctrl' }, 'j',  function() focusWindow(visibleWindowsTo("south")) end)
launchMode:bind({ 'ctrl' }, 'k',  function() focusWindow(visibleWindowsTo("north")) end)
launchMode:bind({ 'ctrl' }, 'h',  function() focusWindow(visibleWindowsTo("west")) end)

-- Mapped keys
launchMode:bind({}, 'a',  function() switchToApp('IntelliJ IDEA.app') end)
launchMode:bind({}, 'c',  function() switchToApp('Google Chrome.app') end)
launchMode:bind({}, 'd',  function() leaveMode(); deepwork() end)
launchMode:bind({"shift"}, 'd',  function() leaveMode(); interrogateDeepWorkTimer() end)
launchMode:bind({}, 'f',  function() switchToApp('Google Chrome.app') end)
launchMode:bind({}, 'g',  function() switchToApp('OmniGraffle.app') end)
launchMode:bind({"ctrl"}, 'i',  function() toggleApp('Signal.app', 'org.whispersystems.signal-desktop') end)
launchMode:bind({}, 'k',  function() switchToApp('Skim.app') end)
launchMode:bind({}, 'l',  function() switchToApp('VLC.app') end)
launchMode:bind({}, 'n',  function() switchToApp('Microsoft OneNote.app') end)
launchMode:bind({}, 'o',  function() switchToApp('Microsoft Outlook.app') end)
launchMode:bind({}, 'p',  function() switchToApp('Microsoft Powerpoint.app') end)
launchMode:bind({}, 'q',  function() switchToApp('Markoff.app') end)
launchMode:bind({}, 'r',  function() switchToApp('Safari') end)
launchMode:bind({"ctrl"}, 's',  function() toggleApp('Slack.app', 'com.tinyspeck.slackmacgap') end)
launchMode:bind({}, 't',  function() switchToApp('iTerm.app') end)
launchMode:bind({}, 'v',  function() switchToApp('VimR.app') end)
launchMode:bind({"shift"}, 'v', function() switchToApp('iTerm.app'); switchToApp('VimR.app') end)
-- launchMode:bind({}, 'v',  function() switchToApp('MacVim.app') end)
launchMode:bind({"ctrl"}, 'y',  function() toggleApp('Spotify.app', 'com.spotify.client') end)
launchMode:bind({}, 'z',  function() switchToApp('zoom.us.app') end)
launchMode:bind({}, '`',  function() hs.reload(); leaveMode() end)

-- Unmapped keys

launchMode:bind({}, 'b',  function() end)


launchMode:bind({}, 'd',  function() end)
launchMode:bind({}, 'e',  function() end)


launchMode:bind({}, 'h',  function() end)
launchMode:bind({}, 'i',  function() end)

launchMode:bind({}, 'j',  function() end)


launchMode:bind({}, 'm',  function() end)





launchMode:bind({}, 's',  function() end)

launchMode:bind({}, 'u',  function() end)

launchMode:bind({}, 'w',  function() end)
launchMode:bind({}, 'x',  function() end)
launchMode:bind({}, 'y',  function() end)

launchMode:bind({}, '1',  function() end)
launchMode:bind({}, '2',  function() end)
launchMode:bind({}, '3',  function() end)
launchMode:bind({}, '4',  function() end)
launchMode:bind({}, '5',  function() end)
launchMode:bind({}, '6',  function() end)
launchMode:bind({}, '7',  function() end)
launchMode:bind({}, '8',  function() end)
launchMode:bind({}, '9',  function() end)
launchMode:bind({}, '0',  function() end)
launchMode:bind({}, '-',  function() end)
launchMode:bind({}, '=',  function() end)
launchMode:bind({}, '[',  function() end)
launchMode:bind({}, ']',  function() end)
launchMode:bind({}, '\\', function() end)
launchMode:bind({}, ';',  function() end)
launchMode:bind({}, "'",  function() end)
launchMode:bind({}, ',',  function() end)
launchMode:bind({}, '.',  function() end)
launchMode:bind({}, '/',  function() end)

