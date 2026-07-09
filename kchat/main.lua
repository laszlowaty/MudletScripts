module("kchat", package.seeall)
setfenv(1, getfenv(2))

kchat = kchat or {}
kchat.enabled = false
kchat.colors = kchat.colors or {}
kchat.silent = kchat.silent or 'n'
kchat.boxHeight = kchat.boxHeight or 200
kchat.box = kchat.box or nil
kchat.history = kchat.history or {}
kchat.historyMax = 500

function kchat:doChat()
  local param = kinstall.params[1]
  if param ~= "silent" then
    cecho('<gold>Włączam panel czatu\n')
  end
  if param == 'quiet' then
    kchat.silent = kinstall:getConfig('chatSilent')
    if kchat.silent == 'y' then
      cecho('<gold>Włączono powiadamianie o nowych wiadomościach.\n\n')
      kinstall:setConfig('chatSilent', 'n')
      kchat.silent = 'n'
    else
      cecho('<gold>Wyłączono powiadamianie o nowych wiadomościach.\n\n')
      kinstall:setConfig('chatSilent', 'y')
      kchat.silent = 'y'
    end
    return
  end
  kinstall:setConfig('chat', 't')
  kchat.enabled = true
  kchat:register()
  kchat:addBox()
end

function kchat:undoChat()
  local param = kinstall.params[1]
  if param ~= 'silent' then
    cecho('<gold>Wyłączam panel czatu\n')
  end
  kchat:removeBox()
  kinstall:setConfig('chat', 'n')
  kchat.enabled = false
end

function kchat:doUninstall()
  kchat:unregister()
end

function kchat:doInit()
  local colors = kinstall:getConfig('kchatColors')
  if colors == nil or colors == "" or colors == false then colors = "{}" end
  kchat.colors = yajl.to_value(colors)
  if kinstall:getConfig('chat') == 't' then
    kchat:register()
    kchat:doChat()
  end
end

function kchat:doUpdate()
  kchat:render()
end

function kchat:register()
  kchat:unregister()
  kchat.chatTrigger = tempRegexTrigger("^((\\w+) (m[oó]wi|nuci|dudni|grzmi|piszczy|warczy|miauczy|szczeka|ryczy|syczy|[sś]piewa|zawodzi|wydaje d[zź]wi[ęe]k|pieje|skrzeczy).*'(.+)'|(\\w+) (pyta|nuci|dudni|piszczy|warczy|miauczy|szczeka|ryczy|syczy|[sś]piewa|pieje|skrzeczy).*'(.+)'|()(M[oó]wisz|Nucisz|Dudnisz|Grzmisz|Piszczysz|Warczysz|Miauczysz|Szczekasz|Ryczysz|Syczysz|[ŚS]piewasz|Zawodzisz|Wydajesz d[zź]wi[eę]k|Piejesz|[ŚS]piewasz).*'(.+)'|()Pytasz.*'(.+)'|()Wykrzykujesz.*'(.+)'|()Krzyczysz '(.+)'|()Wrzeszczysz '(.+)'|(\\w+) wrzeszczy '(.+)'|(\\w+) krzyczy.*'(.+)'|(\\w+) wykrzykuje.*'(.+)'|\\[(\\w+)\\]:\\s(.+))$", kchat.chatTriggerHandler)
end

function kchat:unregister()
  if kchat.chatTrigger then killTrigger(kchat.chatTrigger) end
end

--
-- Wyswietla okienko chatu. Tresc renderowana jest tym samym stylem co
-- reszta widgetow (kgui:styleContent), ale okienko NIE jest rejestrowane
-- jako kgui.ui['chat']['content'] - dzieki temu kgui:updateWrapperSize nie
-- nadpisuje co update wysokosci wrappera i mozna go swobodnie rozciagac.
--
function kchat:addBox()
  local wrapper = kgui:addBox('chat', kchat.boxHeight, "Czat", "chat")
  kchat.box = kchat.box or Geyser.Label:new({
    name = "chat",
    x = 2,
    y = (kgui.titleHeight + 2) .. "px",
    width = "100%-4px",
    height = "100%-" .. (kgui.titleHeight + 4) .. "px",
  }, wrapper)
  -- AlignBottom: najnowsze wiadomosci trzymaja sie dolu panelu jak w
  -- normalnym czacie (nowa wiadomosc wypycha starsze do gory)
  kchat.box:setStyleSheet(kgui:styleContent("qproperty-alignment: AlignBottom;"))
  kchat.box:enableClickthrough()
  kchat.box:raiseAll()
  kchat.box:show()
  kchat:render()
end

--
-- Usuwa okienko chatu
--
function kchat:removeBox()
  kgui:removeBox('chat')
  kgui:update()
end

--
-- Wylicza ile ostatnich wiadomosci zmiesci sie w okienku i wyswietla je
--
function kchat:render()
  if kchat.box == nil then return end
  local lineHeight = kgui.baseFontHeightPx or 16
  local boxHeight = kchat.box:get_height() or kchat.boxHeight
  -- zostawiamy maly margines bezpieczenstwa, zeby ostatnia wiadomosc nie byla przycieta
  local maxLines = math.floor(boxHeight / lineHeight) - 1
  if maxLines < 1 then maxLines = 1 end

  -- szacujemy ile znakow miesci sie w jednej linii, zeby policzyc ile linii
  -- faktycznie zajmie zawijana wiadomosc (a nie zakladac 1 wiadomosc = 1 linia)
  local charsPerLine = 40
  local charWidth = calcFontSize(kgui.baseFontHeight)
  local boxWidth = kchat.box:get_width()
  if charWidth ~= nil and charWidth > 0 and boxWidth ~= nil and boxWidth > 0 then
    charsPerLine = math.max(10, math.floor(boxWidth / charWidth) - 1)
  end

  local lines = {}
  local usedLines = 0
  for i = #kchat.history, 1, -1 do
    local msg = kchat.history[i]
    local plainLen = #(string.gsub(msg, "<[^>]+>", ""))
    local msgLines = math.max(1, math.ceil(plainLen / charsPerLine))
    if usedLines + msgLines > maxLines and #lines > 0 then
      break
    end
    table.insert(lines, 1, msg)
    usedLines = usedLines + msgLines
  end
  kchat.box:rawEcho(formatText(table.concat(lines, '<br>')))
end

--
-- Dodaje wiadomości z czatu do okienka
--
function kchat:chatTriggerHandler()
  if kchat.enabled == false then
    return
  end

  if kchat.silent ~= 'y' and not hasFocus() then
    alert(5)
  end

  selectCurrentLine()
  local formattedText = copy2html()
  -- usuwamy wypalone tlo pojedynczych znakow (kopiowane z glownego okna),
  -- zeby dziedziczyly tlo panelu czatu zamiast wlasnego czarnego tla
  formattedText = string.gsub(formattedText, "background%-color:%s*[^;\"]+;?", "")
  formattedText = string.gsub(formattedText, "background:%s*[^;\"]+;?", "")

  table.insert(kchat.history, formattedText)
  while #kchat.history > kchat.historyMax do
    table.remove(kchat.history, 1)
  end

  kchat:render()
  kgui:update()
end
