json = require("json");
utils = require("utils");
storyboard = require("storyboard");
storyboard.purgeOnSceneChange = true;

if (system.getInfo("model") == "Kindle Fire") then
  local deviceScreen = {
    left = display.screenOriginX, top = display.screenOriginY,
    right = display.contentWidth - display.screenOriginX,
    bottom = display.contentHeight - display.screenOriginY
  }
  local kFireScale = 580 / 600;
  local stage = display.getCurrentStage();
  local stageShift = 10 * display.contentScaleY;
  local screenWidth = deviceScreen.right - deviceScreen.left;
  local xShift = ((screenWidth / kFireScale) - screenWidth) / 2;
  stage:setReferencePoint(display.CenterReferencePoint);
  stage:scale(kFireScale, kFireScale);
  stage.yOrigin = stage.yOrigin - stageShift;
  stage.yReference = stage.yReference + stageShift;
  deviceScreen.left = deviceScreen.left - xShift;
  deviceScreen.right = deviceScreen.right + xShift;
end


-- Turn off status bar.
display.setStatusBar(display.HiddenStatusBar);


-- Initial startup info.
os.execute("cls");
utils:log("main", "Spelunky + Skyrim STARTING...");
utils:log("main", "Environment: " .. system.getInfo("environment"));
utils:log("main", "Model: " .. system.getInfo("model"));
utils:log("main", "Device ID: " .. system.getInfo("deviceID"));
utils:log("main", "Platform Name: " .. system.getInfo("platformName"));
utils:log("main", "Platform Version: " .. system.getInfo("version"));
utils:log("main", "Corona Version: " .. system.getInfo("version"));
utils:log("main", "Corona Build: " .. system.getInfo("build"));
utils:log("main", "display.contentWidth: " .. display.contentWidth);
utils:log("main", "display.contentHeight: " .. display.contentHeight);
utils:log("main", "display.fps: " .. display.fps);
utils:log("main", "audio.totalChannels: " .. audio.totalChannels);


-- Seed random number generator.
math.randomseed(os.time());



storyboard.gotoScene("gameScene", "fade", 500);