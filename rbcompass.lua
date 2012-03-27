------------------------------------------
-- Robot Compass
------------------------------------------
--関数宣言--------------------------------
main={} --mainメソッド
setTateGamen={} --縦向きに変更
print={} --スクロールするテキスト表示
sendcmd={} --コマンドを送信します
iniRngBuf={} --リングバッファの初期化
getKaku={} --角度の取得

--グローバル変数宣言----------------------
Cmps={ mRngBuf={}, cnt=1, cntmax=5 }
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
local w, h = canvas.getviewSize() --画面サイズ取得
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
 canvas.putRect( 0, h-fontsize*sc-1, w, h, bcolor, 1 )
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
    while psec>system.getSec() do end
end
------------------------------------------
--リングバッファの初期化
------------------------------------------
function iniRngBuf()
local i
for i=1, Cmps.cntmax do
Cmps.mRngBuf[i] = sensor.getOrient()
end
Cmps.cnt = 1
end
------------------------------------------
--角度の取得
------------------------------------------
function getKaku()
local i
Cmps.mRngBuf[Cmps.cnt] = sensor.getOrient()
Cmps.cnt = Cmps.cnt + 1
if( Cmps.cnt>Cmps.cntmax )then Cmps.cnt = 1 end
local kaku = 0
for i=1, Cmps.cntmax do
kaku = kaku + Cmps.mRngBuf[i]
end
return kaku/Cmps.cntmax
end
------------------------------------------
--メインプログラム
------------------------------------------
function main()
--画面を縦向きに変更
setTateGamen()

canvas.drawCls( color(255,255,255) ) --背景を白色に
system.setSleep(0) --スリープしない

--60101ポートへの接続を10秒間待つ
local ret = sock.nlistenOpen( 1, 60101, 10 )
if( ret~=1 )then
dialog( "adb接続に失敗しました", "終了します" , 1 )
system.exit()
end

--接続できたことを表示する
print( "MicroBridgeと接続しました")

--方位センサ起動
sensor.setdevOrient(1)

--リングバッファの初期化
iniRngBuf()

local cmd
--ギアを回転に入れる間を取る
cmd = "L"..string.char(25)
sendcmd( cmd, 0.2 )

local gosa = 5
local spd = 64
local tim = 0.5
local kaku = 0
while(true)do
kaku = 0
while(kaku==0)do
kaku = sensor.getOrient()
end

if( kaku>90 and kaku<270 )then
spd = 75
tim = 1.0
elseif( (kaku>45 and kaku<=90) or (kaku>=270 and kaku<315) )then
spd = 60
tim = 0.4
else
spd = 38
tim = 0.2
end

if( kaku<=180 and kaku>gosa )then
--左回り
cmd = "L"..string.char(spd)
sendcmd( cmd, tim )
elseif( kaku>180 and kaku<360-gosa )then
--右回り
cmd = "R"..string.char(spd)
sendcmd( cmd, tim )
end

if( kaku>350 or kaku<10 )then
--止める
cmd = "S"..string.char(32)
sendcmd( cmd, 0.2 )
if( kaku<=gosa or kaku>=360-gosa )then
local w,h = canvas.getviewSize()
canvas.putCls( color(255,255,255) )
local fs = 55
local y = fs/1.5
canvas.putTextRotate( "こ", w/2, y, 0, fs, color(0,0,0) )
y = y + fs
canvas.putTextRotate( "っ", w/2, y, 0, fs, color(0,0,0) )
y = y + fs
canvas.putTextRotate( "ち", w/2, y, 0, fs, color(0,0,0) )
y = y + fs
canvas.putTextRotate( "が", w/2, y, 0, fs, color(0,0,0) )
y = y + fs
canvas.putTextRotate( "北", w/2, y, 0, fs, color(0,0,0) )
y = y + fs
canvas.putTextRotate( "だ", w/2, y, 0, fs, color(0,0,0) )
y = y + fs
canvas.putTextRotate( "よ", w/2, y, 0, fs, color(0,0,0) )
y = y + fs
canvas.putTextRotate( "！", w/2, y, 0, fs, color(0,0,0) )
canvas.putflush()
end
else
--canvas.drawCls( color(255,255,255) )
print( kaku )
end

local x,y,s = touch()
if( s~=1 )then break end
end

--PIC動作終了
cmd = "C"..string.char(40)
sendcmd( cmd, 0.2 )

--傾斜センサ終了
sensor.setdevOrient(0)

sock.nclose( 1 )

--dialog( "", "電源を切ってください" , 1 )
end
main()
system.exit()
