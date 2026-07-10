module("kmap", package.seeall)
setfenv(1, getfenv(2))

kmap = kmap or {}

kinstall:require('kmap/mapper')
kinstall:require('kmap/speedwalk')

mudlet.mapper_script = true

kmap.mapperBox = kmap.mapperBox or {}
kmap.messageBox = kmap.messageBox or {}
kmap.immoMap = kmap.immoMap or false
kmap.editMap = kmap.editMap or false
kmap.hideGroup = kmap.hideGroup or false
kmap.ids = kmap.ids or {}
kmap.vnumToRoomIdCache = {}

-- widok mapy: 'native' (natywny mapper Mudleta, domyslny - potrzebny do
-- przeciagania/przestawiania panelu, prawoklik-Info/immo/edycji) albo
-- 'tile' (kafelki sektorow, patrz +map view)
kmap.viewMode = kmap.viewMode or 'native'
kmap.tileIconDir = getMudletHomeDir() .. '/kmap/img/icons/'
kmap.tileSize = 56
kmap.tileGap = 2
kmap.tileLegendHeight = 40
kmap.tileMaxCols = 9
kmap.tileMaxRows = 7

function kmap:doMap()
  if setMapWindowTitle('WYŁĄCZ OKNO MAPPERA I UŻYJ KOMENDY +map') == true then
    cecho('\n<red>!!! Masz, lub miałeś, włączone okno mapy. Niestety, musisz upewnić się że jest wyłączone i zrestartować Mudleta !!!\n')
    cecho('\n<dim_gray>Skrypty killera rysują własne okno mapy jako panel. Jeżeli przed instalacją skryptów używałeś okna Mapy, Mudlet nadal trzyma je w pamięci. Zamknij mapę jeśli jest otwarta. Ponowne uruchomienie Mudleta usunie ją z pamięci i skrypty będą mogły się poprawnie uruchomić.\n\n')
    cecho('\nNie używaj już przycisku "Map" mudleta, od tej pory mapę włącza się komendą <gray>+map<dim_gray>\na wyłącza komendą <gray>-map\n\n')
    return
  end

  local param = kinstall.params[1]
  if param == 'reload' then
    kmap:mapLoad(true)
    return
  end
  if param == 'check' then
    kmapper:mapCheck()
    return
  end
  if param == 'redraw' then
    kmap:mapRedraw(true)
    return
  end
  if param == 'load' then
    kmapper:mapLoad()
    return
  end
  if param == 'save' then
    kmapper:mapSave()
    return
  end
  if param == 'info' then
    kmapper:mapInfo(false)
    return
  end
  if param == 'zoom' then
    kmapper:mapZoom(kinstall.params[2])
    return
  end
  if param == 'refresh' then
    kmapper:mapRefresh()
    return
  end
  if param == 'start' then
    if kinstall:getConfig('editMap') ~= 'y' then cecho('<red>Nie włączyłeś funkcji edytora\n\n') return end
    kmapper:mapStart()
    return
  end
  if param == 'stop' then
    if kinstall:getConfig('editMap') ~= 'y' then cecho('<red>Nie włączyłeś funkcji edytora\n\n') return end
    kmapper:mapStop()
    return
  end
  if param == 'area' then
    if kinstall:getConfig('editMap') ~= 'y' then cecho('<red>Nie włączyłeś funkcji edytora\n\n') return end
    kmapper:mapArea(kinstall.params[2])
    return
  end
  if param == 'step' then
    if kinstall:getConfig('editMap') ~= 'y' then cecho('<red>Nie włączyłeś funkcji edytora\n\n') return end
    kmapper:mapStep(kinstall.params[2])
    return
  end
  if param == 'symbol' then
    if kinstall:getConfig('editMap') ~= 'y' then cecho('<red>Nie włączyłeś funkcji edytora\n\n') return end
    kmapper:mapSymbol(kinstall.params[2])
    return
  end
  if param == 'forget' then
    if kinstall:getConfig('editMap') ~= 'y' then cecho('<red>Nie włączyłeś funkcji edytora\n\n') return end
    kmapper:mapForget(false)
    return
  end
  if param == 'special' then
    if kinstall:getConfig('editMap') ~= 'y' then cecho('<red>Nie włączyłeś funkcji edytora\n\n') return end
    kmapper:mapSpecial(kinstall.params[2], kinstall.params[3])
    return
  end
  if param == 'export' then
    if kinstall:getConfig('editMap') ~= 'y' then cecho('<red>Nie włączyłeś funkcji edytora\n\n') return end
    kmapper:exportArea(getRoomArea(getPlayerRoom()))
    return
  end
  if param == 'import' then
    if kinstall:getConfig('editMap') ~= 'y' then cecho('<red>Nie włączyłeś funkcji edytora\n\n') return end
    kmapper:importArea()
    return
  end
  if param == 'label' then
    if kinstall:getConfig('editMap') ~= 'y' then cecho('<red>Nie włączyłeś funkcji edytora\n\n') return end
    local text = ''
    for k,v in pairs(kinstall.params) do
      if k ~= 1 then text = text .. ' ' .. kinstall.params[k] end
    end
    kmapper:mapLabel(string.trim(text))
    return
  end

  if param == 'immo' then
    kmap.immoMap = kinstall:getConfig('immoMap')
    if kmap.immoMap == 'y' then
      cecho('<gold>Wyłączono tryb immo mapy.\n\n')
      kinstall:setConfig('immoMap', 'n')
      kmap.immoMap = 'n'
      kmap:unsetImmoMap()
    else
      cecho('<gold>Włączono tryb immo mapy.\n\n')
      kinstall:setConfig('immoMap', 'y')
      kmap.immoMap = 'y'
      kmap:setImmoMap()
    end
    return
  end

  if param == 'edit' then
    kmap.editMap = kinstall:getConfig('editMap')
    if kmap.editMap == 'y' then
      cecho('<gold>Wyłączono tryb edycji mapy.\n\n')
      kmap.editMap = 'n'
      kinstall:setConfig('editMap', 'n')
      kmap:unsetEditMap()
      else
      cecho('<gold>Włączono tryb edycji mapy.\n\n')
      kmap.editMap = 'y'
      kinstall:setConfig('editMap', 'y')
      kmap:setEditMap()
    end
    return
  end
  if param == 'backup' then
    kmapper:mapBackup()
    return
  end

  if param == 'group' then
    kmap.hideGroup = kinstall:getConfig('mapHideGroup')
    if kmap.hideGroup == 'y' then
      cecho('<gold>Włączono wyświetlanie grupy na mapie.\n\n')
      kinstall:setConfig('mapHideGroup', 'n')
      kmap.hideGroup = 'n'
    else
      cecho('<gold>Wyłączono wyświetlanie grupy na mapie.\n\n')
      kinstall:setConfig('mapHideGroup', 'y')
      kmap.hideGroup = 'y'
    end
    return
  end

  if param == 'restore' then
    kmapper:mapRestore(kinstall.params[2])
    return
  end
  if param == 'view' then
    if kmap.viewMode == 'native' then
      kmap.viewMode = 'tile'
      cecho('<gold>Mapa: widok kafelkowy. Sterowanie przyciskami w prawym gornym rogu panelu.\n\n')
    else
      kmap.viewMode = 'native'
      cecho('<gold>Mapa: widok natywny mudleta (prawoklik-Info, edycja, immo).\n\n')
    end
    kinstall:setConfig('mapViewMode', kmap.viewMode)
    kmap:switchView()
    return
  end
  if param ~= "silent" then
    cecho('<gold>Włączam mapę\n')
  end
  kmap:delayedmapLoad()
  kinstall:setConfig('mapa', 't')
