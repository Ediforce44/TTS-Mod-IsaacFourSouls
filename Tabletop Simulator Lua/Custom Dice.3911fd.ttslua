function onLoad()
	lifespan     = 2 
	spin_speed   = 2 
	rise_speed   = 2 
	grow_speed   = 3 
	font_size    = 2 
	flash_max    = true 
	sound_max    = false 
	sound_min    = false 
	log_chat     = true 
	parent_guid  = "card01" 
	roll_active  = false
	rv = self.getRotationValues() or false
end
function onDrop(a)trigger(a)end;function onRandomize(a)trigger(a)end;function trigger(a)if roll_active then return false end;roll_active=true;Wait.condition(function()roll_active=false;local b=self.getRotationValue()or false;if not b or not rv then log("Dice "..self.guid.." does not have a valid rotation value set! Unable to show roll value.")return false end;local c=self.getPosition()+Vector({0,1+font_size/5,0})local d=spawnObject({type="3DText",position=c,sound=true})d.TextTool.setValue(tostring(b))d.TextTool.setFontColor(self.getColorTint())d.TextTool.setFontSize(font_size*24)Wait.frames(function()d.interactable=false;d.auto_raise=false;rise(d,c)spin(d,{0,spin_speed*18,0})grow(d,font_size*24)log("Score is "..b)if log_chat then local e=a;if self.getName()and self.getName()~=""then e=e.." | "..self.getName()end;printToAll("["..e.."] "..Player[a].steam_name.." rolled a "..b,a)end;if(sound_max or flash_max)and b==rv[#rv].value then if flash_max then flash(self)flash(d)end;if sound_max and getObjectFromGUID(parent_guid)then getObjectFromGUID(parent_guid).AssetBundle.playTriggerEffect(0)end end;if b==1 and sound_min and getObjectFromGUID(parent_guid)then getObjectFromGUID(parent_guid).AssetBundle.playTriggerEffect(1)end;Wait.time(function()d.destruct()end,lifespan)end,1)end,function()return self.resting end,5)end;function rise(d,c)if not getObjectFromGUID(d.guid)then return false end;d.setPosition(c)c[2]=c[2]+rise_speed/100;Wait.frames(function()rise(d,c)end,1)end;function spin(d,f)if not getObjectFromGUID(d.guid)then return false end;d.setRotationSmooth(f,false,true)f[2]=f[2]+spin_speed*5;Wait.time(function()spin(d,f)end,0.5)end;function grow(d,font_size)if not getObjectFromGUID(d.guid)then return false end;d.TextTool.setFontSize(font_size)Wait.time(function()grow(d,font_size*(grow_speed+100)/100)end,0.1)end;function flash(d,g)if not getObjectFromGUID(d.guid)or g and g>20 then return false end;local a=g or 1;local h=self.getColorTint()if a%2==0 then h=randomColor()end;if d.tag=="3D Text"then d.TextTool.setFontColor(h)else d.highlightOn(h,0.1)end;Wait.time(function()flash(d,a+1)end,0.2)end;function randomColor()local i=math.random;return{i(255)/255,i(255)/255,i(255)/255}end