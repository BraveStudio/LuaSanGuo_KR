--@auto code head
local BaseViewController = require("app.baseMVC.BaseViewController")
local AstoreLoginViewController = class("AstoreLoginViewController", BaseViewController)

local Functions = require("app.common.Functions")

AstoreLoginViewController.debug = true
AstoreLoginViewController.modulePath = ...
AstoreLoginViewController.studioSpriteFrames = {"NaverLoginUI","CB_loginBg" }
--@auto code head end

--@Pre loading
AstoreLoginViewController.spriteFrameNames = 
    {
    }

AstoreLoginViewController.animaNames = 
    {
    }


--@auto code uiInit
--add spriteFrames
if #AstoreLoginViewController.studioSpriteFrames > 0 then
    AstoreLoginViewController.spriteFrameNames = AstoreLoginViewController.spriteFrameNames or {}
    table.insertto(AstoreLoginViewController.spriteFrameNames, AstoreLoginViewController.studioSpriteFrames)
end
function AstoreLoginViewController:onDidLoadView()

    --output list
    self._npc_t = self.view_t.csbNode:getChildByName("main"):getChildByName("npc")
	
    --label list
    
    --button list
    self._astoreLoginBt_t = self.view_t.csbNode:getChildByName("main"):getChildByName("loginPanle"):getChildByName("astoreLoginBt")
	self._astoreLoginBt_t:onTouch(Functions.createClickListener(handler(self, self.onAstoreloginbtClick), ""))

	self._guestBt_t = self.view_t.csbNode:getChildByName("main"):getChildByName("loginPanle"):getChildByName("guestBt")
	self._guestBt_t:onTouch(Functions.createClickListener(handler(self, self.onGuestbtClick), ""))

end
--@auto code uiInit end


--@auto button backcall begin

--@auto code Loginbt btFunc
function AstoreLoginViewController:onLoginbtClick()
    Functions.printInfo(self.debug,"Loginbt button is click!")
    Functions.callJavaFuc(function()
        NativeUtil:sdkLogin()
    end) 
end
--@auto code Loginbt btFunc end

--@auto code Astoreloginbt btFunc
function AstoreLoginViewController:onAstoreloginbtClick()
    Functions.printInfo(self.debug,"Astoreloginbt button is click!")
    -- if G_isFirstStartApp then
    --     Functions.callJavaFuc(function()
    --         G_isFirstStartApp = false
    --         NativeUtil:GameCenterLogin()
    --     end)
    -- else
    --     Functions.callJavaFuc(function()
    --         NativeUtil:syncGameCenter()
    --     end)
    -- end
    Functions.callJavaFuc(function()
        NativeUtil:NaverLogin()
    end)
end
--@auto code Astoreloginbt btFunc end

--@auto code Guestbt btFunc
function AstoreLoginViewController:onGuestbtClick()
    Functions.printInfo(self.debug,"Guestbt button is click!")
    local NoticeManager = require("app.ui.noticeSystem.NoticeManager")
    NoticeManager:openTips(GameCtlManager.currentController_t, {title = "Guest 계정으로 로그인 후 게임을 삭제하시면 계정 정보가 저장되지 않습니다.",handler = function()
        local handler = function(event)
            GameState.storeAttr.isGusetLogin_b = true
            GameState.storeAttr.isLoginNaver_b = true
            GameState.storeAttr.NaverUserId_s = event.userName
            GameState.storeAttr.NaverUserName_s = event.userName
        end
        print("UserID：" .. GameState.storeAttr.NaverUserId_s)
        if GameState.storeAttr.NaverUserId_s ~= "" then 
            Functions.oneKeyLogin({userName = GameState.storeAttr.NaverUserId_s,cb = handler})
        else
            Functions.oneKeyLogin({cb = handler})
        end
    end}) 
end
--@auto code Guestbt btFunc end

--@auto button backcall end


--@auto code view display func
function AstoreLoginViewController:onCreate()
    Functions.printInfo(self.debug_b," AstoreLoginViewController controller create!")
end
function AstoreLoginViewController:openBgMusic()
    Audio.playMusic("sound/main2.mp3",true)
end
function AstoreLoginViewController:onDisplayView()
	Functions.printInfo(self.debug_b," AstoreLoginViewController view enter display!")
    Functions.loadImageWithSprite(self._npc_t, GameState.storeAttr.LoadingNpcImage_s)
end
--@auto code view display func end

return AstoreLoginViewController