end

function kmap:undoMap()
  local param = kinstall.params[1]
  if param ~= 'silent' then
    cecho('<gold>Wyłączam mapę\n')
  end
  kmap:removeBox()
  kinstall:setConfig('mapa', 'n')
end

function kmap:doWalk()
  local param = kinstall.params[1]
  kspeedwalk:walk(param)
end

function kmap:doStop()
  kspeedwalk:stop()
end

function kmap:doPoi()
  local param = kinstall.params[1]
  kspeedwalk:poiAdd(param)
end

function kmap:undoPoi()
  local param = kinstall.params[1]
  kspeedwalk:removePoi(param)
end

function kmap:doUninstall()
  kmap:undoMap()
  kmap:unregister()
end

function kmap:doInstall()
  if map ~= nil then
    map.eventHandler = function() end
  end
  if kinstall:getConfig('mapaInfo') ~= 't' then
    cecho('<green>gotowe.\n\n')
    cecho('<orange>=========================\n')
    cecho('<orange>==     PRZECZYTAJ!     ==\n')
    cecho('<orange>=========================\n\n')
    cecho('<orange>Od teraz mapę włącza się komendą <cyan>+map <orange>a wyłącza komendą <cyan>-map\n\n')
    cecho('<orange>Przycisk Map na pasku narzędzi mudleta <red>nie będzie działał<orange>.\n\n')
    cecho('<orange>Postaram się to zmienić w przyszłości, ale w tej chwili nie ma sposobu na przechwycenie faktu\n')
    cecho('<orange>kliknięcia w ten przycisk, być może za jakiś czas się to zmieni.\n\n')
    cecho('<orange>Dodatkowo, jesli od momentu ostatniego uruchomienia Mudleta, do zainstalowania\n')
    cecho('<orange>tych skryptów używałeś już przycisku "Map" na górze ekranu, musisz teraz ponownie\n')
    cecho('<orange>uruchomić Mudleta. Nic na to nie poradze - to bug w Mudlecie.\n')
    cecho('<orange>Po następnym odpaleniu Mudleta będzie już dobrze.\n\n')
    cecho('<orange>W przypadku problemów z załadowaniem się, lub działaniem mapy spróbuj wpisać\n')
    cecho('<orange><cyan>+map redraw <orange>(przerysowanie obrazków/etykiet) lub <cyan>+map reload <orange>(ponownie załadowanie mapy z dysku)\n\n')
    cecho('<orange>Zalecane ustawienia mapki:\n')
    cecho('<orange> - zmień cyfrę przy "Rooms" na 8\n')
    cecho('<orange> - kliknij poziomy pasek ze znaczkiem "^" żeby schować panel ustawień\n')
    cecho('<orange> - w ustawieniach Mudleta, zakładka Mapper, odznaczyć "Show room borders"\n\n')
  end
  kinstall:setConfig('mapaInfo', 't')
end

function kmap:doInit()
  kmap.viewMode = kinstall:getConfig('mapViewMode')
  if kmap.viewMode ~= 'tile' then kmap.viewMode = 'native' end
  kmap:register()
  if kinstall:getConfig('mapa') == 't' then
    kinstall.params[1] = 'silent'
    kmap:doMap()
  end
  kspeedwalk:init()
end

function kmap:doUpdate()
  kmap:charGroupEventHandler()
end

--
--
--


function kmap:register()
  kmap:unregister()
  kmap.ids.roomInfoEvent = registerAnonymousEventHandler("gmcp.Room.Info", "kmap:roomInfoEventHandler")
  kmap.ids.charGroupEvent = registerAnonymousEventHandler("gmcp.Char.Group", "kmap:charGroupEventHandler")
  kmap.ids.sysExitEvent = registerAnonymousEventHandler("sysExitEvent", "kmap:sysExitEvent")
  kmap.ids.receivingGmcpTimer = tempTimer(2, [[ kmap:checkGmcp() ]], true)
end

