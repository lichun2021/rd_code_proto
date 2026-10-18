@echo proto file build ...
@echo off

set /p isBuildAll=是否将所有proto文件生成java？(y(Y)是/n(N)否,指定单个文件)


if "%isBuildAll%" == "y" goto buildAll
if "%isBuildAll%" == "Y" goto buildAll
if "%isBuildAll%" == "n" goto buildSigle
if "%isBuildAll%" == "N" goto buildSigle

goto buildSigle
:buildAll
for /r %%i in (*.proto) do (
	@echo %%~ni.proto
	protoc.exe --java_out=./Protobuf/Java/src/main/java %%~ni.proto
	if errorlevel 1 goto return
)
goto next

:buildSigle
set /p filename=请输入proto文件名(不包含后缀):
if not exist %filename%.proto (
	echo 文件 %filename%.proto 不存在！
	goto buildSigle
)
@echo build %filename%.proto
protoc.exe --java_out=./Protobuf/Java/src/main/java %filename%.proto

set /p continueBuild=是否继续输入？(y(Y)是/n(N)否)
if "%continueBuild%" == "y" goto buildSigle
if "%continueBuild%" == "Y" goto buildSigle
:next

@echo proto build done!

@echo gradle build gameprotocol.jar ...

call gradle -b Protobuf\Java\build.gradle clean
if errorlevel 1 goto return
call gradle -b Protobuf\Java\build.gradle jar
if errorlevel 1 goto return

@echo gameprotocol.jar build done!

@echo publish gameprotocol.jar ...

set SERVER_ROOT=..\..\Code_Server\1.4.109
if not exist "%SERVER_ROOT%\GameServer\lib" set SERVER_ROOT=..\..

xcopy /Y Protobuf\Java\build\libs\gameprotocol.jar "%SERVER_ROOT%\GameServer\lib\"
if errorlevel 1 goto return
if exist "%SERVER_ROOT%\Protocol\Protobuf\Java\build\libs" xcopy /Y Protobuf\Java\build\libs\gameprotocol.jar "%SERVER_ROOT%\Protocol\Protobuf\Java\build\libs\"
if exist "%SERVER_ROOT%\Publish\lib" xcopy /Y Protobuf\Java\build\libs\gameprotocol.jar "%SERVER_ROOT%\Publish\lib\"
if exist "%SERVER_ROOT%\GameActivity\lib" xcopy /Y Protobuf\Java\build\libs\gameprotocol.jar "%SERVER_ROOT%\GameActivity\lib\"
if exist "%SERVER_ROOT%\GameRobot\lib" xcopy /Y Protobuf\Java\build\libs\gameprotocol.jar "%SERVER_ROOT%\GameRobot\lib\"
if exist "%SERVER_ROOT%\RaolRobot\lib" xcopy /Y Protobuf\Java\build\libs\gameprotocol.jar "%SERVER_ROOT%\RaolRobot\lib\"

@echo build success!

:return
pause