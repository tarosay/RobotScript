------------------------------------------
-- 操縦されます
------------------------------------------
--関数宣言--------------------------------
main={}                --mainメソッド
setTateGamen={} --縦向きに変更
print={}                 --スクロールするテキスト表示
sendcmd={}          --コマンドを送信します
waitgetHttp={}     --http.getするのを待ちます
IniPicture={}         --画像の初期化


--グローバル変数宣言----------------------
SockNum = 1
Gw,Gh = 320,480  --画面のサイズを取得
Clr_W = color(255,255,255)
Clr_B = color(0,0,0)
Clr_R = color(255,0,0)

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
	Gw, Gh = canvas.getviewSize()  --画面のサイズを取得
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
--画像の初期化
------------------------------------------
function IniPicture()
	--矢印画像をダウンロード
--	http.get( "http://192.168.24.99/robot/yajirushi.png", system.getAppPath().."/yajirushi.png" )
	--ダウンロードチェック
--	if( waitgetHttp()==-1 )then
--		dialog("","ダウンロードに失敗しました",1)
--		return
--	end
--	print( "ダウンロードしました" )

	--ワークエリアを初期化します
	canvas.workCls()
	--画像を読み込みます
	local pwid, phei = canvas.getBmpSize(system.getAppPath().."/yajirushi.png")
	if( canvas.loadBmp( system.getAppPath().."/yajirushi.png", 0, 0, pwid-1, phei-1 )==-1)then
		dialog( "", "ロードに失敗しました",1 )
		system.exit()
	end
	--十字と丸を描いてワークエリアに取り込みます
	--MainBMPを透明色に塗りつぶす
	canvas.putCls()
	local cenX = Gw/2
	local cenY = Gh/2
	--十字を描く
	canvas.putRect( cenX-cenX/7, cenY-3, cenX+cenX/7, cenY+3, Clr_B, 1)
	canvas.putRect( cenX-3, cenY-cenY/7, cenX+3, cenY+cenY/7, Clr_B, 1)
	--十字をWorkBMPに取り込む
	canvas.getg( cenX-cenX/7,cenY-cenY/7,cenX+cenX/7,cenY+cenY/7, 0, phei, cenX/7*2,phei+cenY/7*2 )
	--丸を描く
	canvas.putCls()
	local r = 35
	canvas.putCircle( r, r, r, Clr_R, 1 )
	--丸をWorkBMPに取り込む
	canvas.getg( 0,0,2*r,2*r, 0, phei+cenY/7*2+1, 2*r,phei+cenY/7*2+1+2*r )
	--×アイコン描画
	local i
	canvas.putCls()
	for i=0,5 do
		canvas.putRect( i, i, 50-i, 50-i, Clr_B )
		canvas.putLine( i, 0, 50, 50-i, Clr_B)
		canvas.putLine( 0, i, 50-i, 50, Clr_B)
		canvas.putLine( i, 50, 50, i, Clr_B)
		canvas.putLine( 0, 50-i, 50-i, 0, Clr_B)
	end
	--×アイコンをWorkBMPに取り込む
	canvas.getg( 0,0,50,50, 0, phei+cenY/7*2+1+2*r+1, 50, phei+cenY/7*2+1+2*r+51 )

	--取り込み画像の確認
--	canvas.putCls(color(255,255,0))
--	canvas.putg( 0, 0, Gw-1, Gh-1, 0, 0, Gw-1, Gh-1 )
--	canvas.putflush()
--	touch(3)
	
	--スプライトに登録します
	sprite.init()  --初期化
	--上矢印定義
	sprite.define( 1, 0, 0, 71, 84 )
	sprite.move( 1, 2, cenX, cenY-cenY/7-(cenY-cenY/7)/2 )
	--下矢印定義
	sprite.define( 2, 72, 0, 143, 84 ) 
	sprite.move( 2, 2, cenX, cenY+cenY/7+(cenY-cenY/7)/2 )
	--左回転矢印定義
	sprite.define( 3, 144, 0, 238, 84 )
	sprite.move( 3, 2, cenX-cenX/7-(cenX-cenX/7)/2, cenY )
	--右回転矢印定義
	sprite.define( 4, 239, 0, 333, 84 ) 
	sprite.move( 4, 2, cenX+cenX/7+(cenX-cenX/7)/2, cenY )
	--十字定義
	sprite.define( 5, 0, phei, cenX/7*2, phei+cenY/7*2 )
	sprite.move( 5, 2, cenX, cenY )
	--xアイコン定義
	sprite.define( 6, 0, phei+cenY/7*2+1+2*r+1, 50, phei+cenY/7*2+1+2*r+51 )
	sprite.move( 6, 2, 50, 50 )
	--丸定義
	sprite.define( 7, 0, phei+cenY/7*2+1, 2*r, phei+cenY/7*2+1+2*r  )
	--sprite.move( 7, 1, cenX, cenY )
	--sprite.put()
