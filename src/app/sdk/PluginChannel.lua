PluginChannel = {}
local cjson = cjson.new()
local NoticeManager = require("app.ui.noticeSystem.NoticeManager")
local scheduler = require("app.common.scheduler")  
local user_plugin = nil    --获取用户插件
local iap_plugin_maps = nil --支付插件
local agent = nil
--登陆监听函数
function PluginChannel:onUserResult( plugin, code, msg )
    print("on user action listener.")
    print("code:"..code..",msg:"..msg)
    if code == UserActionResultCode.kInitSuccess then
        -- GameEventCenter:dispatchEvent({ name = GameEventCenter.GAME_ANYSDK_INIT_FINISH })
        local customParam = self:getCustomParam()
        if customParam.showToolBar ~= nil and tonumber(customParam.showToolBar) == 1 then
            self:showToolBar() 
        end
        local channelId = self:getChannelId()
        if channelId == "000255" then 
            self:login()
        end
    elseif code == UserActionResultCode.kInitFail then
        PromptManager:openTipPrompt("sdk初始化失败！")
    elseif code == UserActionResultCode.kLoginSuccess then
        local customParam = self:getCustomParam()
        NoticeManager:debugDisplay(customParam.debug, msg, function()
            Functions.setLoginInf(msg,function(event)
                NativeUtil:sdkLogin()
                if customParam.showToolBar ~= nil and tonumber(customParam.showToolBar) == 2 then
                    self:showToolBar()
                end
            end)
        end)
    elseif code == UserActionResultCode.kLoginNetworkError then
       if GameCtlManager.currentController_t.class.__cname ~= "StartupSceneViewController" then
            GameCtlManager:goTo("app.ui.startupSceneSystem.StartupSceneViewController")
       end
    elseif code == UserActionResultCode.kLoginNoNeed then

    elseif code == UserActionResultCode.kLoginFail then
       if GameCtlManager.currentController_t.class.__cname ~= "StartupSceneViewController" then
            GameCtlManager:goTo("app.ui.startupSceneSystem.StartupSceneViewController")
       end
    elseif code == UserActionResultCode.kLoginCancel then
       if GameCtlManager.currentController_t.class.__cname ~= "StartupSceneViewController" then
            GameCtlManager:goTo("app.ui.startupSceneSystem.StartupSceneViewController")
       end
    elseif code == UserActionResultCode.kLogoutSuccess then
       Player:logout(true)
       self:login()
    elseif code == UserActionResultCode.kLogoutFail then
       PromptManager:openTipPrompt("注销失败")
    elseif code == UserActionResultCode.kPlatformEnter then
       PromptManager:openTipPrompt("进入平台")
    elseif code == UserActionResultCode.kPlatformBack then
        --do
    elseif code == UserActionResultCode.kPausePage then
        --do
    elseif code == UserActionResultCode.kExitPage then
        Functions.callAnySdkFuc(function()
            Analytics:stopSession()
            self:submitLoginGameRole("4")
            local scheduler = require("app.common.scheduler")  
            scheduler.performWithDelayGlobal(function ( )
                cc.Director:getInstance():endToLua() 
            end, 0.2)
        end)
    elseif code == UserActionResultCode.kAntiAddictionQuery then
        --do
    elseif code == UserActionResultCode.kRealNameRegister then

    elseif code == UserActionResultCode.kAccountSwitchSuccess then
        
    elseif code == UserActionResultCode.kAccountSwitchFail then
        PromptManager:openTipPrompt("账户切换失败！")
    elseif code == UserActionResultCode.kOpenShop then
        --do
    end
