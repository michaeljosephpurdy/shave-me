pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
-- shave me
-- by mike purdy

function _init()
 test_levels()
 state='menu'
 load_levels()
 p=new_player()
 hairs={}
 goal={}
	score=0
	goal_score=0
	gametime=0
	menu_starttime=time()
	starttime=nil
	clients_seen=0
	next_client=false
	intro_over=false
	tips=0
	menu_text=0
	sign_sprite=39
	sign_anim_counter=0
	music_playing='none'
	max_hairs_cut=0
	hairs_cut=0
	first_level_started=nil
	show_what_you_want_button=false
	change_msg_speed(1)
end

function _update()
 if level_i>=2 then
  show_what_you_want_button=true
 end
 if starttime==nil then
  gametime = 600
 else
  gametime = 600-flr(time()-starttime)
 end
 update_msg()
 tip_update()
 if state=='menu' then
  if music_playing!=state then
  	music(0, 0, 12)
  	music_playing=state
  end
  if menu_text>=-100 then
   menu_text-=1
  end
  sign_anim_counter+=1
  if sign_anim_counter>=7 then
   if sign_sprite==39 then
  	 sign_sprite=53
  	elseif sign_sprite==55 then
  	 sign_sprite=39
  	else sign_sprite+=1 end
  	sign_anim_counter=0
  end
  if time()-menu_starttime>6 and not next_state then
   if btnp(❎) then 
	   req_fadeout()
	   next_state='load'
	  end
	  if btnp(🅾️) then
	   change_msg_speed(1)
	  end
  end
  if fadeout_done() and next_state then
   req_fadein()
   state='load'
   next_state=nil
  end
 elseif state=='load' then
  load_level()
  state='employer'
  add_msg('busy day for a first day.')
  add_msg('just listen to what every     client wants.')
  add_msg("you'll do great.")
  update_msg()
  req_fadein()
 elseif state=='employer' then
  	if music_playing!=state then
	 		music(-1, 500)
	   music_playing=state
  	end
   if msgs_done() then
 			req_fadeout()
    next_state='intro'
    foreach(level.req, add_msg)
   end
		if next_state and fadeout_done() then
		 state=next_state
		 next_state=nil
		 req_fadein()
		end
 elseif state=='intro' then
  if starttime==nil then
   starttime=time()
  end
  if fadein_done() then
 		if msgs_done() then
  	 state='cut'
  	 if level_i==1 then
  	  first_level_started=time()
  	 else
  	  first_level_started=nil
  	 end
  	end
 	end
 elseif state=='cut' then
  if first_level_started==nil and
     level_i==1 then
   first_level_started=time()
  end
 	if music_playing!=state then
 		music(1, 0, 12)
  music_playing=state
  end
  update_player()
  update_particles()
  if gametime==0 then
   gameover()
  end
 	if next_client then
 		local tip=calc_tip()
 		req_tip_display(tip)
  	tips+=tip
  	add_msg(outro_message(tip))
 	 state='outro'
 	end
 elseif state=='outro' then
 	if music_playing!=state then
 		music(-1, 500)
   music_playing=state
  end
  if not next_state and msgs_done() then
   req_fadeout()
   clients_seen+=1
   level_i+=1
   level=levels[level_i]
   if level==nil or
      gametime<=0 then
    add_msg('you were able to help         '..clients_seen..' clients')
    add_msg('and you made '..tips..' bucks!')
 			add_msg('good work today! same time    tomorrow?')
 			update_msg()
 			req_fadeout()
 			next_state='gameover'
    return 
   end
   next_state='intro'
  end
  if next_state=='intro' and fadeout_done() then
   load_level()
   foreach(cur_level.req, add_msg) 
   req_fadein()
   state=next_state
   next_state=nil
  end
  if next_state=='gameover' and fadeout_done() then
   state=next_state
   next_state=nil
  end
 elseif state=='gameover' then
  if msgs_done() and
     next_state!='menu' then
   req_fadeout()
   --todo
   level_i=1
   clients_seen=0
   tips=0
   load_levels()
   next_state='menu'
  end
  if next_state and
     fadeout_done() then
   state=next_state
   next_state=nil
   starttime=nil
  end
 end
end

function gameover()
end

function _draw()
 pal()
 cls()
 
 if state=='cut' then
  map()
  draw_hair()
  draw_particles()
  draw_ui()
  if fadeout_done() and
     fadein_done() then
  -- draw_goal()
 	end
 	if cur_level.top_help then
 	 print(cur_level.top_help[1], 0, 0, 10)
 	 if cur_level.top_help[2] then
 	  print(cur_level.top_help[2], 0, 8, 10)
 	 end
 	end
 	if first_level_started!=nil and
 	   first_level_started+10<time() then
 	 print('move the buzzer over next', 0, 112, 10)
 	 print('client, hit ❎ when done', 0, 120, 10)
 	 spr(41, 80, 100)
 	end
 	if show_what_you_want_button and
 	   level_i==2 then
 	 print('you can ask clients', 18, 112, 10)
 	 print('to repeat themselves', 14, 120, 10)
 	 spr(41, 88, 92, 1, 1, false, true)
 	end
  
 elseif state=='intro' or
        state=='outro' then
  map()
  draw_hair()
  draw_ui()
 elseif state=='instructions' then
  map(50, 0, 0, 0, 16, 16)
 elseif state=='employer' then
  map(33, 0, 0, 0, 16, 16)
  pal(15, 4, 1)
  pal(1, 5, 1)
  pal(11, 2, 1)
  pal(3, 13, 1)
	 if fadein_done() then
	  draw_ui()
	 end
 elseif state=='menu' then
  map(16, 0, 0, 0, 16, 16)
  for i=0,13 do
   for k=0,4 do
    spr((196+i)+(16*k), i*8-menu_text-100,76+(8*k))
   end
  end
  spr(23, 52, 49)
  spr(22, 60, 49)
  spr(38, 68, 49)
  spr(sign_sprite, 52, 40)
  if time()-menu_starttime>6 then
   print('❎/x: start', 20, 110, 7)
   print('🅾️/z: message speed '..msg_speed, 20, 118, 7)
  end
  print('by', 220+menu_text, 80, 7)
  print('mike', 212+menu_text, 88, 7)
  print('purdy', 208+menu_text, 96, 7) 
 elseif state=='gameover' then
  map(33, 0, 0, 0, 16, 16)
  pal(15, 4, 1)
  pal(1, 5, 1)
  pal(11, 2, 1)
  pal(3, 13, 1)
 end
 display_msg()
 if state=='cut' then
  draw_player()
  draw_cursor()
 end
 tip_display()
 draw_fadeout()
 draw_fadein()
 if (fadein_done() and fadeout_done())
     and next_state then
  fade_fill()
 end
end


-->8
-- level generations
function load_level(i)
 p.x=5
 p.y=100
 if cur_level!=level then
  cur_level=level
 end
 hairs=generate_beard(cur_level[1])
 goal=generate_goal(cur_level[2])
 max_hairs_cut=calc_max_moves(hairs, goal)
end

