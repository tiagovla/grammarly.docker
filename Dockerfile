FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386

RUN apt update && apt install -y \
    gnupg \
    wget \
    software-properties-common

RUN wget -nc https://dl.winehq.org/wine-builds/winehq.key \
    && apt-key add winehq.key \
    && add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' \
    && apt update -y \
    && apt install -y --install-recommends winehq-staging

RUN wget "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"\
    && chmod +x winetricks\
    && mv winetricks /usr/bin

RUN wget "https://download-editor.grammarly.com/windows/GrammarlySetup.exe"
RUN apt-get install -y cabextract

ENV WINEDEBUG=fixme-all
ENV WINEPREFIX=/root/.wine
ENV WINEARCH=win32

RUN winecfg
RUN wineboot -u && winetricks -q dotnet452

RUN winetricks win7
RUN apt install firefox -y

RUN wine "GrammarlySetup.exe" || :
CMD wine "/root/.wine/drive_c/users/root/AppData/Local/GrammarlyForWindows/GrammarlyForWindows.exe" \
    && while pgrep GrammarlyForWin>/dev/null; do sleep 2; done

