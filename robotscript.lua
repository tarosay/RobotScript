------------------------------------------
-- Robot Script Loader Ver 1.2
------------------------------------------
--関数宣言--------------------------------
main={}                  --mainメソッド
readURL={}            --robotscript.iniファイルを読み込みます
getHttp={}             --http.getを用いてファイルを取得します
filedowmload={}    --URLからファイルをDown Loadします
readLastData={}   --最後に動作させたデータを読み出します
savedata={}          --読み込んだurlとファイル名データを保存します
--グローバル変数宣言----------------------
Title = "Robot Script Loader Ver 1.2"
RbModulePath = system.getAppPath().."/rbmodule.txt"
RbLastFilename = system.getAppPath().."/rblastdata.txt"
RbLast = { moduleURL="error", scriptURL="error", scriptname="robot.lua" }
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
--読み込んだurlとファイル名データを保存します
------------------------------------------
function savedata( urlofurl, urloffilename, filename )
local fp
	fp = io.open( RbLastFilename, "w+" )
	if( not(fp) )then
		toast( RbLastFilename.." がオープンできません" )
		return -1
	else
		fp:write( urlofurl.."\n" )
		fp:write( urloffilename.."\n" )
		fp:write( filename.."\n" )
	end
	io.flush()
	io.close( fp )
	return 0
end
------------------------------------------
--最後に動作させたデータを読み出します
------------------------------------------
function readLastData()
local fp
	fp = io.open( RbLastFilename, "r" )    --ファイルを開きます
	if( not(fp) )then
		--ファイルが無かったので、自動生成します
		fp = io.open( RbLastFilename, "w+" )
		if( not(fp) )then
			dialog( RbLastFilename.." がオープンできません","変更しないで終了します", 1 )
			return -1
		else
			fp:write( RbLast.moduleURL.."\n" )
			fp:write( RbLast.scriptURL.."\n" )
			fp:write( RbLast.scriptname.."\n" )
			io.flush()
			io.close( fp )
			return 0
		end
	else
		--データを読み込みます
		local i
		local str = fp:read("*l")            --1行読み込み
		str = string.gsub( str,"\r","" )   --改行コードを外す
		RbLast.moduleURL = str
		str = fp:read("*l")            --1行読み込み
		str = string.gsub( str,"\r","" )   --改行コードを外す
		RbLast.scriptURL = str
		str = fp:read("*l")            --1行読み込み
		str = string.gsub( str,"\r","" )   --改行コードを外す
		RbLast.scriptname = str
		io.close(fp)
	end
	return 0
end
------------------------------------------
-- ファイルから#で始まらない1行を読み込みます
-- cre= 0:読み込むデータが無ければエラーで終了, 1:無ければ仮生成する
------------------------------------------
function readURL( filename, cre)
local fp
local url = "error"
	fp = io.open( filename, "r" )
	if( not(fp) )then
		if( cre==1 )then
			--ファイルが無かったので、自動生成します
			fp = io.open( filename, "w+" )
			if( not(fp) )then
				dialog( RbLastFilename.." がオープンできません","変更しないで終了します", 1 )
			else
				url = "http://192.168.1.100/rbscript.add"
				fp:write( "#This is URL with the file that specifies the robot script.".."\n" )
				fp:write( url.."\n" )
				io.flush()
				io.close( fp )
			end
		else
			toast( filename..":Open Error" )
		end
		return url
	end
	
	while(true)do
		url = fp:read("*l")          --1行読み込み
		if( url==nil )then
			--読込むデータが無ければ終了
			toast( filename..":Read Error" )
			url = "error"			
			break
		end
		url = url:gsub( "\r","" )  --改行コードを外す
		if( url:sub(1,1)~="#" )then break end
	end
	io.close(fp)
	return url
end
------------------------------------------
--http.getを用いてファイルを取得します
-- Error:-1
------------------------------------------
function getHttp( url, putFilename )

	http.get( url, putFilename )
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
--URLからファイルをDown Loadします
--Loadしたフルパスが返ります
------------------------------------------
function filedowmload( url )
local filename = url
	--先頭がhttp://かどうか調べます
	if( url:sub( 1,7)=="http://" )then
		--http://だった
		for i=1, string.len( filename ) do
			local cname = filename:sub( -i )
			if( cname:sub( 1, 1 )=="/" )then
				filename = cname:sub( 2 )
				break
			end			
		end
		--filenameをダウンロードします
		if( getHttp( url,  system.getAppPath().."/"..filename )==-1)then
			toast( "エラーが発生したました" )
			return "error"
		end
	else
		toast( "URLエラーが発生したました" )
		return "error"
	end
	return (system.getAppPath().."/"..filename )
end
------------------------------------------
--メインプログラム
------------------------------------------
function main()

	toast( Title )
	system.setSleep(0) --スリープしない

	--最後に動作させたデータを読み出します
	if(readLastData()==-1)then
		dialog( "readLastData" , "エラーが発生したので終了します", 1 )
		system.exit()	--終了します
	end

	local setrunFlg = 0
	local filename = RbLast.scriptname

	--RB-Moduleから読み込むスクリプトのURLを書いたファイルのURLを読み込みます
	local urlofurl = readURL(RbModulePath, 1)
	if( urlofurl=="error" )then
		if( RbLast.moduleURL=="error" )then
			dialog( "readURL-1" , "エラーが発生したので終了します", 1 )
			system.exit()	--終了します
		else
			urlofurl = RbLast.moduleURL
		end
	end
	--読み込むスクリプトのURLを書いたファイルのURLをダウンロードします
	local urloffilename = filedowmload( urlofurl )
	if( urloffilename=="error" )then
		if( RbLast.scriptURL=="error" )then
			dialog( "filedowmload-1" , "エラーが発生したので終了します", 1 )
			system.exit()	--終了します
		else
			urloffilename = RbLast.scriptURL
		end
	end

	--filenameからロボットスクリプトのURLを読み込みます
	local urlofscript = readURL(urloffilename, 0)
	if( urlofscript=="error" )then
		if( urloffilename==RbLast.scriptURL )then
			--失敗したURLがRbLast.scriptURLと同じであれば終了します
			setrunFlg = 1
			--dialog( "" , "エラーが発生したので終了します-4", 1 )
			--system.exit()	--終了します
		else
			--今度はRbLast.scriptURLを読み込みます
			urlofscript = readURL(RbLast.scriptURL, 0)
			if(urlofscript=="error" )then
				dialog( "readURL-2" , "エラーが発生したので終了します", 1 )
				system.exit()	--終了します
			end
		end
	end

	if(setrunFlg==0)then
		--ロボットスクリプトをダウンロードします
		filename = filedowmload( urlofscript )
		if( filename=="error" )then
			filename = RbLast.scriptname
		end
		--読み込んだurlとファイル名データを保存します
		savedata( urlofurl, urlofscript, filename )
	end
	
	--実行ファイルをセットします
	system.setrun( filename )
end
main()
