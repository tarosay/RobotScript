------------------------------------------
-- MFS Droid
------------------------------------------
--関数宣言--------------------------------
main={}              --mainメソッド
setTateGamen={}      --縦向きに変更
print={}             --スクロールするテキスト表示
sendcmd={}           --コマンドを送信します
waitgetHttp={}     --http.getするのを待ちます
iniSprite={}       --スプライトを定義します

--グローバル変数宣言----------------------
SockNum = 1
Gw,Gh = 320,480  --画面のサイズを取得
Clr_W = color(255,255,255)
Clr_B = color(0,0,0)
Clr_R = color(255,0,0)
Droid = { head={x=0,y=0}, body={x=0,y=0}, leg={x=0,y=0}, larm={x=0,y=0}, rarm={x=0,y=0}, sc=0.60 }
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
		sock.nsend( 1, cmd, 2 ) 
		if( cmd:sub(1,1)=="Q" )then break end
		txt, ret = sock.nrecv( 1 )
		--print( txt..","..ret )
		if( txt==cmd:sub(1,1) )then break end
		print( "コマンド送信に失敗しました" )
		--dialog( "","コマンド送信に失敗しました",1 )
	end
    psec=system.getSec() + sec -0.4
    while psec>system.getSec() do	end
end
------------------------------------------
--http.getするのを待ちます
-- Error:-1
------------------------------------------
function waitgetHttp()
	local s = http.status()
	while( s==0 )do	--ファイルを取得するまで待ちます。
		s = http.status()
	end
	if( s~=1 )then
		if( s==2 )then
			toast( "URLのプロトコルが開けません" )
		elseif( s==3 )then
			toast( "接続できない、またはURLが見つかりません" )
		elseif( s==4 )then
			toast( "データ取得時にエラーが発生しました" )
		elseif( s==5 )then
			toast( "保存ファイルが開けませんでした" )
		elseif( s==6 )then
			toast( "接続がタイムアウトしました" )
		else
			toast( "httpスレッド起動時にエラーが発生しました" )
		end
		return -1
	end
	return 0
end
------------------------------------------
--スプライトを定義します
------------------------------------------
function iniSprite()
--[[
	--画像をダウンロードしておく
	http.get( "http://192.168.1.100/robot/mfsdroid.png", system.getAppPath().."/mfsdroid.png" )
	--画像ファイルのダウンロードチェック
	if( waitgetHttp()==-1 )then
		return
	end
	print( "mfsdroid.pngダウンロードしました" )
--]]
	--ワークエリア画面をクリアします
	canvas.workCls()
	local gwid, ghei = canvas.getBmpSize(system.getAppPath().."/mfsdroid.png")
	--ワークエリアに画像を読み込みます
	if( canvas.loadBmp( system.getAppPath().."/mfsdroid.png", 0, 0, gwid-1, ghei-1)==-1)then
		print( "", "ロードに失敗しました",1 )
		system.exit()
	end

	--スプライトに登録します
	sprite.init()  --初期化
	--スライド下絵定義
	sprite.define( 1, 473, 19, 496, 308 )
	sprite.move( 1, 2, 463, 147 )
	--カメラボタン定義
	sprite.define( 2, 428, 217, 473, 308 )
	sprite.move( 2, 2, 410, 245)
	--終了ボタン定義
	sprite.define( 3, 428, 125, 473, 216 )
	sprite.move( 3, 2, 410, 150 )
	--スライドつまみ定義
	sprite.define( 4, 428, 95, 451, 125 )
	sprite.move( 4, 2, 463, 147 )

	local dx = 10
	local dy = -2
	--local sc = 0.58
	--ドロイド頭
	Droid.head.x = 94+dx
	Droid.head.y = 158+dy
	sprite.define( 5, 10, 67, 119, 246 )
	sprite.move( 5, 2, Droid.head.x, Droid.head.y, Droid.sc, Droid.sc )

	--ドロイド体
	Droid.body.x = 193+dx
	Droid.body.y = 160+dy
	sprite.define( 6, 152, 67, 326, 247 )
	sprite.move( 6, 2, Droid.body.x, Droid.body.y, Droid.sc, Droid.sc )

	--ドロイド足
	Droid.leg.x = 280+dx
	Droid.leg.y = 160+dy
	sprite.define( 7, 359, 102, 426, 212 )
	sprite.move( 7, 2, Droid.leg.x, Droid.leg.y, Droid.sc, Droid.sc )

	--右手
	Droid.rarm.x = 118+dx
	Droid.rarm.y = 237+dy
	sprite.define( 8, 47, 278, 176, 314 )
	sprite.move( 8, 2, Droid.rarm.x, Droid.rarm.y, Droid.sc, Droid.sc )

	--左手
	Droid.larm.x = 177+dx
	Droid.larm.y = 79+dy
	sprite.define( 9, 145, 0, 274, 35 )
	sprite.move( 9, 2, Droid.larm.x, Droid.larm.y, Droid.sc, Droid.sc )

	sprite.put()
	canvas.putflush()
	