function kmap:unregister()
  if kmap.ids.roomInfoEvent then killAnonymousEventHandler(kmap.ids.roomInfoEvent) end
  if kmap.ids.charGroupEvent then killAnonymousEventHandler(kmap.ids.charGroupEvent) end
  if kmap.ids.sysExitEvent then killAnonymousEventHandler(kmap.ids.sysExitEvent) end
  if kmap.ids.receivingGmcpTimer then killTimer(kmap.ids.receivingGmcpTimer) end
end

function kmap:showHelp()
  cechoLink("<gold>Kliknij by otworzyć stronę z helpem.", [[openUrl("https://github.com/laszlowaty/MudletScripts#mapa")]], nil, true)
end

--
-- Wyswietla okienko mapy
--
function kmap:addBox()
  local wrapper = kgui:addBox('mapper', 300, "Mapa", "map")
  -- mapperBox tworzony jest od nowa przy kazdym otwarciu panelu, wiec wszystkie
  -- widgety-dzieci (natywny mapper, siatka kafli) musza tez zostac odtworzone
  -- pod nowym rodzicem - stale referencje do dzieci starego boxa powoduja
  -- "odklejanie sie" mapy od panelu przy przesuwaniu
  kmap.nativeMapper = nil
  kmap.tileContainer = nil
  kmap.tileHighlight = nil
  kmap.tilePool = {}
  kmap.tileConnectorPool = {}
  kmap.tileLegendIconPool = {}
  kmap.tileLegendTextPool = {}
  kmap.mapperBox = Geyser.Label:new({
    name = 'mapper',
    x = 2,
    y = (kgui.titleHeight + 2) .. "px",
    width = "100%-4px",
    height = "100%-" .. (kgui.titleHeight + 4) .. "px",
  }, wrapper)
  wrapper.windowList.mapperWrapperadjLabel:setStyleSheet([[
    QWidget {
      background: rgba(0,0,0,0);
    }
  ]])
  kmap.mapperBox:setStyleSheet(kgui:styleContent([[
      border: 1px solid ]] .. kgui.theme.border .. [[;
  ]]))

  kmap.messageBox = Geyser.Label:new({
    name = 'mapperMessage',
    width = "100%-4px",
    height = "40",
    x = "2px",
    y = "2px"
  }, kmap.mapperBox)
  kmap.messageBox:setStyleSheet([[
    background: rgba(17,20,28,0.85);
    color: ]] .. kgui.theme.textMain .. [[;
    font-size: ]] .. kgui:font(12) .. [[px;
    font-family: sans-serif;
    border-radius: ]] .. kgui.theme.radius .. [[px;
  ]])
  kmap.messageBox:enableClickthrough()
  kmap.messageBox:hide()

  kgui:update()
end

--
-- Dodaje mape do okienka
--
function kmap:addMapper()
  if kmap.nativeMapper == nil then
    kmap.nativeMapper = Geyser.Mapper:new({
      embedded = true,
      name = 'mapperElement',
      width = "100%-4px",
      height = "100%-4px",
      x = "2px",
      y = "2px"
    }, kmap.mapperBox)
    kmap.nativeMapper.container:lowerAll()
  else
    kmap.nativeMapper.container:show()
  end
  kgui:update()
end

function kmap:removeMapper()
  if kmap.nativeMapper ~= nil then
    kmap.nativeMapper.container:hide()
  end
end

--
-- Wlacza widok mapy zgodny z kmap.viewMode ('tile' albo 'native'),
-- chowajac ten drugi (nie niszczymy widgetow, tylko je chowamy/pokazujemy)
--
function kmap:addActiveView()
  if kmap.viewMode == 'native' then
    kmap:removeTileGrid()
    kmap:addMapper()
  else
    kmap:addTileGrid()
    kmap:removeMapper()
  end
end

--
-- Przelacza widok mapy w locie (komenda +map view)
--
function kmap:switchView()
  if kmap.mapperBox == nil then return end
  kmap:addActiveView()
  kmap:renderTileGrid(true)
end

--
-- Kafelkowy widok mapy: siatka ikon sektorow zamiast natywnego mappera Mudleta.
-- Nie zapewnia prawoklik-Info/immo/edycji/znacznikow grupy - do tego sluzy widok
-- natywny (+map view).
--
function kmap:addTileGrid()
  if kmap.tileContainer ~= nil then
    kmap.tileContainer:show()
    return
  end

  kmap.tileContainer = Geyser.Label:new({
    name = 'mapperTiles',
    x = '2px',
    y = '2px',
    width = '100%-4px',
    height = '100%-4px',
  }, kmap.mapperBox)
  kmap.tileContainer:setStyleSheet([[background: rgba(10,12,18,255);]])
  -- clickthrough: nie przechwytujemy myszy na calym kontenerze, zeby nie blokowac
  -- przeciagania/przestawiania panelu przez kgui (uzywa setMoveCallback na
  -- etykiecie wrappera) - sterowanie zoom/pan robimy malymi przyciskami w rogu
  kmap.tileContainer:enableClickthrough()

  kmap.tilePool = {}
  kmap.tileConnectorPool = {}
  kmap.tileLegendIconPool = {}
  kmap.tileLegendTextPool = {}
  kmap.tilePanCol = 0
  kmap.tilePanRow = 0
  kmap.tileLastPlayerRoom = nil

  kmap.tileHighlight = Geyser.Label:new({
    name = 'mapperPlayerHighlight',
    x = 0,
    y = 0,
    width = 10,
    height = 10,
  }, kmap.tileContainer)
  kmap.tileHighlight:setStyleSheet([[
    background: rgba(0,0,0,0);
    border: 3px solid #ff7a1a;
    border-radius: 4px;
  ]])
  kmap.tileHighlight:enableClickthrough()
  kmap.tileHighlight:hide()

  kmap:addTileControls()
end

