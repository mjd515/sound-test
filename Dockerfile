FROM debian:buster

ENV LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=C.UTF-8 DISPLAY=:0.0

# Install dependencies.
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
      bzip2 \
      gstreamer1.0-plugins-good \
      gstreamer1.0-pulseaudio \
      gstreamer1.0-tools \
      libglu1-mesa \
      libgtk-3-0 \
      libncursesw5 \
      libopenal1 \
      libsdl-image1.2 \
      libsdl-ttf2.0-0 \
      libsdl1.2debian \
      libsndfile1 \
      novnc \
      pulseaudio \
      supervisor \
      ucspi-tcp \
      wget \
      x11vnc \
      xvfb \
      software-properties-common \
      apt-transport-https \
      ca-certificates \
      gnupg2 \ 
      procps \
      curl \
      libgbm-dev && \
      curl -s 'https://updates.signal.org/desktop/apt/keys.asc' | apt-key add - && \
	add-apt-repository 'deb https://updates.signal.org/desktop/apt xenial main' && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends && \
	signal-desktop && \
	rm -rf /var/lib/apt/lists/*

 
# WORKDIR /tmp
 
 #RUN \
#	add-pkg software-properties-common apt-transport-https ca-certificates curl gnupg2 libgtk-3-0 procps libgbm-dev && \
#	curl -s 'https://updates.signal.org/desktop/apt/keys.asc' | apt-key add - && \
#	add-apt-repository 'deb https://updates.signal.org/desktop/apt xenial main' && \
#	add-pkg signal-desktop=5.47.0 && \
#	rm -rf /var/lib/apt/lists/*

 COPY startapp.sh /startapp.sh
 
# Set environment variables
#ENV APP_NAME="signal-desktop"

# Configure pulseaudio.
COPY default.pa client.conf /etc/pulse/

# Force vnc_lite.html to be used for novnc, to avoid having the directory listing page.
# Additionally, turn off the control bar. Finally, add a hook to start audio.
COPY webaudio.js /usr/share/novnc/core/
RUN ln -s /usr/share/novnc/vnc_lite.html /usr/share/novnc/index.html \
 && sed -i 's/display:flex/display:none/' /usr/share/novnc/app/styles/lite.css \
 && sed -i "/import RFB/a \
      import WebAudio from './core/webaudio.js'" \
    /usr/share/novnc/vnc_lite.html \
 && sed -i "/function connected(e)/a \
      var wa = new WebAudio('ws://localhost:8081/websockify'); \
      document.getElementsByTagName('canvas')[0].addEventListener('keydown', e => { wa.start(); });" \
    /usr/share/novnc/vnc_lite.html

# Configure supervisord.
COPY supervisord.conf /etc/supervisor/supervisord.conf
ENTRYPOINT [ "supervisord", "-c", "/etc/supervisor/supervisord.conf" ]

# Run everything as standard user/group df.
RUN groupadd df \
 && useradd --create-home --gid df df
WORKDIR /home/df
USER df

# Install signal/discord.

 
 
