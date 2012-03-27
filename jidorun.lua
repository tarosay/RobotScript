------------------------------------------
-- センサのデータを送信します
------------------------------------------
--関数宣言--------------------------------
main={}                --mainメソッド
setTateGamen={} --縦向きに変更
print={}                 --スクロールするテキスト表示
sendcmd={}          --コマンドを送信します
iniRiBuf={}             --リングバッファの初期化
getAcc={}              --加速度センサ値の取得

--グローバル変数宣言----------------------
--RbModulePath = system.getAppPath().."/rbmodule.txt"
SockADB = 1
SockPC = 2
Ac={ xbuf={}, ybuf={}, zbuf={}, cnt=1, max=5 }
------------------------------------------
mt={}
mt.__newindex=function(mtt,mtn,mtv)
	dialog( "Error Message", "宣言していない変数 "..mtn.." に値を入れようとしています", 0 )
	toast("画面タッチで実行を続けます", 1)
	touch(3)
end
mt.__index=function(mtt,mtn)
	dialog( "Error Message", "変数 "..mtn.." は宣言されていません", 0 )
	toast("画面タッチで実行を続けます", 1)
	touch(3)
end
setmetatable(_G,mt)
--------以下が実プログラム----------------
------------------------------------------
--加速度センサ値の取得
------------------------------------------
function getAcc()
local i
	Ac.xbuf[Ac.cnt], Ac.ybuf[Ac.cnt] , Ac.zbuf[Ac.cnt] = sensor.getAccel()
	Ac.cnt = Ac.cnt + 1
	if( Ac.cnt>Ac.max )then Ac.cnt = 1 end
	local x = 0
	local y = 0
	local z = 0
	for i=1, Ac.max do
		x = x + Ac.xbuf[i]
		y = y + Ac.ybuf[i]
		z = z + Ac.zbuf[i]
	end
	return math.floor(x/Ac.max*1000+0.5)/1000, math.floor(y/Ac.max*1000+0.5)/1000, math.floor(z/Ac.max*1000+0.5)/1000
end
------------------------------------------
--リングバッファの初期化
------------------------------------------
function iniRiBuf()
local i, j
	for j=1, 100 do
		for i=1, Ac.max do
			Ac.xbuf[i], Ac.ybuf[i] , Ac.zbuf[i] = sensor.getAccel()
		end
	end
	Ac.cnt = 1
end
------------------------------------------
--縦向きに変更
------------------------------------------
function setTateGamen()
	system.setScreen(1)
	--内部グラフィック画面設定の変更
	local w,h = canvas.getviewSize()
	canvas.setMainBmp( w, h )
end
------------------------------------------
--スクロールするテキスト表示
-- 文字, サイズ, 色, 背景色
------------------------------------------
function print(...)
local w, h = canvas.getviewSize()  --画面サイズ取得
 local t={...}
 local str = t[1]
 if( str==nil )then str = "" end
 local fontsize = t[2]
 if( fontsize==nil )then fontsize = 18 end
 local fcolor = t[3]
 if( fcolor==nil )then fcolor = color(0,0,0) end
 local bcolor = t[4]
 if( bcolor==nil )then bcolor = color(255,255,255) end
 --一度、見えないところにテキストを書いて、改行数を求める
 local sc = canvas.putTextBox( str, 0, h+1, fontsize, fcolor, w )
 --画面の絵をワークエリアに取り込みます
 canvas.getg( 0, fontsize*sc, w-1, h-1, 0, fontsize*sc, w-1, h-1 )
 --取り込んだ画面をスクロールさせて描きます
 canvas.putg( 0, 0, w-1, h-fontsize*sc-1, 0, fontsize*sc, w-1, h-1 )
 --書き出す部分をバックカラーで塗り潰します
 canvas.putRect(  0, h-fontsize*sc-1, w, h, bcolor, 1 )
 --スクロールしたところにテキストを書きます
 canvas.drawTextBox( str, 0, h-fontsize*sc, fontsize, fcolor, w )
end
------------------------------------------
--コマンドを送信します
------------------------------------------
function sendcmd( cmd, sec )
local txt, ret,psec
    while( true )do
		--print( cmd:sub(1,1) )
		sock.nsend( SockADB, cmd, 2 ) 
		if( cmd:sub(1,1)=="Q" )then break end
		txt, ret = sock.nrecv( SockADB )
		--print( txt..","..ret )
		if( txt==cmd:sub(1,1) )then break end
		print( "コマンド送信に失敗しました" )
	end
    psec=system.getSec() + sec -0.4
    while psec>system.getSec() do	end
end
------------------------------------------
--メインプログラム
------------------------------------------
function main()
	--画面を縦向きに変更
	setTateGamen()

	canvas.drawCls( color(255,255,255) ) --背景を白色に
	system.setSleep(0) --スリープしない

	--60101ポートへの接続を5秒間待つ
	local ret = sock.nlistenOpen( SockADB, 60101, 5 ) 
	if( ret~=1 )then
		dialog( "adb接続に失敗しました", "終了します" , 1 )
		system.exit()
	end
	--接続できたことを表示する
	print( "MicroBridgeと接続しました")
--[[
	--60102ポートへの接続を5秒間待つ
	local ret = sock.nconnectOpen( SockPC, "192.168.24.98", 60102 ) 
	if( ret~=1 )then
		dialog( "PC接続に失敗しました", "終了します" , 1 )
		system.exit()
	end
	--接続できたことを表示する
	print( "PCと接続しました")
--]]
	--加速度センサ起動
	sensor.setdevAccel(1)
	--リングバッファの初期化
	iniRiBuf()

	local cmd
	local p = 50
	cmd = "F"..string.char(p)
	sendcmd( cmd, 0.1 )

	local x, y, z
	--local dat
	--今の時間取得
	local ntime
	local etime = system.getSec() +60.0
	local bx, by, bz
	bx, by, bz = getAcc()
	while(system.getSec()<etime)do
		x,y,z =  getAcc()
		--print( "x="..x.." y="..y.." z="..z )
		--dat = tostring(y)..","..tostring(z)..","..tostring(by-y)..","..tostring(bz-z).."/"
		--sock.nsend( SockPC, dat, dat:len() )
		
		--0.18sec待つ
		ntime = system.getSec() + 0.18
		while(system.getSec()<ntime)do end

		if( by-y>0.50 )then
			--回転する
			cmd = "R"..string.char(p)
			sendcmd( cmd, 4.7 )

			--1.0秒考える
			cmd = "S"..string.char(p)
			sendcmd( cmd, 1.0 )

			--再び前進する
			cmd = "F"..string.char(p)
			sendcmd( cmd, 0.1 )
			--sock.nsend( SockPC, "0,0,0/", 6 )
			x,y,z =  getAcc()
		end
		bx,by,bz = x,y,z
	end

	cmd = "S"..string.char(p)
	sendcmd( cmd, 0.2 )

	cmd = "C"..string.char(p)
	sendcmd( cmd, 0.2 )

	--加速度センサ終了
	sensor.setdevAccel(0)
	
	--sock.nclose(SockPC)
	sock.nclose(SockADB)
	
	--dialog("", "Exit", 1)
end
main()
system.exit()
