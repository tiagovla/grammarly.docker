FROM ubuntu:22.04 AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG BUILD_DEPENENCIES="gnupg wget software-properties-common"
RUN dpkg --add-architecture i386 \
    && apt update && apt install -y $BUILD_DEPENENCIES \
    winbind libgl1-mesa-glx:i386 libglu1-mesa:i386 cabextract \
    # Download and add the repository key: [https://wiki.winehq.org/Ubuntu]
    && wget -nc https://dl.winehq.org/wine-builds/winehq.key \
    && mv winehq.key /usr/share/keyrings/winehq-archive.key \
    # Add the repository: [https://wiki.winehq.org/Ubuntu]
    && wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources \
    &&  mv winehq-jammy.sources /etc/apt/sources.list.d/ \
    # Update packages and install staging version: [https://wiki.winehq.org/Ubuntu]
    && apt update -y && apt install -y --install-recommends winehq-staging \
    # Clear:
    # && apt-get remove --purge -yqq $BUILD_DEPENDENCIES \
    && apt-get autoremove -yqq && rm -rf /var/lib/apt/lists/*

FROM base AS dotnet

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y  xvfb --install-recommends \
    # Install winetricks:
    && wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/local/bin/winetricks \
    && chmod +x /usr/local/bin/winetricks \
    # Clear:
    && apt-get autoremove -yqq && rm -rf /var/lib/apt/lists/*

ENV WINEPREFIX /root/.wine
ENV WINEARCH win32
RUN wget "https://www.dropbox.com/s/taj4fvvqaiw9ld7/GrammarlySetup.exe?dl=1" -O GrammarlySetup.exe
RUN apt update && apt install -y --no-install-recommends wget 

# FIX: install grammarly during building
# RUN wineboot --init
# RUN while pgrep -u root wineserver > /dev/null; do echo "waiting ..." sleep 1; done
# RUN xvfb-run -a winetricks -q dotnet452

CMD if [ -f "/root/.wine/drive_c/users/root/AppData/Local/GrammarlyForWindows/GrammarlyForWindows.exe" ]; then wine "/root/.wine/drive_c/users/root/AppData/Local/GrammarlyForWindows/GrammarlyForWindows.exe" \ && while pgrep GrammarlyForWin>/dev/null; do sleep 2; done; else wineboot --init && winetricks -q --force dotnet452 && winetricks win7 && wine GrammarlySetup.exe && sleep 30 && while pgrep GrammarlyForWin>/dev/null; do sleep 2; fi