end
------------------------------------------
--メインプログラム
------------------------------------------
function main()
	--画面を縦向きに変更
	--setTateGamen()

	canvas.drawCls( color(255,255,255) ) --背景を白色に
	system.setSleep(0) --スリープしない

	--スプライトを定義します
	iniSprite()
	
	--60101ポートへの接続を10秒間待つ
	local ret = sock.nlistenOpen( SockNum, 60101, 5 ) 
	if( ret~=1 )then
		print( "adb接続に失敗しました。終了します" )
		system.exit()
	end
--]]	

	local cmd
	local po = 0
	local bpo = 0
	local dat, st
	local cenX = 463
	local cenY = 147
	local x,y,s
	local st={}
	local cs, bcs = "S", "S"
	local ntime
	local ntFlg = 1
	local i
	local spp = 0
	local dtime = system.getSec() + 0.5
	while(true)do
	
		--100ms毎に処理をまわします
		ntime = system.getSec() + 0.1
		while( ntime>system.getSec())do
			x,y,s=touch()
			if( ntFlg==1 and y==0 )then
				x,y = cenX,cenY
			elseif( ntFlg==1 and y~=0)then
				ntFlg = 0
			end
			
			if(y<2 or y>60000)then
				--canvas.drawTextRotate( y, 380, 60, 270, 40, Clr_B )
				y = 2
			elseif(y>292)then
				--canvas.drawTextRotate( y, 380, 60, 270, 40, Clr_B )
				y = 292
			end
		end
		
		st = sprite.touch( 2, 3 )
		if( st[1]==2 )then
			cmd = "C"..string.char(1)
			sendcmd( cmd, 0.1 )
			sock.nclose( SockNum )
			--カメラボタン
			system.expCall("com.momoonga.incamera.IncameraActivity")
			system.exit()
		elseif( st[1]==3 )then
			--停止ボタン
			x,y = cenX,cenY
		end

		--ボタンエリアにタッチされているとき
		if( x>441)then
			po = math.floor((292-y)/290*510) - 255
			canvas.putCls(Clr_W)  --画面消去
			sprite.move( 4, 2, cenX, y )
			sprite.put()
		elseif( x>387 and x<442 and y>=0 and y<103)then
			--終了する
			break
		end
		canvas.drawTextRotate( po, 410, 60, 270, 40, Clr_B )
		
		--for i=1,3 do
		--	spp = bpo - math.floor((bpo - po)*i/3)
			spp = po
			if( spp>0 )then
				--正転
				cs = "F"
			elseif( spp<0)then
				--後退
				spp = -spp
				cs = "B"
			else
				--停止
				spp = 1
				cs = "S"
			end

			--新規のコマンドであれば送信します
			if( cs~=bcs or spp~=bpo )then
				cmd = cs..string.char(spp)
				sendcmd( cmd, 0.1 )
				bcs = cs
				bpo = spp
			end
			
			if( spp==0 or spp==1 )then
				sprite.move( 5, 2, Droid.head.x, Droid.head.y, Droid.sc, Droid.sc )
				sprite.move( 6, 2, Droid.body.x, Droid.body.y, Droid.sc, Droid.sc )
				sprite.move( 7, 2, Droid.leg.x, Droid.leg.y, Droid.sc, Droid.sc )
				sprite.move( 8, 2, Droid.rarm.x, Droid.rarm.y, Droid.sc, Droid.sc )
				sprite.move( 9, 2, Droid.larm.x, Droid.larm.y, Droid.sc, Droid.sc )
				sprite.put()
			else
				if( dtime<system.getSec() )then
					--sprite.move( 5, (math.random(2)-1)*2, Droid.head.x, Droid.head.y, Droid.sc, Droid.sc )
					sprite.move( 6, (math.random(2)-1)*2, Droid.body.x, Droid.body.y, Droid.sc, Droid.sc )
					sprite.move( 7, (math.random(2)-1)*2, Droid.leg.x, Droid.leg.y, Droid.sc, Droid.sc )
					sprite.move( 8, (math.random(2)-1)*2, Droid.rarm.x, Droid.rarm.y, Droid.sc, Droid.sc )
					sprite.move( 9, (math.random(2)-1)*2, Droid.larm.x, Droid.larm.y, Droid.sc, Droid.sc )
					sprite.put()
					dtime = system.getSec() + 0.5
				end
			end
		--end
	end
	
	--ポンプ停止
	cmd = "S"..string.char(1)
	sendcmd( cmd, 1 )
	--コネクト待ちモード
	cmd = "C"..string.char(1)
	sendcmd( cmd, 0.1 )
	
	sock.nclose( SockNum )
end
main()
system.exit()