--
-- Male przyciski zoom/pan w prawym gornym rogu widoku kafelkowego.
-- Celowo przyciski a nie drag/scroll na calym panelu - przechwytywanie myszy
-- na calej powierzchni psulo kgui-owe przeciaganie paneli (v61/v62)
--
function kmap:addTileControls()
  local buttons = {
    { txt = '◀', fn = function() kmap:tilePan(-1, 0) end },
    { txt = '▲', fn = function() kmap:tilePan(0, -1) end },
    { txt = '▼', fn = function() kmap:tilePan(0, 1) end },
    { txt = '▶', fn = function() kmap:tilePan(1, 0) end },
    { txt = '⌂', fn = function() kmap:tileRecenter() end },
    { txt = '−', fn = function() kmap:tileZoom(-1) end },
    { txt = '+', fn = function() kmap:tileZoom(1) end },
  }
  local size = 22
  kmap.tileControls = Geyser.Label:new({
    name = 'mapperTileControls',
    x = '100%-' .. (#buttons * size + 6) .. 'px',
    y = '4px',
    width = (#buttons * size) .. 'px',
    height = size .. 'px',
  }, kmap.tileContainer)
  kmap.tileControls:setStyleSheet([[background: rgba(17,20,28,0.75); border-radius: 4px;]])
  for i, def in ipairs(buttons) do
    local btn = Geyser.Label:new({
      name = 'mapperTileBtn' .. i,
      x = (i - 1) * size,
      y = 0,
      width = size,
      height = size,
    }, kmap.tileControls)
    btn:setStyleSheet([[
      background: rgba(0,0,0,0);
      color: ]] .. kgui.theme.textMain .. [[;
      font-size: 14px;
      qproperty-alignment: AlignCenter;
    ]])
    btn:echo('<center>' .. def.txt .. '</center>')
    btn:setClickCallback(def.fn)
  end
end

function kmap:tilePan(dcol, drow)
  kmap.tilePanCol = (kmap.tilePanCol or 0) + dcol
  kmap.tilePanRow = (kmap.tilePanRow or 0) + drow
  kmap:renderTileGrid(true)
end

function kmap:tileRecenter()
  kmap.tilePanCol = 0
  kmap.tilePanRow = 0
  kmap:renderTileGrid(true)
end

function kmap:tileZoom(direction)
  local newSize = kmap.tileSize + direction * 8
  if newSize < 32 then newSize = 32 end
  if newSize > 96 then newSize = 96 end
  kmap.tileSize = newSize
  kmap:renderTileGrid(true)
end

function kmap:removeTileGrid()
  if kmap.tileContainer ~= nil then
    kmap.tileContainer:hide()
  end
end

function kmap:getTile(index)
  local tile = kmap.tilePool[index]
  if tile == nil then
    tile = Geyser.Label:new({ name = 'mapperTile' .. index, x = 0, y = 0, width = 10, height = 10 }, kmap.tileContainer)
    tile:enableClickthrough()
    kmap.tilePool[index] = tile
  end
  return tile
end

function kmap:getConnector(index)
  local connector = kmap.tileConnectorPool[index]
  if connector == nil then
    connector = Geyser.Label:new({ name = 'mapperConnector' .. index, x = 0, y = 0, width = 2, height = 2 }, kmap.tileContainer)
    connector:enableClickthrough()
    connector:setStyleSheet([[background: rgba(158,122,77,255);]])
    kmap.tileConnectorPool[index] = connector
  end
  return connector
end

function kmap:getLegendIcon(index)
  local icon = kmap.tileLegendIconPool[index]
  if icon == nil then
    icon = Geyser.Label:new({ name = 'mapperLegendIcon' .. index, x = 0, y = 0, width = 10, height = 10 }, kmap.tileContainer)
    icon:enableClickthrough()
    kmap.tileLegendIconPool[index] = icon
  end
  return icon
end

function kmap:getLegendText(index)
  local text = kmap.tileLegendTextPool[index]
  if text == nil then
    text = Geyser.Label:new({ name = 'mapperLegendText' .. index, x = 0, y = 0, width = 10, height = 10 }, kmap.tileContainer)
    text:enableClickthrough()
    kmap.tileLegendTextPool[index] = text
  end
  return text
end

--
-- Przelicza i rysuje siatke kafli wokol gracza + legende widocznych sektorow.
-- forceLayout wymusza przerysowanie nawet gdy gracz sie nie ruszyl (np. po resize).
--
function kmap:renderTileGrid(forceLayout)
  if kmap.viewMode ~= 'tile' or kmap.tileContainer == nil then return end

  local playerRoom = getPlayerRoom()
  if playerRoom == nil or not roomExists(playerRoom) then
    for _, tile in pairs(kmap.tilePool) do tile:hide() end
    for _, connector in pairs(kmap.tileConnectorPool) do connector:hide() end
    kmap.tileHighlight:hide()
    return
  end

  -- gdy gracz faktycznie zmienil pokoj (a nie np. tylko przerysowanie po
  -- resize/pan/zoom), wracamy z przesunietym widokiem do wycentrowania na nim
  if playerRoom ~= kmap.tileLastPlayerRoom then
    kmap.tilePanCol = 0
    kmap.tilePanRow = 0
    kmap.tileLastPlayerRoom = playerRoom
  end

  local areaId = getRoomArea(playerRoom)
  local px, py, pz = getRoomCoordinates(playerRoom)
  local step = kmapper.step or 2
  if step == 0 then step = 1 end

  -- srodek siatki = pokoj gracza + przesuniecie z przyciskow pan
  local panCol = kmap.tilePanCol or 0
  local panRow = kmap.tilePanRow or 0
  local centerX = px + panCol * step
  local centerY = py - panRow * step

  local boxWidth = kmap.tileContainer:get_width() or 400
  local boxHeight = kmap.tileContainer:get_height() or 300

  local tileSize = kmap.tileSize
  local cols = math.min(kmap.tileMaxCols, math.max(1, math.floor(boxWidth / tileSize)))
  local rows = math.min(kmap.tileMaxRows, math.max(1, math.floor((boxHeight - kmap.tileLegendHeight) / tileSize)))

  local gridWidth = cols * tileSize
  local gridHeight = rows * tileSize
  local offsetX = math.floor((boxWidth - gridWidth) / 2)
  local offsetY = math.floor((boxHeight - kmap.tileLegendHeight - gridHeight) / 2)

  local halfCols = math.floor((cols - 1) / 2)
  local halfRows = math.floor((rows - 1) / 2)

  local roomAtCell = {}
  local visibleSectors = {}
  local tileIndex = 0
  local playerVisible = false

  for row = 0, rows - 1 do
    for col = 0, cols - 1 do
      tileIndex = tileIndex + 1
      local dcol = col - halfCols
      local drow = row - halfRows
      local x = centerX + dcol * step
      local y = centerY - drow * step

      local roomId = nil
      local rooms = getRoomsByPosition(areaId, x, y, pz)
      if rooms ~= nil and table.size(rooms) > 0 then
        roomId = next(rooms)
      end

      local tile = kmap:getTile(tileIndex)
      tile:move(offsetX + col * tileSize, offsetY + row * tileSize)
      tile:resize(tileSize - kmap.tileGap, tileSize - kmap.tileGap)

      if roomId ~= nil then
        roomAtCell[dcol .. ':' .. drow] = { id = roomId, x = x, y = y }
        -- sector z userdata, a gdy go brak (pokoje z mapa.json bez userdata)
        -- wyprowadzamy ikone i nazwe z env pokoju ustawionego przez colourRoom
        local env = getRoomEnv(roomId)
        local sector = getRoomUserData(roomId, 'sector')
        if sector == nil or sector == '' then
          sector = kmapper.envToSector[env] or 'nieznany'
        end
        local iconFile = kmapper.sectorToIcon[sector] or kmapper.envToIcon[env] or kmapper.sectorToIconDefault
        visibleSectors[sector] = iconFile
        tile:setStyleSheet([[
          background: rgba(0,0,0,0);
          border-image: url("]] .. kmap.tileIconDir .. iconFile .. [[.png") 0 0 0 0 stretch stretch;
        ]])
        tile:show()
      else
        tile:hide()
      end

      -- znacznik gracza: komorka pokoju gracza po uwzglednieniu przesuniecia pan
      if dcol == -panCol and drow == -panRow then
        kmap.tileHighlight:move(offsetX + col * tileSize, offsetY + row * tileSize)
        kmap.tileHighlight:resize(tileSize - kmap.tileGap, tileSize - kmap.tileGap)
        kmap.tileHighlight:show()
        playerVisible = true
      end
    end
  end

  if not playerVisible then
    kmap.tileHighlight:hide()
  end

  for i = tileIndex + 1, table.size(kmap.tilePool) do
    if kmap.tilePool[i] ~= nil then kmap.tilePool[i]:hide() end
  end

  -- laczniki (drogi) miedzy sasiednimi zajetymi komorkami, tylko wschod/poludnie
  -- zeby nie rysowac kazdego polaczenia podwojnie
  local connectorIndex = 0
  for key, room in pairs(roomAtCell) do
    local dcol, drow = string.match(key, '(-?%d+):(-?%d+)')
    dcol, drow = tonumber(dcol), tonumber(drow)
    local exits = getRoomExits(room.id) or {}

    local eastNeighbor = roomAtCell[(dcol + 1) .. ':' .. drow]
    if eastNeighbor ~= nil and exits['east'] == eastNeighbor.id then
      connectorIndex = connectorIndex + 1
      local connector = kmap:getConnector(connectorIndex)
      local col = dcol + halfCols
      local row = drow + halfRows
      connector:move(offsetX + (col + 1) * tileSize - kmap.tileGap, offsetY + row * tileSize + math.floor(tileSize / 2) - 1)
      connector:resize(kmap.tileGap * 2, 3)
      connector:show()
    end

    local southNeighbor = roomAtCell[dcol .. ':' .. (drow + 1)]
    if southNeighbor ~= nil and exits['south'] == southNeighbor.id then
      connectorIndex = connectorIndex + 1
      local connector = kmap:getConnector(connectorIndex)
      local col = dcol + halfCols
      local row = drow + halfRows
      connector:move(offsetX + col * tileSize + math.floor(tileSize / 2) - 1, offsetY + (row + 1) * tileSize - kmap.tileGap)
      connector:resize(3, kmap.tileGap * 2)
      connector:show()
    end
  end
  for i = connectorIndex + 1, table.size(kmap.tileConnectorPool) do
    if kmap.tileConnectorPool[i] ~= nil then kmap.tileConnectorPool[i]:hide() end
  end

  kmap:renderTileLegend(visibleSectors, offsetY + gridHeight, boxWidth)

  -- kafle i laczniki tworzone sa leniwie juz PO utworzeniu znacznika gracza
  -- i przyciskow, wiec bez podniesienia przykrywalyby je (z-order wg kolejnosci
  -- tworzenia)
  kmap.tileHighlight:raiseAll()
  if kmap.tileControls ~= nil then kmap.tileControls:raiseAll() end
end

--
-- Pasek legendy na dole panelu, budowany dynamicznie z sektorow widocznych w danej chwili
--
function kmap:renderTileLegend(visibleSectors, y, boxWidth)
  local items = {}
  for sector, iconFile in pairs(visibleSectors) do
    table.insert(items, { sector = sector, icon = iconFile })
  end
  table.sort(items, function(a, b) return a.sector < b.sector end)

  local maxItems = 14
  while #items > maxItems do
    table.remove(items)
  end

  if #items == 0 then
    for _, icon in pairs(kmap.tileLegendIconPool) do icon:hide() end
    for _, text in pairs(kmap.tileLegendTextPool) do text:hide() end
    return
  end

  local itemWidth = math.max(30, math.floor(boxWidth / #items))
  local iconSize = math.min(kmap.tileLegendHeight - 16, itemWidth - 6)

  for i, entry in ipairs(items) do
    local icon = kmap:getLegendIcon(i)
    icon:move((i - 1) * itemWidth + math.floor((itemWidth - iconSize) / 2), y)
    icon:resize(iconSize, iconSize)
    icon:setStyleSheet([[
      background: rgba(0,0,0,0);
      border-image: url("]] .. kmap.tileIconDir .. entry.icon .. [[.png") 0 0 0 0 stretch stretch;
    ]])
    icon:show()

    local text = kmap:getLegendText(i)
    text:move((i - 1) * itemWidth, y + iconSize)
    text:resize(itemWidth, kmap.tileLegendHeight - iconSize)
    text:setStyleSheet([[
      background: rgba(0,0,0,0);
      color: ]] .. kgui.theme.textMain .. [[;
      font-size: ]] .. kgui:font(8) .. [[px;
      qproperty-alignment: AlignHCenter;
    ]])
    text:rawEcho('<center>' .. entry.sector .. '</center>')
    text:show()
  end

  for i = #items + 1, table.size(kmap.tileLegendIconPool) do
    if kmap.tileLegendIconPool[i] ~= nil then kmap.tileLegendIconPool[i]:hide() end
    if kmap.tileLegendTextPool[i] ~= nil then kmap.tileLegendTextPool[i]:hide() end
  end
end

--
-- Usuwa okienko mapy
--
function kmap:removeBox()
  closeMapWidget()
  kmap:removeTileGrid()
  kmap:removeMapper()
  kgui:removeBox('mapper')
  kgui:update()
end

--
-- Centruje mape tylko jesli gracz juz nie stoi na danym roomie
--
function kmap:centerView(roomId)
  if getPlayerRoom() ~= roomId then
    centerview(roomId)
  end
end

--
-- Buduje cache roomów
--
function kmap:vnumCacheRebuild()
  kmap.vnumToRoomIdCache = {}
  for id,name in pairs(getRooms()) do
    local vnum = getRoomUserData(id, "vnum")
    if vnum ~= "" then
      if kmap.vnumToRoomIdCache[tonumber(vnum)] ~= nil then
        cecho('<red>UWAGA! Masz na mapie dwa roomy o takim samym vnumie! Room A: ' .. id .. ' Room B: ' .. kmap.vnumToRoomIdCache[tonumber(vnum)] .. '.\nRoom o wyższym roomId został zignowany i mapa nie będzie to niego skakała.\n')
      else
        kmap.vnumToRoomIdCache[tonumber(vnum)] = id
      end
    end
  end
end

--
-- Odnajdywanie lokacji na mapie
--
function kmap:mapLocate()
  if gmcp.Room == nil then
    return
  end
  local cachedRoomId = kmap.vnumToRoomIdCache[gmcp.Room.Info.num]
  if cachedRoomId ~= nil and not roomExists(cachedRoomId) then
    kmap:vnumCacheRebuild()
    kmap:mapLocate()
  end
  if cachedRoomId ~= nil and roomExists(cachedRoomId) then
    local roomId = kmap.vnumToRoomIdCache[gmcp.Room.Info.num]
    kmap:centerView(roomId)
    return roomId
  else
    if kinstall.receivingGmcp == false then
      centerview(18914)
    end
  end
  return nil
end

-- kasowanie labelek obrazkowych
function kmap:deleteImageLabels()
  for _, areaId in pairs(getAreaTable()) do
    local labels = getMapLabels(areaId)
    if type(labels) ~= 'table' then
      labels = {}
    end
    for id, text in pairs(labels) do
      if id ~= -1 and ( text == "" or text == "no text" or text == "brak tekstu") then
        deleteMapLabel(areaId, id)
      end
    end
  end
end

--
-- Map redraw
--
function kmap:mapRedraw(forceReload)
  if forceReload or kmap.labelsMap == nil then
    local f = assert(io.open(getMudletHomeDir() .. '/kmap/img/labelmap.json', "r"))
    local labelsFile = f:read("*all")
    f:close()
    kmap.labelsMap = yajl.to_value(labelsFile)
  end

  --czy trzeba przerysowac
  local shouldRepaint = 0
  local imageHashes = {}
  local totalLabelsFromJsonCount = 0
  for _, labels in pairs(kmap.labelsMap) do
    for _, label in pairs(labels) do
      imageHashes[string.format("%.3f", label.Width) .. string.format("%.3f", label.Height)] = label
      totalLabelsFromJsonCount = totalLabelsFromJsonCount + 1
    end
  end
  local usedLabelsFromJsonCount = 0
  for areaId in pairs(kmap.labelsMap) do
    local areaLabels = getMapLabels(areaId)
    if areaLabels == nil or type(areaLabels) ~= 'table' then areaLabels = {} end
    for id, txt in pairs(areaLabels) do
      if id ~= -1 and (txt == "" or txt == "no text" or txt == "brak tekstu") then
        local existing = getMapLabel(areaId, id)
        local label = imageHashes[string.format("%.3f", existing.Width) .. string.format("%.3f", existing.Height)]
        if label ~= nil then
          usedLabelsFromJsonCount = usedLabelsFromJsonCount + 1
        end
        if label == nil or label.X ~= existing.X or label.Y ~= existing.Y then
          shouldRepaint = 1
        end
      end
    end
  end

  if totalLabelsFromJsonCount ~= usedLabelsFromJsonCount then
    shouldRepaint = 1
  end

  if shouldRepaint == 0 then
    return
  end
 
  cecho('<gold>Przerysowuje obrazki na mapie\n')
  kmap:deleteImageLabels()

  -- rysowanie ich od nowa
  for areaId, labels in pairs(kmap.labelsMap) do
    for _, label in pairs(labels) do
      createMapImageLabel(
        areaId,
        getMudletHomeDir() .. '/kmap/img/' .. label.File .. '.png',
        label.X,
        label.Y,
        0,
        label.Width,
        label.Height,
        50,
        false,
        true -- set label as temporary
      )
    end
  end
end

--
-- nasluchiwanie komunikatow gmcp.Room.Info
--
function kmap:roomInfoEventHandler()
  -- przeniesione do group event, poniewaz nastepuje on nieco pozniej, i chcemy uniknac podwojnego odswiezania mappera
end
--
-- nasluchiwanie komunikatow gmcp.Char.Group
--
function kmap:charGroupEventHandler()
  if kmap.mapperBox ~= nil
  and kgui.ui.mapper ~= nil
  and kgui.ui.mapper.wrapper ~= nil
  and kgui.ui.mapper.wrapper.hidden ~= true then
    kmap:drawGroup()
    if kmapper.mapping ~= true then
      kmap:mapLocate()
    end
    kmap:renderTileGrid()
  end
  kspeedwalk:step()
end

--
-- Infobox mapy
--
function kmap:addInfoBox()
  disableMapInfo("Short")
  disableMapInfo("Full")
  disableMapInfo("Killer")
  killMapInfo("Killer")
  registerMapInfo("Killer", function (roomId, selectionSize)
    if selectionSize < 2 then
      local nazwa = ""
      if selectionSize == 1 then
        nazwa = "(zaznaczenie)"
      end
      if selectionSize == 0 then
        roomId = getPlayerRoom()
      end
      if roomId == nil or roomId == 0 or roomId == "" then
        return "";
      end
      nazwa = nazwa .. " " .. getRoomName(roomId)
      local dane = {}
      local vnum = getRoomUserData(roomId, "vnum")
      if vnum ~= nil and vnum ~= "" then
        table.insert(dane, vnum)
      end
      local sector = getRoomUserData(roomId, "sector")
      if sector ~= nil and sector ~= "" then
        table.insert(dane, sector)
      end
      if table.size(dane) > 0 then
        return nazwa .. " [" .. table.concat(dane, ", ") .. "]", true, false, 240, 240, 240
      end
      return nazwa, true, false, 240, 240, 240;
    end
    return ""
  end)
  enableMapInfo("Killer")
end

--
-- załadowanie mapy
--
function kmap:mapLoad(forceReload)
  kmap:addActiveView()
  local mapVersion = tonumber(getMapUserData("version") or 0)
  local moduleFile = kinstall:getModuleDotJsonFile("kmap")
  local moduleVersion = moduleFile.version
  if forceReload or mapVersion ~= moduleVersion then
    cecho('<gold>Ładuje mapę z dysku\n')
    loadJsonMap(getMudletHomeDir() .. '/kmap/mapa.json')
    setMapUserData("version", tostring(moduleVersion))
    setMapUserData("type", "killermud")
  end
  kmap:vnumCacheRebuild()
  if gmcp.Room == nil then
    centerview(18914)
  end
  kmap:mapLocate()
  kmap:mapRedraw(false)
  kmap:removeGroup()
  kmap.editMap = kinstall:getConfig('editMap')
  if kmap.editMap == 'y' then
    kmap:setEditMap()
  else
    kmap:unsetEditMap()
  end
  kmap.immoMap = kinstall:getConfig('immoMap')
  if kmap.immoMap == 'y' then
    kmap:setImmoMap()
  else
    kmap:unsetImmoMap()
  end
  updateMap()
  kmap:addInfoBox()
end

function kmap:delayedmapLoad()
  maptype = getMapUserData("type");
  if maptype ~= nil and maptype ==  "killermud" then
    kmap:deleteImageLabels()
  end
  closeMapWidget()
  kmap:addBox()
  tempTimer(0, function()
    kmap:mapLoad(false)
  end)
end

--
-- usuwanie obrazkow przed zapisaniem mapy
--
function kmap:sysExitEvent()
  cecho('<gold>Czyszczenie mapy przed zapisem...')
  kmap:deleteImageLabels()
end

--
-- Usuwanie grupki z mapy
--
function kmap:removeGroup()
    -- usuwanie znaczkow grupy z mapy
    for _, areaId in pairs(getAreaTable()) do
      local labels = getMapLabels(areaId)
      if labels ~= nil and type(labels) == "table" then
        for id, text in pairs(getMapLabels(areaId)) do
          -- !!! w tych cudzyslowiach jest znak niewidocznej spacji !!!
          if text:starts("​") then
            deleteMapLabel(areaId, id)
          end
        end
      end
    end
end

--
-- Rysowanie grupki na mapie
--
function kmap:drawGroup()
  kmap:removeGroup()

  if kmap.hideGroup == "y" then
    return
  end

  if gmcp.Room == nil or gmcp.Room.Info == nil then return end

  -- sprawdzamy czy mamy informacje o lokalizacji
  if gmcp.Room.Info[1] ~= nil and gmcp.Room.Info[1].unavailable ~= nil then
    kmap.messageBox:show()
    kmap.messageBox:rawEcho('<center>' .. kgui:transliterate(gmcp.Room.Info[1].unavailable) .. '</center>')
    return
  end

  -- sprawdzamy czy mamy informacje o grupie
  local group = gmcp.Char.Group
  if group[1] ~= nil and group[1].unavailable ~= nil then
    kmap.messageBox:show()
    kmap.messageBox:rawEcho('<center>' .. kgui:transliterate(group[1].unavailable) .. '</center>')
    return
  end

  if group.members == nil and kgui.ui.info == nil then
    return
  end

  if #group.members == 1 then
    return
  end

  kmap.messageBox:hide()

  local symbolMode = "num"
  if kgui:isClosed('group') then symbolMode = "short" end
  if kmap.immoMap == "y" then symbolMode = "name" end

  local playerSymbols = { "①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨", "⑩", "⑪", "⑫", "⑬", "⑭", "⑮", "⑯", "⑰", "⑱", "⑲", "②"}

  -- rysowanie playerow z kolkami zamiast charmow
  local members = {}
  local lastPlayerId = nil
  local playerId = 1
  local mobId = 1
  for _, player in ipairs(group.members) do
    if player.is_npc and lastPlayerId ~= nil and members[lastPlayerId] ~= nil then
      if members[lastPlayerId] ~= nil and members[lastPlayerId].room == player.room then
        members[lastPlayerId].name = members[lastPlayerId].name .. '°'
      else
        members["m" .. mobId] = {
          ["name"] = "©",
          ["room"] = player.room,
        }
      end
      mobId = mobId + 1
    else
      members[playerId] = {
        ["name"] = player.name,
        ["room"] = player.room,
      }
      lastPlayerId = playerId
      if symbolMode == "num" then
        members[lastPlayerId].name = playerSymbols[playerId]
      end
      if symbolMode == "short" then
        members[lastPlayerId].name = utf8.sub(members[lastPlayerId].name, 1, 3)
      end
      playerId = playerId + 1
    end
  end

  -- grupowanie ludzi wedlug lokalizacji
  local labelForRoom = {}
  local labelCharCountForRoom = {}
  for _, player in pairs(members) do
    local roomLabel = labelForRoom[player.room]
    local playerChar = player.name
    if symbolMode ~= "num" then
      playerChar = kgui:transliterate(player.name) .. '\n'
    end
    -- !!! w tych cudzyslowiach jest znak niewidocznej spacji !!!
    if roomLabel == nil then roomLabel = "​" end
    labelForRoom[player.room] = roomLabel .. playerChar
    if labelCharCountForRoom[player.room] == nil then labelCharCountForRoom[player.room] = 0 end
    labelCharCountForRoom[player.room] = labelCharCountForRoom[player.room] + 1
    if symbolMode == "num" and labelCharCountForRoom[player.room] % 3 == 0 then
      labelForRoom[player.room] = labelForRoom[player.room] .. '\n'
    end
  end

  for room, label in pairs(labelForRoom) do
    local roomId = kmap.vnumToRoomIdCache[room]
    if roomId ~= nil then
      local fontW, fontH = calcFontSize(20, "Marcellus")
      local deltaX = fontW * 3 / 20  / 2
      if symbolMode == "num" then
        local symbolCount = labelCharCountForRoom[room]
        if symbolCount > 3 then symbolCount = 3 end
        deltaX = fontW * symbolCount / 20
      end
      local roomX, roomY, roomZ = getRoomCoordinates(roomId)
      createMapLabel(
        getRoomArea(roomId),
        label,
        roomX - deltaX,
        roomY + 1,
        roomZ,
        240,
        240,
        240,
        0,
        0,
        0,
        30,
        14,
        true,
        true,
        'Marcellus',
        255,
        50,
        true -- set label as temporary
      )
    end
  end

  --kmap.lastGmcpInfo = yajl.to_string(gmcp.Char.Group)
end

function kmap:checkGmcp()
  if kmap == nil or kmap.messageBox == nil or kmap.messageBox.show == nil then return end
  if kinstall.receivingGmcp == false and not (kgui.ui ~= nil and kgui.ui.info ~= nil and kgui.ui.info.wrapper.hidden == false ) then
    kmap.messageBox:show()
    kmap.messageBox:rawEcho('<center>Zaloguj się do gry lub włącz GMCPs</center>')
  end
end

--
-- dodatki dla immo na mapie
--
function kmap:setImmoMap()
  addMapEvent('🚀 Skocz tutaj', 'mapJumpTo')
  if kmap.ids.onKMapJumpTo then killAnonymousEventHandler(kmap.ids.onKMapJumpTo) end
  kmap.ids.onKMapJumpTo = registerAnonymousEventHandler("mapJumpTo", function() kmap:jumpTo() end)
end

function kmap:unsetImmoMap()
  if kmap.ids.onKMapJumpTo then killAnonymousEventHandler(kmap.ids.onKMapJumpTo) end
  removeMapEvent('🚀 Skocz tutaj')
end

--
-- dodatki dla edytorow na mapie
--
function kmap:setEditMap()
  addMapEvent('🔍 Info', 'mapInfo')
  addMapEvent('🗑 Wyczyść dane', 'mapForget')
  if kmap.ids.onKMapForget then killAnonymousEventHandler(kmap.ids.onKMapForget) end
  kmap.ids.onKMapForget = registerAnonymousEventHandler("mapForget", function() kmapper:mapForget(true) end)
  if kmap.ids.onKMapInfo then killAnonymousEventHandler(kmap.ids.onKMapInfo) end
  kmap.ids.onKMapInfo = registerAnonymousEventHandler("mapInfo", function() kmapper:mapInfo(true) end)
end

function kmap:unsetEditMap()
  if kmap.ids.onKMapForget then killAnonymousEventHandler(kmap.ids.onKMapForget) end
  if kmap.ids.onKMapInfo then killAnonymousEventHandler(kmap.ids.onKMapInfo) end
  removeMapEvent("🔍 Info")
  removeMapEvent("🗑 Wyczyść dane")
end

--
-- Skakanie po mapie
--
function kmap:jumpTo()
  local selectedRooms = getMapSelection()["rooms"]
  if selectedRooms == nil or #selectedRooms == 0 then
    cecho('\n<red>Najpierw zaznacz room na mapie!\n')
    return
  end
  local roomId = selectedRooms[1]
  local vnum = getRoomUserData(roomId, "vnum")
  send('goto ' .. vnum .. '\n')
  kmap:centerView(roomId)
end

--
-- Podpinamy się pod Mudletowego speedwalka
--

function doSpeedWalk()
  if kmap.immoMap == "y" then
    local roomId = speedWalkPath[#speedWalkPath]
    if roomId == nil or roomId == 0 or roomId == "" then
      kspeedwalk:start()
      return
    end
    local vnum = getRoomUserData(roomId, "vnum")
    if roomId == nil or roomId == 0 or roomId == "" then
      kspeedwalk:start()
      return
    end
    send('goto ' .. vnum)
    return
  end
  kspeedwalk:start()
end