call Clear

call SetUpPaths

REM create R.java
call %AAPT_PATH% package -f -m -S %DEV_HOME%\res -J %DEV_HOME%\src -M %DEV_HOME%\AndroidManifest.xml -I %ANDROID_JAR%

REM Use Jack toolchain (*.java -> *.dex)
%JAVAVM% -jar %JACK_JAR% --output-dex "%DEV_HOME%\bin" -cp %ANDROID_JAR% -D jack.java.source.version=1.8 "%DEV_HOME%\src\com\example\testapp\R.java" "%DEV_HOME%\src\com\example\testapp\MainActivity.java"  

call %AAPT_PATH% package -f -M %DEV_HOME%\AndroidManifest.xml -S %DEV_HOME%\res -I %ANDROID_JAR% -F %DEV_HOME%\bin\AndroidTest.unsigned.apk %DEV_HOME%\bin

REM create key and signed APK
call "%JAVA_HOME%\bin\keytool" -genkey -validity 10000 -dname "CN=AndroidDebug, O=Android, C=US" -keystore %DEV_HOME%\AndroidTest.keystore -storepass android -keypass android -alias androiddebugkey -keyalg RSA -keysize 2048
call "%JAVA_HOME%\bin\jarsigner" -sigalg SHA1withRSA -digestalg SHA1 -keystore %DEV_HOME%\AndroidTest.keystore -storepass android -keypass android -signedjar %DEV_HOME%\bin\AndroidTest.signed.apk %DEV_HOME%\bin\AndroidTest.unsigned.apk androiddebugkey

REM reinstall and start APK on device
call %ADB% uninstall %PACKAGE%
call %ADB% install %DEV_HOME%\bin\AndroidTest.signed.apk
call %ADB% shell am start -n %PACKAGE%/%PACKAGE%.%MAIN_CLASS%
pause