end
--支付监听函数
function PluginChannel:onPayResult( code, msg, info )
    print("on iap result listener.")
    print("code:"..code..",msg:"..msg)
    -- NoticeManager:openTips(GameCtlManager.currentController_t, {title = "iap-code:"..code..",msg:"..msg ,type = 5}) 
    PromptManager:closeHttpLinkPrompt() 
    local customParam = self:getCustomParam()
    if code == PayResultCode.kPaySuccess then
        -- NoticeManager:openTips(GameCtlManager.currentController_t, {title = LanguageConfig.language_0_48 ,type = 5,isShowNpc = "npc/NPC_lb_gold.png"}) 
        Analytics:onChargeSuccess()
    elseif code == PayResultCode.kPayFail then
        PromptManager:openTipPrompt("支付失败！")
        Analytics:onChargeFail()
    elseif code == PayResultCode.kPayCancel then
        NoticeManager:debugDisplay(customParam.debug, tostring(self:getOrderId()), function()
            PromptManager:openTipPrompt(LanguageConfig.language_9_79)
        end)
    elseif code == PayResultCode.kPayNetworkError then
        PromptManager:openTipPrompt("网络错误,请重试！")
    elseif code == PayResultCode.kPayProductionInforIncomplete then

    elseif code == PayResultCode.kPayInitSuccess then

    elseif code == PayResultCode.kPayInitFail then
        --do
    elseif code == PayResultCode.kPayNowPaying then

    elseif code == PayResultCode.kPayRechargeSuccess then

    end
end
function PluginChannel:init()
    --for anysdk
    --init
    --anysdk //c++层初始化
    --注意：这里appKey, appSecret, privateKey，要替换成自己打包工具里面的值(登录打包工具，游戏管理界面上显示的那三个参数)。
    local appKey = "6D7E6FC3-4DDD-E5EF-B131-B60D14A30B81"
    local appSecret = "5ed642ca101399889cba0ce2e4b486d7"
    local privateKey = "6C6B80BE7AD41F784E0624D87897707A"
    local oauthLoginServer = "http://hjby.tanyu.mobi:8085/sanguoGM/sanguoGMSomeFunc2/AnySdkVeriServ"
    agent = AgentManager:getInstance()
    --init
    agent:init(appKey,appSecret,privateKey,oauthLoginServer)
    --load
    agent:loadAllPlugins()

    -- get user plugin
    user_plugin = agent:getUserPlugin()
    if user_plugin ~= nil then
        user_plugin:setActionListener(handler(self,self.onUserResult))
    end

    iap_plugin_maps = agent:getIAPPlugin()
    for key, value in pairs(iap_plugin_maps) do
        print("key:" .. key)
        print("value: " .. type(value))
        value:setResultListener(handler(self,self.onPayResult))
    end
    agent:setIsAnaylticsEnabled(true)
end
function PluginChannel:login()
    if user_plugin ~= nil then
        user_plugin:setActionListener(handler(self,self.onUserResult))
        user_plugin:login()
    end
end

function PluginChannel:exit()
    local user_plugin = agent:getUserPlugin();
    if nil ~= user_plugin and user_plugin:isFunctionSupported("exit") then
        user_plugin:callFuncWithParam("exit");
    end
end
function PluginChannel:getCustomParam()
    local customParam = agent:getCustomParam()
    local msgTable = json.decode(customParam)
    -- if msgTable.debug then 
    --     PromptManager:openTipPrompt("true")
    -- else
    --     PromptManager:openTipPrompt("false")
    -- end
    return msgTable
end
function PluginChannel:getChannelId()
    return agent:getChannelId()
end
function PluginChannel:getChannelName()
    local customParam = self:getCustomParam()
    return customParam.channelName or "test"
end
function PluginChannel:logout()
    if user_plugin ~= nil then
        if user_plugin:isFunctionSupported("logout") then
            user_plugin:callFuncWithParam("logout")
        end
    end
end

function PluginChannel:enterPlatform()
    if user_plugin ~= nil then
        if user_plugin:isFunctionSupported("enterPlatform") then
            user_plugin:callFuncWithParam("enterPlatform")
        end
    end
end

function PluginChannel:showToolBar()
    if user_plugin ~= nil then
        if user_plugin:isFunctionSupported("showToolBar") then
            local param1 = PluginParam:create(ToolBarPlace.kToolBarTopLeft)
            user_plugin:callFuncWithParam("showToolBar", param1)
        end
    end
