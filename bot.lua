local token = "292558405:AAFwjY4VoNRVUz0HmOmXKSpu7wdJajgrF7o"
local URL = require "socket.url"
local https = require "ssl.https"
local serpent = require "serpent"
local url = 'https://api.telegram.org/bot' .. token
local offset = 0
local redis = require('redis')
local redis = redis.connect('127.0.0.1', 6379)
local json  = dofile("json.lua")
local ch = "Zekrshomarrobot"
------------------------------------------------------------------------------
function GetMe()
urlk = url .. '/GetMe'
surl = https.request(urlk)
jdat = json:decode(surl)
return jdat
end

------------------------------------------------------------------------------

local bot = GetMe().result
local fn = bot.first_name
local id = bot.id
local un = bot.username
print("#-FirstName >>> "..fn.." \n" .. "#-ID >>> "..id.." \n" .. "#-UserName >>> @"..un)
------------------------------------------------------------------------------
local function getUpdates()
  local response = {}
  local success, code, headers, status  = https.request{
    url = url .. '/getUpdates?timeout=20&limit=1&offset=' .. offset,
    method = "POST",
    sink = ltn12.sink.table(response),
  }
local body = table.concat(response or {"no response"})
  if (success == 1) then
    return json:decode(body)
  else
    return nil, "Request Error"
  end
end

------------------------------------------------------------------------------

function vardump(value)
  print(serpent.block(value, {comment=false}))
end

------------------------------------------------------------------------------

function SendKeyboard(chat, text, parse_mode, keyboard)
urlk = url .. '/sendMessage?chat_id=' ..chat.. '&text='..URL.escape(text)..'&parse_mode=' ..URL.escape(parse_mode).. '&reply_markup='..URL.escape(json:encode(keyboard))
https.request(urlk)
end

------------------------------------------------------------------------------

function EditMessage(chat_id, msg_id, text, parse_mode, keyboard)
  local urlk = url .. '/editMessageText?chat_id=' .. chat_id .. '&message_id='.. msg_id .. '&text=' .. URL.escape(text) .. '&parse_mode=' .. URL.escape(parse_mode)
    urlk = urlk .. '&parse_mode=Markdown'
  if keyboard then
    urlk = urlk..'&reply_markup='..URL.escape(json:encode(keyboard)).. '&parse_mode=' .. URL.escape(parse_mode)
  end
    return https.request(urlk)
end

------------------------------------------------------------------------------

function sleep(n) 
os.execute("sleep " .. tonumber(n)) 
end

------------------------------------------------------------------------------

local function run()
 while true do
 local updates = getUpdates()
 --vardump(updates)
  if(updates) then
   if (updates.result) then
    for i=1, #updates.result do
    local msg = updates.result[i]
    offset = msg.update_id + 1
-------------------------------------------------------------------------------

-- #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --
          if msg.message then
            msg = msg.message
           end
-- #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --
          if msg.text then 
           local text_ = msg.text:gsub("^[#/!]",'')
           if text_:lower():match("^start$") then
            local s = json:decode(https.request(url .. "/getchatmember?chat_id=@" .. ch .. "&user_id=" .. msg.from.id)).result.status
           if s == "creator" or s == "administrator" or s == "member" then
            local kb = {}
            kb.inline_keyboard = {
                        {{text="ذکر بفرست 📿", callback_data="zekr:1"}},
                        {{text="کانال ما 📣", url="https://t.me/" .. ch}}
                                  }
           SendKeyboard(msg.chat.id, "سلام دوست عزیز\nبه ربات ذکر شمار خوش امدید", "markdown", kb)
           else
		   local jb = {}
           jb.inline_keyboard = {
		                         {
		   {text="📣", url="https://telegram.me/" ..ch}
		                         }
		                        }
           SendKeyboard(msg.chat.id, "برای استفاده از ربات باید عضو کانال باشید\nبا استفاده از دکمه زیر در کانال عضو شوید", "Markdown", jb)
          end
		  end
		  end
          if msg.callback_query then
           q = msg.callback_query
           n = q.data:match("(%d+)")
		   text = "تا حالا " .. n .. " ذکر گفتی"
		   local s = json:decode(https.request(url .. "/getchatmember?chat_id=@" .. ch .. "&user_id=" .. q.from.id)).result.status
           if s == "creator" or s == "administrator" or s == "member" then
           if q.data:match("^zekr") then
            local kb = {}
            kb.inline_keyboard = {
                                 {{text="ذکر بفرست 📿", callback_data="zekr:" .. n+1}},
                                 {{text="اشتباه شد 📿", callback_data="uzekr:" .. n-1}}
                                 }
               EditMessage(q.message.chat.id, q.message.message_id, text, "markdown", kb)
            end
           if q.data:match("^uzekr") then
            if tonumber(n) > 0 then
            local kb = {}
            kb.inline_keyboard = {
                                 {{text="ذکر بفرست 📿", callback_data="zekr:" .. n+1}},
                                 {{text="اشتباه شد 📿", callback_data="uzekr:" .. n-1}}
                                 }
               EditMessage(q.message.chat.id, q.message.message_id, text, "markdown", kb)
             else
            kb = {}
            kb.inline_keyboard = {
                                 {{text="ذکر بفرست 📿", callback_data="zekr:" .. n+1}},
                                  }
            EditMessage(q.message.chat.id, q.message.message_id, text, "Markdown", kb)
            end
            end
			else
					   local jb = {}
           jb.inline_keyboard = {
		                         {
		   {text="📣", url="https://telegram.me/" ..ch}
		                         }
		                        }
          EditMessage(q.message.chat.id, q.message.message_id, "برای استفاده از ربات باید عضو کانال باشید\nبا استفاده از دکمه زیر در کانال عضو شوید", "Markdown", jb)
			end
          end
-- #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --
-- #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --
-------------------------------------------------------------------------------
    end
   end
  end
 end
end

return run()
