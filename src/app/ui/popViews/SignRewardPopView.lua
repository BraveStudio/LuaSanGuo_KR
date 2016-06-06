--@auto code head
local BasePopView = require("app.baseMVC.BasePopView")
local SignRewardPopView = class("SignRewardPopView", BasePopView)

local Functions = require("app.common.Functions")

SignRewardPopView.csbResPath = "tyj/csb"
SignRewardPopView.debug = true
SignRewardPopView.studioSpriteFrames = {"PropUI","SignRewardPopUI","SignRewardPopUI_Text" }
--@auto code head end
SignRewardPopView.spriteFrameNames = 
    {
    }

SignRewardPopView.animaNames = 
    {
    }

--@auto code uiInit
--add spriteFrames
if #SignRewardPopView.studioSpriteFrames > 0 then
    SignRewardPopView.spriteFrameNames = SignRewardPopView.spriteFrameNames or {}
    table.insertto(SignRewardPopView.spriteFrameNames, SignRewardPopView.studioSpriteFrames)
end
function SignRewardPopView:onInitUI()

    --output list
    self._signPrizePanel_t = self.csbNode:getChildByName("signPrizePanel")
	
    --label list
    
    --button list
    self._closeBt_t = self.csbNode:getChildByName("closeBt")
	self._closeBt_t:onTouch(Functions.createClickListener(handler(self, self.onClosebtClick), ""))
end
--@auto code uiInit end


--@auto button backcall begin

--@auto code Closebt btFunc
function SignRewardPopView:onClosebtClick()
    Functions.printInfo(self.debug,"Closebt button is click!")
    self:close()
end
--@auto code Closebt btFunc end

--@auto button backcall end


--@auto code output func
function SignRewardPopView:getPopAction()
	Functions.printInfo(self.debug,"pop actionFunc is call")
end

function SignRewardPopView:onDisplayView()
	Functions.printInfo(self.debug,"pop action finish ")
    Functions.setPopupKey("sign_in")
    self:initPrizeList(self._signPrizePanel_t,g_SampleCfg.NewReward,RewardStateData.rewardState)

    self._prizeBt_t = self._signPrizePanel_t:getChildByTag(1):getChildByName("bg")
end

function SignRewardPopView:onCreate()
	Functions.printInfo(self.debug,"child class create call ")
end
--@auto code output func end

--custom code start
function SignRewardPopView:initPrizeList(prizePanel,prizeData,prizeStateData)
 
    for i = 1,#prizeData do
        local prizeBox = prizePanel:getChildByTag(i)   

        for j=1,4 do
             local prize = prizeBox:getChildByName("prize" .. tostring(j))
             prize:ignoreContentAdaptWithSize(true)
             local prizeCnt = prizeBox:getChildByName("prize" .. tostring(j) .. "Cnt")
             prizeCnt:setString("x" .. tostring(prizeData[i][j][3]))

            if prizeData[i][j][2] == 1 then
                local heroHeadImg = ConfigHandler:getHeroHeadImageOfId(prizeData[i][j][1]) 
                Functions.loadImageWithWidget(prize, heroHeadImg)
            elseif prizeData[i][j][2] == 4 and prizeData[i][j][1] > 0 then
                local propImg = ConfigHandler:getPropImageOfId(prizeData[i][j][1]) 
                Functions.loadImageWithWidget(prize, propImg)
            elseif prizeData[i][j][1] == -3 then
                Functions.loadImageWithWidget(prize, "property_money.png")
            elseif prizeData[i][j][1] == -2 then
                Functions.loadImageWithWidget(prize, "property_gold.png")
            elseif prizeData[i][j][1] == -5 then
                Functions.loadImageWithWidget(prize, "soul80.png")
            elseif prizeData[i][j][1] == -6 then    
                Functions.loadImageWithWidget(prize, "property_soulCrystal.png")
            end
        end

   
        local mask = prizeBox:getChildByName("mask")
        local done = prizeBox:getChildByName("done")
        local choose = prizeBox:getChildByName("choose")
        local prize = prizeBox:getChildByName("bg")

        if i == prizeStateData.m_keepLoginDay and  prizeStateData.m_loginReward == 1 then
            mask:setVisible(true)
            done:setVisible(true)
            choose:setVisible(true) 
            prize:setTouchEnabled(false)
        elseif  i < prizeStateData.m_keepLoginDay and  prizeStateData.m_loginReward == 1 then
            mask:setVisible(true)
            done:setVisible(true)
            prize:setTouchEnabled(false)
        elseif i < prizeStateData.m_keepLoginDay then
             mask:setVisible(true) 
             done:setVisible(true)
             prize:setTouchEnabled(false)
        elseif i == prizeStateData.m_keepLoginDay and prizeStateData.m_loginReward ~= 1 then --当前可领取状态
            choose:setVisible(true) 
            prize:setTouchEnabled(true)
        end
        local onPrizeClick = function()
            local handler = function(event)
                Functions.playSound("getrewards.mp3")
                mask:setVisible(true)
                done:setVisible(true)
                prize:setTouchEnabled(false)   
                prizeStateData.m_loginReward = 1    
                Functions:addItemResources({id = prizeData[i][1][1],type = prizeData[i][1][2],count = prizeData[i][1][3],slot = event.rettbl[1]})
                Functions:addItemResources({id = prizeData[i][2][1],type = prizeData[i][2][2],count = prizeData[i][2][3],slot = event.rettbl[2]})
                Functions:addItemResources({id = prizeData[i][3][1],type = prizeData[i][3][2],count = prizeData[i][3][3],slot = event.rettbl[3]})
                RewardStateData.eventAttr.signRewardFlag = 0   --签到领奖：是否有奖可领 1/0
            end
            RewardData:RequestSignReward(handler)
        end
        prize:onTouch(Functions.createClickListener(handler(prize, onPrizeClick), ""))
    end
   
    local dayCnt = prizePanel:getChildByName("dayCnt")
    dayCnt:setString(tostring(prizeStateData.m_keepLoginDay))
end
--custom code end
return SignRewardPopView