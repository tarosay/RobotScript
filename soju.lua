------------------------------------------
-- 操縦されます
------------------------------------------
--関数宣言--------------------------------
main={}                --mainメソッド
setTateGamen={} --縦向きに変更
print={}                 --スクロールするテキスト表示
sendcmd={}          --コマンドを送信します

--グローバル変数宣言----------------------
SockADB = 1
SockPC = 2
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
	print( "MicroBridgeと接続しました: "..sock.ngetAddress(SockADB) )

	local cmd
	--60102ポートからの接続を20秒間待つ
	print( "Androidとの接続を待ちます")
	local ret = sock.nconnectOpen( SockPC, "192.168.0.200", 60102, 20 ) 
	--local ret = sock.nconnectOpen( SockPC, "192.168.24.55", 60102, 20 ) 
	--local ret = sock.nconnectOpen( SockPC, "192.168.1.103", 60102, 20 ) 
	--local ret = sock.nlistenOpen( SockPC, 60102, 20 ) 
	if( ret~=1 )then
		dialog( "Android端末との接続に失敗しました", "終了します" , 1 )
		cmd = "C"..string.char(1)
		sendcmd( cmd, 0.1 )
		sock.nclose(SockADB)
		system.exit()
	end
	--接続できたことを表示する
	print( "Android端末と接続しました: "..sock.ngetAddress(SockPC) )
	
	local bye=0
	local dat, st
	while(true)do
		st = 0
		while(st<=0)do
			cmd, st = sock.nrecv( SockPC, 1 )
		end
		if( cmd=="Q" )then
			cmd = "Q"..string.char(1)
			sendcmd( cmd, 0.1 )
			break
		end
		sendcmd( cmd, 0.1 )
	end
	sock.nclose(SockPC)
	sock.nclose(SockADB)
end
main()
system.exit()