function calc_max_moves(_hairs, _goal)
 goal_lengths=0
 foreach(_goal, function(g)
  goal_lengths+=g.length
 end)
 hair_lengths=0
 foreach(_hairs, function(h)
  hair_lengths+=h.length
 end)
 return abs(goal_lengths-hair_lengths)
end


function color_match(dict, s, to_match)
 for y=0,7 do
  for x=0,7 do
   spr(s, 0, 0)
   local x_offset=0
   local y_offset=0
   local colour=pget(x+x_offset,y+y_offset)
  	if colour==to_match then
  	 local x_offset=16
    local y_offset=48
  	 add(dict, {
  	  length=calc_length(to_match),
  	  x=x*8+x_offset,
  	  y=y*8+y_offset,
  	  })
  	end
  end
 end
end

function calc_length(i)
 if i==8 then return 4
 elseif i==9 then return 3
 elseif i==10 then return 2
 elseif i==11 then return 1
 elseif i==12 then return 0
 end
end

function generate_beard(sprite)
 local _hairs={}
 color_match(_hairs,sprite,8)
 color_match(_hairs,sprite,9)
 color_match(_hairs,sprite,10)
 color_match(_hairs,sprite,11)
 return _hairs
end

function generate_goal(sprite)
 local _goal={}
 color_match(_goal,sprite,8)
 color_match(_goal,sprite,9)
 color_match(_goal,sprite,10)
 color_match(_goal,sprite,11)
 color_match(_goal,sprite,12)
 return _goal
end
-->8
-- scoring

function calc_score(_hairs, _goals)
 local s=0
 foreach(goal, function(g)
  local h=matching_hair(g)
  if h!= nil then
   local diff=abs(g.length-h.length)
	 	if diff==0 then s+=5
			elseif diff==1 then s+=1
	 	elseif diff==2 then s+=.5
	 	elseif diff==3 then s+=0
		 elseif diff==4 then s-=1
		 else s-=10 end
  end
 end)
 local goal_score=#goal*5
 if goal_score<=0 then return 0 end
 return (s/goal_score)
end

function matching_hair(g)
 for i=0,#hairs do
  local h=hairs[i]
  if h!=nil then
   if g.x==h.x and g.y==h.y then
 	  return h
  	end
  end
	end
 return nil
end

function stub(x, y, l)
 return {x=x, y=y, length=l}
end

-->8
-- levels
levels={
  {64, 65, req={
    'just a trim with a number 2   guard'
   },
   top_help={"press ❎ or 'x'","to shave"}
  },{66, 67, req={
 	  'take these bad boys down to a number one please'
 	 },
 	 top_help={"press 🅾️ or 'z'","to switch guards"}
 	},{96, 97, req={
 	  'clean shave please.'
 		},
 		top_help={"you can only use the","razor on stubble"}
 	},{68, 69, req={
 	  'take off the handle bars.     keep the rest, though.'
 		}
 	},{70, 71, req={
 	  "i'd love a goatee, can you do that?",
 		}
 	},{72, 73, req={
 	  'keep the soul patch. evertyth-ing else? clean shaven.'
 	 }
 	},{74, 75, req={
 	  'got a wedding to go to.       just a clean shave please.',
 	 }
 	},{76, 77, req={
 	  'why did that guy shave off hisbeard? it was awesome!',
 	  'i want what he had.'
 	 }
 	},{78, 79, req={
 	  "trim it all the way down but  don't shave it off",
 	 }
  },{88, 89, req={
 	  'my wife says it looks dumb andthat i need to shave it off',
 	 },
	 },{80, 81, req={
	   'shave it all off but i want tostill have the sideburns',
	   "i don't want them below my    nose"
	  }
	 },{90, 91, req={
	   "i tried fading my sideburns.  you gotta fix!'em"
	  }
	 },{92, 93, req={
	   "i'd like a clean moustache.   maybe take it to a number one"
	  }
	 },{94, 95, req={
	   'i want to keep the little bit on my chin'
	  }
	 },{98, 99, req={
	   'i want sideburns that fade to nothing, and a moustache',
	   'trim the `stache with a numbertwo'
	  }
	 },{100, 101, req={
	   "i tried growing a beard. it's pretty pathetic...",
	   'just shave it all, please',
	  }
	 },{102, 103, req={
	   'i think it looks cool.',
	   "everyone at work doesn't.",
	   'i want it all gone, please'
	  }
	 },{104, 105, req={
	   'keep everything under my lips but shave the rest.'
	  }
	 }
 }
 
function load_levels()
 foreach(levels, function(l)
  l.state={}
 end)
 level_i=1
 level=levels[level_i]
end