end

function PluginChannel:hideToolBar()
    if user_plugin ~= nil then
        if user_plugin:isFunctionSupported("hideToolBar") then
            user_plugin:callFuncWithParam("hideToolBar")
        end
    end
end

function PluginChannel:accountSwitch()
    if user_plugin ~= nil then
        if user_plugin:isFunctionSupported("accountSwitch") then
            user_plugin:callFuncWithParam("accountSwitch")
        end
    end
end

function PluginChannel:realNameRegister()
    if user_plugin ~= nil then
        if user_plugin:isFunctionSupported("realNameRegister") then
            user_plugin:callFuncWithParam("realNameRegister")
        end
    end
end

function PluginChannel:antiAddictionQuery()
    if user_plugin ~= nil then
        if user_plugin:isFunctionSupported("antiAddictionQuery") then
            user_plugin:callFuncWithParam("antiAddictionQuery")
        end
    end
end

function PluginChannel:submitLoginGameRole(dataType)
    if user_plugin ~= nil then
        if user_plugin:isFunctionSupported("submitLoginGameRole") then

            local roleLevelTime = ""
            local gongHuiId = ""
            if dataType == "1" or dataType == "2" then
                roleLevelTime = "-1"
            else
                roleLevelTime = tostring(TimerManager:getCurrentSecond())
            end
            if PlayerData.eventAttr.m_tongID ~= 0 then 
                gongHuiId = tostring(PlayerData.eventAttr.m_tongID)
            end
            local data = PluginParam:create({roleId=tostring(PlayerData.eventAttr.m_uid),
                roleName=PlayerData.eventAttr.m_name,roleLevel=tostring(PlayerData.eventAttr.m_level),
                zoneId=tostring(NetWork.serverId),zoneName=NetWork.serverName,dataType=dataType,vipLevel = tostring(VipData.eventAttr.m_vipLevel),
                roleCTime = GameState.userCreateTime,roleLevelMTime = roleLevelTime,
                balance = tostring(PlayerData.eventAttr.m_gold),partyName = gongHuiId })
            user_plugin:callFuncWithParam("submitLoginGameRole", data)
        end
    end
end

function PluginChannel:getProductName(index)
    local channelId = self:getChannelId()
    if g_channelConfig[channelId] ~= nil then 
        for k,v in pairs(g_channelConfig[channelId]["productName"]) do
            if v == index then 
                return k
            end
        end
    end
end
function PluginChannel:getProductId(index)
    local channelId = self:getChannelId()
    if g_channelConfig[channelId] ~= nil then 
        for k,v in pairs(g_channelConfig[channelId]["productCode"]) do
            if v == index then 
                return k
            end
        end
    end
end
function PluginChannel:pay(index,data)
    if iap_plugin_maps ~= nil then
        local customParam = self:getCustomParam()
        local money = 0
        if customParam.debug == "2" then 
            money = 0.01
            index = 9
        else
            money = data.money
        end
        local info = {
                Product_Price = data.money, 
                Product_Id = self:getProductId(index) or "10000",  
                Product_Name = self:getProductName(index) or "10000",  
                Server_Id = NetWork.serverId,  
                Product_Count = "1",    
                Role_Id = tostring(PlayerData.eventAttr.m_uid),  
                Role_Name = tostring(PlayerData.eventAttr.m_name)
            }
        -- analytics_plugin:logEvent("pay", info)
      
        for key, value in pairs(iap_plugin_maps) do
            print("key:" .. key)
            print("value: " .. type(value))
            value:payForProduct(info)
            scheduler.performWithDelayGlobal(function ( )
               Analytics:onChargeRequest(index,data)
            end, 1)
            scheduler.performWithDelayGlobal(function ( )
               ProtocolIAP:resetPayState()
            end, 3)
        end
    end
end
function PluginChannel:getOrderId()
    if iap_plugin_maps ~= nil then
        for key, value in pairs(iap_plugin_maps) do
            local order_id = value:getOrderId()
            return order_id
        end
    end
end
return PluginChannel