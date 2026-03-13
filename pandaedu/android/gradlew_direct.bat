@echo off
setlocal

set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
set "GRADLE_WRAPPER_JAR=%~dp0gradle\wrapper\gradle-wrapper.jar"
set "GRADLE_WRAPPER_PROPERTIES=%~dp0gradle\wrapper\gradle-wrapper.properties"

echo Running Gradle with direct Java invocation...
echo JAVA_HOME: %JAVA_HOME%
echo JAR: %GRADLE_WRAPPER_JAR%
echo.

"%JAVA_HOME%\bin\java.exe" ^
  -classpath "%GRADLE_WRAPPER_JAR%" ^
  -Dorg.gradle.appname=gradlew ^
  org.gradle.wrapper.GradleWrapperMain ^
  %*

exit /b %ERRORLEVEL%