end

------------------------------------------
--メインプログラム
------------------------------------------
function main()
	--画面を縦向きに変更
	setTateGamen()
	canvas.putCls(Clr_W)  --画面消去

	system.setSleep(0) --スリープしない
--
	--60102ポートへの接続を60秒間待つ
	print( "ロボットとの接続を待ちます")
	local ret = sock.nlistenOpen( SockNum, 60102, 60 ) 
	--local ret = sock.nconnectOpen( SockNum, "192.168.24.54", 60102, 60 ) 
	if( ret~=1 )then
		dialog( "ロボットへの接続に失敗しました", "終了します" , 1 )
		system.exit()
	end
	--接続できたことを表示する
	dialog( "ロボットと接続しました", "IP: "..sock.ngetAddress(SockNum), 1)
--]]

	--画像の初期化
	IniPicture()

	local cmd
	local po = 0
	local bpo
	local dat, st
	local cenX = Gw/2
	local cenY = Gh/2
	local x,y,s
	local st={}
	local cs, bcs = "S", "S"
	local ntime
	while(true)do
		--100ms毎に処理をまわします
		ntime = system.getSec() + 0.2
		while( ntime>system.getSec())do
			x,y,s=touch()
			if(s==1 or x<0 or y<0 or x>=Gw or y>=Gh)then
				x,y = cenX,cenY
			end
		end

		canvas.putCls(Clr_W)  --画面消去
		sprite.move( 7, 1, x, y )
		sprite.put()
		canvas.putLine( cenX, cenY, x, y, Clr_R)
		canvas.putLine( cenX+1, cenY+1, x+1, y+1, Clr_R)
		canvas.putLine( cenX+1, cenY-1, x+1, y-1, Clr_R)
		canvas.putLine( cenX-1, cenY-1, x-1, y-1, Clr_R)
		canvas.putflush()
		--6番スプライト(Xマーク)にタッチしたら終了
		st = sprite.touch(6)
		if( #st>0 )then break end
		
		if( y<Gh/Gw*x and y<Gh-Gh/Gw*x and y<cenY-cenY/7)then
			--前進
			--print( "前進" )
			po = (cenY-y)/cenY*100
			cs = "F"
		elseif( y>=Gh/Gw*x and y>=Gh-Gh/Gw*x and y>cenY+cenY/7)then
			--後退
			--print( "後退" )
			po = (y-cenY)/cenY*100
			cs = "B"
		elseif( y>=Gh/Gw*x and y<Gh-Gh/Gw*x and x<cenX-cenX/7)then
			--左回転
			--print( "左回転" )
			po = (cenX-x)/cenX*100
			cs = "L"
		elseif( y<Gh/Gw*x and y>=Gh-Gh/Gw*x and x>cenX+cenX/7)then
			--右回転
			--print( "右回転" )
			po = (x-cenX)/cenX*100
			cs = "R"
		else
			--停止
			--print( "停止" )
			po = 1
			cs = "S"
		end

		--新規のコマンドであれば送信します
		if( cs~=bcs or po~=bpo )then
			cmd = cs..string.char(po)
			sock.nsend( SockNum, cmd, 2 ) 
			bcs = cs
			bpo = po
		end
		
	end

	ntime = system.getSec() + 0.5
	while( ntime>system.getSec())do end

	sock.nsend( SockNum, "Q", 1 ) 
	sock.nclose(SockNum)
end
main()
system.exit()