function test_levels()
 foreach(levels, function(l)
  local h=generate_beard(l[1])
  local g=generate_goal(l[2])
  assert(#h==#g, l[1]..' and '..l[2]..' are not same length')
 end)
end
test_levels()
-->8
-- hair
function draw_hair()
 for h in all(hairs) do
  local sprite=calc_sprite(h)
  spr(sprite,
      h.x,
      h.y)
 end
 for h in all(hair_particles) do
 end
end

function calc_sprite(h)
 local l=h.length
 if l==4 then return 6
 elseif l==3 then return 7
 elseif l==2 then return 8
 elseif l==1 then return 9
 else return 1 end
end

function check_coll(hair)
 local px,py,hx,hy,l=p.x+4,p.y+2,hair.x,hair.y,hair.length
 if px >= hx and
    px <= hx+7 and
    py >= hy and
    py <= hy+7 then
  local prev_len=hair.length
  if p.item=='buzzer2' then
   if l>=4 then
    sfx(1)
    add_particle(hx,hy,l)
    hair.length=3
   end
  elseif p.item=='buzzer1' then
   if l>=3 then
    sfx(2)
    add_particle(hx,hy,l)
    hair.length=2
   end
  elseif p.item=='buzzer0' then
   if l>=2 then
    sfx(3)
    add_particle(hx,hy,l)
   	hair.length=1
   end
  elseif p.item=='razor' then
   if l==1 then
    sfx(4)
    hair.length=0
   end
  end
 end
end

function cut_hair()
 foreach(hairs, check_coll) 
end

-->8
-- dialogue system
local msgs={}
local msg_speeds={.4,.8,1.2}
msg_speed=3

function change_msg_speed(b)
 if b==112 then return true end
 msg_speed-=1
 if msg_speed<1 then
  msg_speed=#msg_speeds
 end
 menuitem(1,"message speed: "..msg_speed,
	 change_msg_speed)
end

function clear_msgs()
 msgs={}
end

function msgs_done()
 return msgs[1]==nil
end

function add_msg(_msg, talk)
 local msg={}
 if #_msg>30 then
  msg[1]=sub(_msg,1,30)
  msg[2]=sub(_msg,31)
 else
  msg[1]=_msg
  msg[2]=' '
 end
 msg.timer=0
 msg.endtimer=#_msg*3
 msg.pointer=0
 log('end_timer: '..msg.endtimer)
	if talk!=nil then
	 msg.talk=true
	else
	 msg.talk=false
	end
	add(msgs,msg)
end

function update_msg()
 if fadein_done() and fadeout_done() then
  local cur=msgs[1]
  if cur!=nil then
   if cur.timer>cur.endtimer then
    del(msgs, cur)
   end
   cur.timer+=msg_speeds[msg_speed]
   cur.pointer+=msg_speeds[msg_speed]
   log('timer'..cur.timer)
   log('pointer'..cur.pointer)
   log('endtimer'..cur.endtimer)
  else
   del(msgs, msg)
  end
 end
end

function display_msg()
 if fadein_done() and fadeout_done() then
 local cur=msgs[1]
 if cur==nil then
  return
 end
 palt(0, false)
 local msg1=cur[1]
 local msg2=cur[2]
 local pointer=cur.pointer
 
 -- randomize character talking
 if rnd(100) >= 25 and
    pointer < (#cur[1]+#cur[2]) then
  spr(32, 32, 88)
 	spr(33, 40, 88)
 	spr(33, 48, 88)
 	spr(34, 56, 88)
 	if rnd(100) >= 50 then sfx(0) end
	end
	
	-- dialogue
	rectfill(3, 112, 120, 127, 1)
	rectfill(3, 113, 120, 126, 7)
 spr(128, 0, 112, 1, 1)
 spr(128, 0, 120, 1, 1, false, true)
 spr(128, 120, 112, 1, 1, true)
 spr(128, 120, 120, 1, 1, true, true)
 print(sub(cur[1], 0, pointer), 4, 114, 1)
 if pointer>=#cur[1] then
  print(sub(cur[2], 0, pointer-#cur[1]), 4, 121, 1)
 end
 palt()
 end
end
-->8
-- ui
function calc_tip()
 local score=calc_score(hairs, goal)
 if score <=0 then return 0 end
 return flr(7*score)
end

function draw_tips()
 local x,y=104,7
 print('tips', x, y, 5)
 print('$'..tips, x+4, y+8, 5)
end

function draw_time()
 local x,y=104,27
 print('closing', x-4, y, 5)
 print('time', x, y+8, 5)
 if gametime>0 then
  print(gametime, x+6, y+16, 5)
 else
  print('closed', x-2, y+16, 5)
 end
end

function draw_client_count()
 local x,y=100,53
 print('clients', x, y, 5)
 print('seen', x+6, y+8, 5)
 print(clients_seen, x+12, y+16, 5)
end

function draw_ui()
 draw_next_client_button()
 draw_tips()
 draw_time()
 draw_client_count()
 draw_what_you_want_button()
end

function draw_next_client_button()
 local x=101
 local y=76
 offset=0
 if click_button_1 then
  offset=1
 end
 rectfill(x+offset, y+offset, x+25, y+20, 13)
 rectfill(x+1, y+1, x+23+offset, y+18+offset, 6)
 print('next', x+5+offset, y+3+offset, 5)
 print('client', x+1+offset, y+11+offset, 5)
end

function draw_what_you_want_button()
 if not show_what_you_want_button then return end
 local x=101
 local y=98
 offset=0
 if click_button_2 then
  offset=1
 end
 rectfill(x+offset, y+offset, x+25, y+28, 13)
 rectfill(x+1, y+1, x+23+offset, y+26+offset, 6)
 print("what", x+5+offset, y+3+offset, 5)
 print('you', x+6+offset, y+11+offset, 5)
 print('want?', x+3+offset, y+19+offset, 5)
end

function draw_customer_speech()
 assert(false)
-- palt(0, false)
 local req1=cur_level.request[1]
 local req2=cur_level.request[2]
 local pointer=cur_level.request.pointer
 local pointer2=cur_level.request.pointer2
 if rnd(100) >= 25 and
    pointer2 < #req2+5 then
  spr(32, 32, 88)
 	spr(33, 40, 88)
 	spr(33, 48, 88)
 	spr(34, 56, 88)
	end
	rectfill(13, 112, 80, 128, 7)
 spr(128, 10, 112, 1, 1)
 spr(128, 10, 120, 1, 1, false, true)
 spr(128, 80, 112, 1, 1, true)
 spr(128, 80, 120, 1, 1, true, true)
 print(sub(req1, 0, pointer), 14, 114, 1)
 cur_level.request.pointer+=.35
 if pointer>=#req1 then
  print(sub(req2, 0, pointer2), 14, 121, 1)
  cur_level.request.pointer2+=.35
 end
-- palt()
end

-->8
-- tips
function outro_message(tip)
 if tip<=0 then return     'well, that was a waste of time'
 elseif tip<=3 then return 'thanks... i guess'
 elseif tip<=4 then return 'not bad.  thanks.'
 elseif tip<=5 then return 'great, thanks forthe shave.'
 elseif tip<=6 then return 'this turned out great, thanks.'
 else return               'this is perfect, thank you!'
 end
end

local y=12
local tip_amount=nil
function req_tip_display(tip)
 tip_amount=tip
 y=12
end

function tip_update()
 if tip_amount==nil then return end
 y-=.5
 if y<=-8 then
  tip_amount=nil
 end
end

function tip_display()
 if tip_amount==nil then return end
 print('+$'..tip_amount, 80, y, 10)
end

function wait(a) for i = 0,a do flip() end end

function customer_fadein(reverse)
 pal(0, 10)
 pal(1, 0)
 palt(10, true)
 fadein(16, 11)
 pal()
end

function fadein(_x, _y)
	local sprite=13
 while sprite>=10 do
 	for y=0,_x do
 	 for x=0,_y do
 	  spr(sprite, x*8, y*8)
 	 end
		end
		wait(5)
		sprite-=1
	end
end

function fadeout(_x, _y)
 local sprite=10
 while sprite<=13 do
 	for y=0,_x do
 	 for x=0,_y do
 	  spr(sprite, x*8, y*8)
 	 end
 	end
 	wait(5)
 	sprite+=1
	end
end

-->8
-- transitions

fadeout_counter=nil
fadein_counter=nil
fade_color=5
fade_increment=0.0009
customer=nil

function fadein_done()
 return fadein_counter==nil
end

function fadeout_done()
 return fadeout_counter==nil
end

function fade_fill()
 rectfill(-1, -1, 129, 129, fade_color)
end

function draw_fadeout()
 if fadeout_counter==nil then
  return
 end
 x_upper_limit=16
 if customer then x_upper_limit=12 end
 if fadeout_counter<5 then
 for _y=0,16 do
  for _x=0,x_upper_limit do
   local x,y=_x*8,_y*8
	   rectfill(x-fadeout_counter,
	   								 y-fadeout_counter,
	   								 x+fadeout_counter,
	   								 y+fadeout_counter,
	   								 fade_color)
	   fadeout_counter+=fade_increment
	  end
	 end
 else
  fadeout_counter=nil
  customer=false
 end
end

function req_fadeout(_customer)
 fadeout_counter=0
 customer=_customer
end

function draw_fadein()
 if fadein_counter==nil then
  return
 end
 x_upper_limit=16
 if customer then x_upper_limit=12 end
 if fadein_counter>=0 then
 for _x=0,x_upper_limit do
  for _y=0,16 do
   local x,y=_x*8,_y*8
	   rectfill(x-fadein_counter,
	   								 y-fadein_counter,
	   								 x+fadein_counter,
	   								 y+fadein_counter,
	   								 fade_color)
	   fadein_counter-=fade_increment
	  end
	 end
 else
  fadein_counter=nil
  customer=false
 end
end

function req_fadein(_customer)
 fadein_counter=5
 customer=_customer
end

-->8
-- player
function new_player()
 return {
  x=5,
  y=100,
  state='idle',
  item='buzzer2',
  speed=2
 }
end

function move_player()
 if btn(➡️) then
  p.x=p.x+p.speed
 elseif btn(⬅️) then
  p.x=p.x-p.speed
 end
 if btn(⬆️) then
  p.y=p.y-p.speed
 elseif btn(⬇️) then
  p.y=p.y+p.speed
 end
 if p.x<=0 then
  p.x=0
 elseif p.x>=124 then
  p.x=124
 elseif p.y<=4 then
  p.y=4
 elseif p.y>=124 then
  p.y=124
 end
end

function item_swap()
 if level_i==1 then return end
 if btnp(🅾️) then
  if p.item=='buzzer2' then
   p.item='buzzer1'
  elseif p.item=='buzzer1' then
   p.item='buzzer0'
  elseif p.item=='buzzer0' then
   if level_i==2 then
    p.item='buzzer2'
   else
    p.item='razor'
   end
  else
   p.item='buzzer2'
  end
 end
end

function update_player()
 move_player()
 next_client=false
 click_button_1=false
 click_button_2=false
 if btn(❎) then
  p.state='use'
 else
  p.state='idle'
 end
 item_swap()
 if btnp(❎) then
  if p.x<=96 then
   cut_hair()
  else
   if p.x>=101 and
      p.x<=126 and
      p.y>=76 and
      p.y<=94 then
    click_button_1=true
    next_client=true
    clear_msgs()
   end
   if p.x>=101 and
      p.x<=126 and
      p.y>=97 and
      p.y<=126 then
    if msgs_done() and
       show_what_you_want_button then
	    click_button_2=true
     foreach(cur_level.req, add_msg)
    end
   end
  end
 end
end

function draw_cursor()
	if p.x>=90 then
	 if p.state=='use' then
	  spr(37, p.x, p.y)
	 else
	  spr(36, p.x, p.y)
	 end
	end
end

function draw_player()
 if p.x<90 then
	if p.state=='idle' then
	 if p.item=='scissors' then
	  draw_idle_scissors()
	 elseif p.item=='buzzer3' then
	  draw_idle_buzzer(3)
	 elseif p.item=='buzzer2' then
	  draw_idle_buzzer(2)
	 elseif p.item=='buzzer1' then
	  draw_idle_buzzer(1)
	 elseif p.item=='buzzer0' then
	  draw_idle_buzzer(0)
	 else
	  draw_idle_razor()
	 end
	else
	 if p.item=='buzzer3' then
	  draw_used_buzzer(3)
	 elseif p.item=='buzzer2' then
	  draw_used_buzzer(2)
	 elseif p.item=='buzzer1' then
	  draw_used_buzzer(1)
	 elseif p.item=='buzzer0' then
	  draw_used_buzzer(0)
	 else
	  draw_used_razor()
	 end
	end
	end
end

function draw_big_sprite(a,b,c,d,e,f,x_offset,y_offset)
 local x,y=p.x,p.y
 x+=x_offset
 y+=y_offset
 spr(a, x, y)
 spr(b, x+8, y)
 spr(c, x, y+8)
 spr(d, x+8, y+8)
 spr(e, x, y+16)
 spr(f, x+8, y+16)
end

function draw_idle_scissors()
 draw_big_sprite(22,23,38,39,54,55,0,0)
end

function draw_used_scissors()
 draw_big_sprite(24,25,40,41,56,57,0,0)
end

function draw_idle_buzzer(i)
 draw_big_sprite(26,27,42,43,58,59,0,0)
 palt(0, false)
	print(i, p.x+5, p.y+12, 0)
	palt()
end

function draw_used_buzzer(i)
 x_offset=rnd(2)-1
 y_offset=rnd(2)-1
 draw_big_sprite(26,27,42,43,58,59,x_offset,y_offset)
 palt(0, false)
 print(i, p.x+x_offset+5, p.y+y_offset+12, 0)
	palt()
end

function draw_idle_razor()
 draw_big_sprite(28,29,44,45,60,61,0,0)
end

function draw_used_razor()
 draw_big_sprite(28,29,44,45,60,61,0,0)
end
-->8
-- draw goal
local ear_goal_pixels={
  {-1, 0}, {-1, 1}, {-2, 0}, {-2, 1},
 	{-1, 2}, {-1, 3}, {-2, 2}, {-2, 3},
 	{16, 0}, {16, 1}, {17, 0}, {17, 1},
 	{16, 2}, {16, 3}, {17, 2}, {17, 3}
	}

function draw_goal()
 local x_offset=105
 local y_offset=110
 spr(46, 0+x_offset, 0+y_offset)
 spr(47, 8+x_offset, 0+y_offset)
 spr(62, 0+x_offset, 8+y_offset)
 spr(63, 8+x_offset, 8+y_offset)
 foreach(ear_goal_pixels, function(e)
  pset(x_offset+e[1], y_offset+e[2], 15)
 end)
 print('request', x_offset-5, y_offset-6, 5)
 
 foreach(goal, function(g)
  local x=g.x/8
  local y=g.y/8
  if g.length>=1 then
   pset((x-2)*2+x_offset+1, (y-6)*2+1+y_offset, 4)
  end
  if g.length>=2 then
   pset((x-2)*2+x_offset, (y-6)*2+1+y_offset, 4)
  end
  if g.length>=3 then
   pset((x-2)*2+x_offset+1, (y-6)*2+y_offset, 4)
  end
  if g.length>=4 then
   pset((x-2)*2+x_offset, (y-6)*2+y_offset, 4)
  end
 end)
end
-->8
-- particle system
local particles={}

function add_particle(x,y,amt)
 for i=1,amt do
  add(particles, {
   x=x+rnd(7),
   y=y+rnd(7),
   dx=rnd(2)-1,
  })
 end
end

function update_particles()
 for p in all(particles) do
  -- remove particles off screen
  if p.y > 150 then
   del(particles, p)
  end
  p.x+=p.dx
  p.dx*=0.1
  p.y+=2
 end
end

function draw_particles()
 for p in all (particles) do
  pset(p.x, p.y, 4)
 end
end
-->8
-- log

log=function(msg)
 printh(msg, 'shaveme.p8l')
end
__gfx__
00000000ffffffffffffffffffffffffffffffffffffffff4444444404040404000000000000000010001000101010101010101011111111ffffffffffffffff
00000000ffffffffffffffff55ffffffffff4444444fffff4444444404040404040404040004000400000000000000000101010111111111ffffffffffffffff
00000000fffffffffff55557775fffffff44444444444fff4444444440404040000000000000000000100010101010101010101011111111ffffffffffffffff
00000000ffffffffff5777777775fffff4444444444444ff4444444440404040404040404000400000000000000000000101010111111111ffffffffffffffff
00000000ffffffffff57777777775fffff4fffffffffffff4444444404040404000000000000000010001000101010101010101011111111ffffffffffffffff
00000000fffffffffff7777777775fffffffffffffffffff4444444404040404040404040004000400000000000000000101010111111111ffffffffffffffff
00000000fffffffff577777bb77775ffffffffffffffffff4444444440404040000000000000000000100010101010101010101011111111ffffffffffffffff
00000000fffffffff577777b3b7775ffffffffffffffffff4444444440404040404040404000400000000000000000000101010111111111ffffffffffffffff
ffffff55fffffffff5777b700bb775ffffffffffffffffff0000000000000000333333333333333300000050000000000000000000006500ffffffffffffffff
ffff55ff5ffffffff5777b000b37775fffff44444fffffff8880055000000040333333333333333300000515550000000000000000566650ffffffffffffffff
fff5ffff5ffffffff5777b0003b7775fff44444444444fff0ff0044000440ff4333333333e3e3e3e00005151550000000000000055655650ffffffffffffffff
ff5fffff5ffffffff5777b000b77775ff44444444444444f009000400ff400f433333333e3e3e3e300051515550000000000055566555600ffffffffffffffff
f5ffffff5fffffffff7777bb3777775fffffffffffff4fff0999011100900ddd333333333e3e3e3e005151555000000000055666555660000044444444444400
5ffffffff5ffffffff5777777777775fffffffffffffffff0f9f041409990fdf33333333e3e3e3e3051515556600000000556555566500000044444444444400
5ffffffff5ffffffff5777777777775fffffffffffffffff00c000500fcf001033333333eeeeeeee515155566600000006565566655000004444444444444444
ffffffffff55fffffff5555555555fffffffffffffffffff0dc002500dc0021033333333eeeeeeee157755666600000005655655550000004444444444444444
ffffffffffffffffffffffffffffffff0500000000000000000000005d55555d33333333000aaaaa55776667660000000556505556000000fff77ffffff77fff
ffffffff55555555ffffffffffffffff5650000005000000099000225555d555333333330000aaa955567667660000000556005556000000ff77b7ffff77b7ff
ffff55557777777755555fffffffffff56650000565000000ff00ff255d5555d3e3e3e3e00000aa955567677660000000000005666000000ff71b7ffff71b7ff
ff55777777777777777775ffffffffff566650005665000000f0001044444444e3e3e3e30000a99955566776660000000000005666600000ff7777ffff7777ff
f50000000000000000000055ffffffff56666500566650000f3f0111999948443e3e3e3e000a900955566666660000000000005666600000fffffff5ffffffff
ff550000000000000000055fffffffff56655000566665000f3f0f1f9aa94744e3e3e3e300a9000005566666660000000000000566660000ffffff5fffffffff
ffff55555555555555555fffffffffff055650005665500000100040a9a94c44eeeeeeee0a90000005566666670000000000000566660000ffffff5fffffffff
ffffffffffffffffffffffffffffffff000000000556500004100d40999a4744eeeeeeeea900000000566666760000000000000566660000ffffff55ffffffff
ffffffffffffffffffffffff77777777556567775d55555d5d55555d5d55555deeeeeeee5500066600556666760000000000000056660000ffffffffffffffff
ffffffffffffffffffffffff77777777565677775555d5555555d5555555d555eeeeeeee5550066600056666676000000000000056666000ffffffffffffffff
ffffffffffffffffffffffff777777775565677755d5555d55d5555d55d5555deeeeeeee5550066600056666666000000000000056666000ffff5ffffff5ffff
ffffffffffffffffffffffff7777777756567777444444444444444444444444eeeeeeee0556066000056666666000000000000005666600fffff555555fffff
f5ffffffffffffffffffff5577777777556567779999474499994c4499994744eeeeeeee055666600005666666600000000000000566660000ffffffffffff00
ff55fffffffffffffffff55f77777777565677779aa94c449aa947449aa94844eeeeeeee555666600000566666660000000000000555660000ffffffffffff00
ffff55555555555555555fff7777777755656777a9a94744a9a94844a9a94744eeeeeeee55506660000055555550000000000000000055000000ffffffff0000
ffffffffffffffffffffffff7777777756567777999a4844999a4744999a4c44eeeeeeee00000000000000000000000000000000000000000000ffffffff0000
877ff778977ff779877ff778a77ff77af77ff77ff77ff77f877ff778c77ff77ca77ff77ac77ff77cb77ff77bc77ff77c877ff778b77ff77bf77ff77ff77ff77f
875ff578975ff579875ff578a75ff57af75ff57ff75ff57f875ff578c75ff57ca75ff57ac75ff57cb75ff57bc75ff57c875ff578b75ff57bf75ff57ff75ff57f
8ff4fff89ff4fff98ff4fff8aff4fffafff4fffffff4ffff8ff4fff8cff4fffcaff4fffacff4fffcbff4fffbcff4fffc8ff4fff8bff4fffbfff4fffffff4ffff
88f4ff8899f4ff998ff4fff8aff4fffafff4fffffff4ffff88f4ff88ccf4ffccaaf4ffaaccf4ffccaaf4ffaaccf4ffcc88f4ff88aaf4ffaafff4fffffff4ffff
888888889999999988ffff88aaffffaaf988889ffc8888cf88888888c888888caaaaaaaacccccccc99999999cccccccc8888888899999999f888888ffbbbbbbf
884444889944449988444488aa4444aafa4444affc4444cf88444488c844448caa4444aacc4444cc88444488cc4444cc8844448888444488f844448ffb4444bf
08888880099999900ffffff00ffffff00affffa00cffffc00888888008cccc800aa88aa00cc88cc0088888800cccccc00888888008999980088888800bbbbbb0
008888000099990000ffff0000ffff0000ffff0000ffff00008888000088880000a88a0000c88c000088880000cccc0000888800008888000088880000bbbb00
877ff778877ff778877ff778f77ff77ff77ff77f877ff778877ff778f77ff77ff77ff77ff77ff77f877ff778877ff778f77ff77ff77ff77ff77ff77ff77ff77f
875ff578875ff578875ff578f75ff57ff75ff57f875ff578875ff578f75ff57ff75ff57ff75ff57f975ff579975ff579f75ff57ff75ff57ff75ff57ff75ff57f
8ff4fff88ff4fff88ff4fff8fff4fffffff4ffff8ff4fff88ff4fff8fff4ffffaaa4faaaccc4fccc8ff4fffaaff4fffafff4fffffff4fffffff4fffffff4ffff
88f4ff888cf4ffc888f4ff88fff4fffffff4ffff88f4ff888cf4ffc8fff4ffff9ff4fff9cff4fffcaff4fff9bff4fffbff94f9ffffc4fcff9ff4fff9cff4fffc
88888888cccccccc88888888ffffffffffffffff88888888ccccccccffffffff99888899ccccccccbffffffacffffffcf999999ffaaaaaaff988889ffccccccf
88444488cc4444cc8844448899444499cc4444cc88444488cc4444ccff4444ffff4444ffff4444ffff4444ffff4444ff99444499cc4444ccf844448ffc4444cf
088888800cccccc008888880099999900cccccc0088888800ccaacc00ffccff00ffffff00ffffff00ffffff00ffffff009ffff900cffffc00f8ff8f00fcffcf0
0088880000cccc00008888000099990000cccc000088880000caac0000fccf0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000f88f0000f88f00
b77ff77bc77ff77c877ff778877ff778f77ff77ff77ff77ff77ff77ff77ff77ff77ff77ff77ff77f000000000000000000000000000000000000000000000000
b75ff57bc75ff57c875ff578975ff579f75ff57ff75ff57ff75ff57ff75ff57ff75ff57ff75ff57f000000000000000000000000000000000000000000000000
bff4fffbcff4fffc8ff4fff8aff4fffafff4fffffff4fffffff4fffffff4fffffff4fffffff4ffff000000000000000000000000000000000000000000000000
bbf4ffbbccf4ffcc88f4ff88bcf4ffcbaff4fff8cff4fffcf994f99ffcc4fccffff4fffffff4ffff000000000000000000000000000000000000000000000000
9bbbbbb9cccccccc88888888cc9999ccb98fafabcccfcfcc99999999cccccccc88888888cccccccc000000000000000000000000000000000000000000000000
89444498cc4444cc88444488cc4444ccfb4444f8fc4444fc99444499cc4444cc89444498cc4444cc000000000000000000000000000000000000000000000000
089999800cccccc0088888800cccccc0089ba9800cccccc009ffff900cffffc00999999009999990000000000000000000000000000000000000000000000000
0088880000cccc000088880000cccc0000b9f80000ccfc0000ffff0000ffff000099990000999900000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001111116666666666577777666665666656666644444444444444444444444455555d555d55555d5d55555d3333333333333333333333335555555566666666
01777777666666666656666666666566665666664444444444444444444444445d55555d5555d5555555d555333333b33b3333333333333355511555cccccccc
17777777666666666657677676767566665666671444414444144441441444415555d55555d5555d55d5555d33333333333333333333333311166111cccccccc
177777775555555555666666666666556656666711111111111111111111111154444444444444444444444533333333333333333333b33366666666cccccccc
17777777666666666766666666666667665666678888888888888888888888884aa99999999948444444444433b33333333333333333333366666666c4cccc4c
177777776666666666666666666666776656666788e2eee2eeeee888888888884a99a99a9aa9474444444444333333333333bab33b33333366666666c455554c
177777776666666667666666666666676656666688e22e22e2ee22888888888849a9aa99a9a94c44444444443333333333333b3333b3333366666666c44cc44c
1777777766677776666666666666667766566666882e2ee2ee2e2e88888888884a99a99a999a4744444444443333333333333333333333336666666600000000
0000000066666666776666666666666666666566888888888888888888888888444444444444444455555d55444444445d55555d555115555555555566666666
00000000666666667666666666666676666665668cccc877778cccc8888888884ccccccc477774445d555555444444445555d555111551115551155577777777
00000000666666667766666666666666666665668cccc877768cccc8888888884ccc1ccc4677744455d555554444444455d5555d555555551116611177711777
00000000666666667666666666666676666665668cccc877768cccc8888888884ccd1ccc4677744455555d554444444444444445555115556666666677711777
00000000555555555566666666666655666665668cccc877768cccc8888888884cdd1ccc46777444555555554444444444444444111551116666666677711777
000000006666666666567676767675666666656688ccc877768ccc88888888884cd51ccc467774445d5555554444444444444444555555556966969677711777
00000000666666666656666666666566666665668888887776888888888888884d551ccc46777444555d555d4444444444444444555115556996499977711777
00000000666666666656666677777566666665668888887776888888888888884444444446777444555555554444444444444444111551116446644477711777
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ccc0000000ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0000000c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c0c0000000c0c00000c00c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c0ccc0cc00cc00cc0c00c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c0c0c0cc00c0c0cc00c00c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c0c0c0ccc0ccc0cc0cc0cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000cccc00000000000000000000000000000000000000008800000000
00000000000000000000000000000000000000000000000000000000000000000000000000cccc00000000000000000000000000000000000000888880000000
00000000000000000000000000000000000000000000000000000000000000000000000000ccccc0000000000000000000000000000000000008888880000000
0000000000000000000000000000000000000cccc000000000000000000000000000000000cccc00000000000000000000000000000000000008888880000000
000000000000000000000000000000000000ccccccc000000000000000000000000000000ccccc00000000000000000000000000000000000000888870000000
00000000000000000000000000000000000cccc00cc000000000000000000000000000000cc77000000000000000000000000000000000008800088777000000
0000000000000000000000000000000000ccccc0cc7000700000000000000000000000000cc77000000000000000000000888800000000008880777777000000
0000000000000000000000000000000000cccc00c77007700000000000000000000000000c777000000000000000000000888880000000087770777777000000
0000000000000000000000000000000000cccc00000007700000000000000000000000000c770000000000000000000008888880000008877700777770000000
0000000000000000000000000000000000cc770000000770000000000000000000000000077700000777700000000000888888800000077770000777c0000000
00000000000000000000000000000000007777000000078000000000000000000000000007700000077880000000000888008887000007700000077cc0000000
0000000000000000000000000000000000777700000008800000000000000000000000000770008888888000008888088800087700000770000000ccc0000000
0000000000000000000000000000000000077770000008800000000077000000cccc00000780088800888000088888888000077700007777cccc00ccc0000000
0000000000000000000000000000000000077777700008800000000077700000ccccc0007800088000000000088888888000077700007ccccc0000cc00000000
0000000000000000000000000000000000008888880008800000000777700000cccc700088000880000000000888088770000777000ccccc000000c700000000
0000000000000000000000000000000000000888880008800000000777cc00000c777700880008000000000008800077700007cc00ccc000000000c700000000
000000000000000000000000000000000000008888000880000000777ccc00000077770088000888888800000870007700000ccc00cc000000ccc07700000000
000000000000000000000000000000000000000888000877000000cccccccc000077770088000888888800000770007700000ccc00cc00000cc7007700000000
00000000000000000000000000000000000000087700077777000cccc00cc7000007788880000008880000000770007c00000cc000cc00000777000000000000
00000000000000000000000000000000000000077000777777000ccc000077700000888880000088000000000770000ccc000cc000c770007777000000000000
00000000000000000000000000000000000000077000770077700ccc777777700000888880000080000000000cc0000ccc00cc70000777777770008880000000
00000000000000000000000000000000077000077007770077c00cc7777777770000088880000770000000000cc0000ccc00c770000077777000088880000000
0000000000000000000000000000000077700777000777007cc00c7000000078000008877000777000077c000cc0000000007700000000000000088880000000
0000000000000000000000000000000077707770007cc000ccc00c70000000880000007770007770077cc00000cc000000000000000000000000008800000000
000000000000000000000000000000007777770000cc0000ccc007700000008800000077700077777ccc000000cc700000000000000000000000000000000000
00000000000000000000000000000000777770000ccc0000ccc0077800000088000000777000777cccc000000cc7700000000000000000000000000000000000
0000000000000000000000000000000000000000cccc0000ccc007880000008800000007000007cccc0000000c77000000000000000000000000000000000000
00000000000000000000000000000000000000000ccc000077000000000000880000000000000000000000000000000000000000000000000000000000000000
__label__
33333333333333333333333366566666666665663333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333b3333333b36656666666666566333333b333333333333333333333333333333333333333333b333333333333333333333333333333333333b3
33333333333333333333333366566667666665663333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
3333b33333333333333333336656666766666566333333333333b3333333b3333333b3333333b3333333b333333333333333b3333333b3333333b33333333333
3333333333b3333333b33333665666676666656633b3333333333333333333333333333333333333333333333333333333333333333333333333333333b33333
3b33333333333333333333336656666766666566333333333b3333333b3333333b3333333b3333333b3333333333bab33b3333333b3333333b33333333333333
33b33333333333333333333366566666666665663333333333b3333333b3333333b3333333b3333333b3333333333b3333b3333333b3333333b3333333333333
33333333333333333333333366566666666665663333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333366566666666665663333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
333333b3333333b33b3333336656666666666566333333b3333333b333333333333333333b333333333333b33333333333333333333333b333333333333333b3
33333333333333333333333366566667666665663333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
333333333333333333333333665666676666656633333333333333333333b3333333b33333333333333333333333b3333333b333333333333333b33333333333
33b3333333b3333333333333665666676666656633b3333333b3333333333333333333333333333333b33333333333333333333333b333333333333333b33333
33333333333333333333bab3665666676666656633333333333333333b3333333b3333333333bab3333333333b3333333b333333333333333b33333333333333
333333333333333333333b336656666666666566333333333333333333b3333333b3333333333b333333333333b3333333b333333333333333b3333333333333
33333333333333333333333366566666666665663333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333366566666666665663333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
333333b3333333b3333333b36656666666666566333333b33b333333333333b3333333b3333333b33b333333333333b3333333b3333333b3333333333b333333
33333333333333333333333366566667666665663333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333366566667666665663333333333333333333333333333333333333333333333333333333333333333333333333333b33333333333
33b3333333b3333333b33333665666676666656633b333333333333333b3333333b3333333b333333333333333b3333333b3333333b333333333333333333333
3333333333333333333333336656666766666566333333333333bab33333333333333333333333333333bab33333333333333333333333333b3333333333bab3
33333333333333333333333366566666666665663333333333333b3333333333333333333333333333333b3333333333333333333333333333b3333333333b33
33333333333333333333333366566666666665663333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333366566666666665663333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
333333b333333333333333b36656666666666566333333b33b33333333333333333333b3333333b333333333333333b3333333333333333333333333333333b3
33333333333333333333333366566667666665663333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
333333333333b33333333333665666676666656633333333333333333333b33333333333333333333333b333333333333333b3333333b3333333b33333333333
33b333333333333333b33333665666676666656633b33333333333333333333333b3333333b333333333333333b3333333333333333333333333333333b33333
333333333b333333333333336656666766666566333333333333bab33b33333333333333333333333b333333333333333b3333333b3333333b33333333333333
3333333333b333333333333366566666666665663333333333333b3333b33333333333333333333333b333333333333333b3333333b3333333b3333333333333
33333333333333333333333366566666666665663333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
444444444444444444444444665666666666656655555d5555555d5555555d553333333333333333333333333333333333333333333333333333333333333333
44444444444444444444444466566666666665665d5555555d5555555d55555533333333333333b3333333b3333333b3333333b3333333b33b33333333333333
444444444444444444444444665666676666656655d5555555d5555555d555553333333333333333333333333333333333333333333333333333333333333333
444444444444444444444444665666676666656655555d5555555d5555555d553333b3333333333333333333333333333333333333333333333333333333b333
44444444444444444444444466566667666665665555555555555555555555553333333333b3333333b3333333b3333333b3333333b333333333333333333333
44444444444444444444444466566667666665665d5555555d5555555d5555553b33333333333333333333333333333333333333333333333333bab33b333333
4444444444444444444444446656666666666566555d555d555d555d555d555d33b33333333333333333333333333333333333333333333333333b3333b33333
44444444444444444444444466566666666665665555555555555555555555553333333333333333333333333333333333333333333333333333333333333333
444444444444444444444444665666666666656655555d555d555d55555d555d3333333333333333333333333333333333333333333333333333333333333333
44444444444444444444444466566666666665665d55555d55555555d555d555333333333333333333333333333333b3333333b333333333333333b333333333
14444144441444414414444166566667666665665555d55555d555d5555d555d3333333333333333333333333333333333333333333333333333333333333333
11111111111111111111111166566667666665665444444444444444444444453333b3333333b3333333b33333333333333333333333b333333333333333b333
88888888888888888888888866566667666665664aa99999999999994844444433333333333333333333333333b3333333b333333333333333b3333333333333
88e2eee2eeeee8888888888866566667666665664a99a99a9aa99aa9474444443b3333333b3333333b33333333333333333333333b333333333333333b333333
88e22e22e2ee228888888888665666666666656649a9aa99a9a9a9a94c44444433b3333333b3333333b33333333333333333333333b333333333333333b33333
882e2ee2ee2e2e888888888866566666666665664a99a99a999a999a474444443333333333333333333333333333333333333333333333333333333333333333
88888888888888888888888866566666666665664444444444444444444444443333333333333333333333333333333333333333333333333333333333333333
8cccc877778cccc88888888866566666666665664ccccccc4777744444444444333333b3333333b33b333333333333b3333333b3333333333333333333333333
8cccc877768cccc88888888866566667666665664ccc1ccc46777444444488843553399333223333333333333333333333333333333333333333333333333333
8cccc877768cccc88888888866566667666665664ccd1ccc467774444ff44ff434433ff33ff233333333333333333333333333333333b3333333b3333333b333
8cccc877768cccc88888888866566667666665664cdd1ccc46777ff444f44494334333f3331333333333333333b3333333b33333333333333333333333333333
88ccc877768ccc888888888866566667666665664cd51ccc467774944ddd499931113f3f311133333333bab333333333333333333b3333333b3333333b333333
88888877768888888888888866566666666665664d551ccc467779994fdf4f9f34143f3f3f1f333333333b33333333333333333333b3333333b3333333b33333
88888877768888888888888866566666666665664444444446777fcf441444c43353331333433333333333333333333333333333333333333333333333333333
66666666666666666666666666577777666665666666666666666dc662166dc6625664166d466666666666666666666666666666666666666666666666666666
66666666666666666666666666566666666665666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666576776767675666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555555555555555555666666666666555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
66666666666666666666666667666666666666676666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666776666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666667666666666666676666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66677776666777766667777666666666666666776667777666677776666777766667777666677776666777766667777666677776666777766667777666677776
66666666666666666666666677666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666676666666666666766666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666677666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666676666666666666766666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555555555555555555666666666666555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
66666666666666666666666666567676767675666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666566666666665666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666566666777775666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111cccc111111111111111111111111111111111111111188111111111111111111111111111111111111111
1111111111111111111111111111111111111111111cccc111111111111111111111111111111111111118888811111111111111111111111111111111111111
1111111111111111111111111111111111111111111ccccc11111111111111111111111111111111111188888811111111111111111111111111111111111111
111111cccc111111111111111111111111111111111cccc111111111111111111111111111111111111188888811111111111111111111111111111111111111
11111ccccccc111111111111111111111111111111ccccc111111111111111111111111111111111111118888711111111111111111111111111111111111111
1111cccc11cc111111111111111111111111111111cc771111111111111111111111111111111111188111887771111111111111111111111111111111111111
111ccccc1cc7111711111111111111111111111111cc771111111111111111111118888111111111188817777771111111111111111111111111111111111111
111cccc11c77117711111111111111111111111111c7771111111111111111111118888811111111877717777771111111111111111111111111111111111111
111cccc11111117711111111111111111111111111c7711111111111111111111188888811111188777117777711111111111111111111111111111111111111
111cc771111111771111111111111111111111111177711111777711111111111888888811111177771111777c11111111111111111111111111111111111111
1117777111111178111111111111111111111111117711111177881111111111888118887111117711111177cc11111111111111111111111111111111111111
111777711111118811111111111111111111111111771118888888111118888188811187711111771111111ccc11111111111111111111111111111111111111
111177771111118811111111177111111cccc11111781188811888111188888888111177711117777cccc11ccc11111111111111111111111111111111111111
111177777711118811111111177711111ccccc1117811188111111111188888888111177711117ccccc1111cc111111111111111111111111111111111111111
111118888881118811111111777711111cccc711188111881111111111888188771111777111ccccc111111c7111111111111111111111111111111111111111
111111888881118811111111777cc11111c777711881118111111111118811177711117cc11ccc111111111c7111111111111111111111111111111111111111
11111118888111881111111777ccc11111177771188111888888811111871117711111ccc11cc111111ccc177111111111111111111111111111111111111111
11111111888111877111111cccccccc111177771188111888888811111771117711111ccc11cc11111cc71177111111111111111111111111111111111111111
1111111187711177777111cccc11cc7111117788881111118881111111771117c11111cc111cc111117771111111111111111111111111111111111111111111
1111111177111777777111ccc111177711111888881111188111111111771111ccc111cc111c7711177771111111111111111111111111111111111111111111
1111111177111771177711ccc777777711111888881111181111111111cc1111ccc11cc711117777777711188811111111111111111111111111111111111111
1177111177117771177c11cc7777777771111188881111771111111111cc1111ccc11c7711111777771111888811111111111111111111111111111111111111
177711777111777117cc11c7111111178111118877111777111177c111cc11111111177111111111111111888811111111111111111111111111111111111111
177717771117cc111ccc11c71111111881111117771117771177cc11111cc1111111111111111111111111188111111111111111111111111111111111111111
17777771111cc1111ccc117711111118811111177711177777ccc111111cc7111111111111111111111111111111111111111111111111111111111111111111
1777771111ccc1111ccc1177811111188111111777111777cccc111111cc77111111111111111111111111111111111111111111111111111111111111111111
111111111cccc1111ccc117881111118811111117111117cccc1111111c771111111111111111111111111111111111111111111111111111111111111111111
1111111111ccc1111771111111111118811111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117771111117717771777177711111777171711111777177717171777111117771717177717711717
11111111111111111111111111111111111111111111111117171111171117171777171111111717171711111777117117171711111117171717171717171717
11111111111111111111111111111111111111111111111117771111171117771717177111111771177711111717117117711771111117771717177117171777
11111111111111111111111111111111111111111111111117171111171717171717171111111717111711111717117117171711111117111717171717171117
11111111111111111111111111111111111111111111111117171111177717171717177711111777177711111717177717171777111117111177171717771777
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111777117717771111171717771771177717771777111117771777177711111777177717771777
11111111111111111111111111111111111111111111111111111711171717171111171711711717117117111717111111711717177711111117171711171717
11111111111111111111111111111111111111111111111111111771171717711111171711711717117117711771111111711777171711111777171717771717
11111111111111111111111111111111111111111111111111111711171717171111177711711717117117111717111111711717171711111711171717111717
11111111111111111111111111111111111111111111111111111711177117171111177717771717117117771717111117711717171711111777177717771777
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

__gff__
0000000000000804020100000000010101010000000000000000010101010101010100010000000000000101010101010101000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008
__map__
000000000000000000000000343333338d8b8b84948b8d8d8d8d8d8c8d8d8d8b3300000d0d0d0d0d0d0d0d00003433333333181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000343333338b8b8c84948b8b8d8d8c8b8d8d8b8d8b33000d0d0d0d0d0d0d0d0d0d003433333333181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000060606060606000000343333338b8b8b84948b8c8b8b8b8c8b8b8b8d8c33000d0d0d0d0d0d0d0d0d0d003433333333181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000006060606060606060000343333338b8d8b84948b8c8d8b8b8d8b8d8d8d8b330d0d0d0d0d0d0d0d0d0d0d0d3433333333181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000601010101010106060600343333339b9b9b84949a9a9a8d8b8b9d9d9d9d9d330d0d01010101010101010d0d3433333333181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060114150101040501060034333333858687849488898a8d8d8d8e8e9e8e8e330d0d01141501010405010d0d3433333333181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010102030101020301010034333333959697849498999b8b8b8c8f8f9f8f8f330d010102030101020301010d3433333333181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001011213010112130101003433333381818182838181818181818181818181330001011213010112130101003433333333282828282828282828282828282800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001010101100101010101003433333391919192939191919191919191919191330001010101100101010101003433333333383838383838383838383838383800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000001010111010101010000343333330d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d330000010101110101010100003433333333383838383838383838383838383800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000001010101010101010000343333330d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d330000010101010101010100003433333333383838383838383838383838383800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000001013031313201010000343333330d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d330000010130313132010100003433333333383838383838383838383838383800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000010101010101000000343333330d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d33a0a1a20101010101010000003433333333383838383838383838383838383800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000101010100000000343333330d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d330000000001010101000000003433333333383838383838383838383838383800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000343333330d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d330000000000000000000000003433333333383838383838383838383838383838000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000343333330d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d330000000000000000000000003433333333383838383838383838383838383838000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000033333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001a1501c1501c1501c1501d1501d1501d1501c150161500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000041000410004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000041002410014100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000041001410034100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000155001530015200151001550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000155001530035200351000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300002853026130265302853000000000001353011530000001353011530285302653000000000002653028530285301353000000000001553013530265302853000000000000000026530245302353021530
00100000100201002000000120201302010020000000e0200f02000000000000e0200e020160201702016020160201102010020000000e0200e02010020160201102015020140200000011020000001002000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021020240202202024020220202402023020210200000000000
0010000000000180201a020000001d0201c0201a02000000000001d0201c0201a020000001f0200000000000000002102000000000000000021020000001f02000000000001c020000001a020000001702000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000280200000028020000000000028020260202402000000000000000000000
00010000200502205024050260502705028050280502805028050280502a050280502705026050220502505023050230502205021050200500000000000000000000000000000000000000000000000000000000
__music__
02 06424344
00 07084344
01 07094344
02 07090a44
00 01424344

