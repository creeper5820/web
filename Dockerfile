FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

RUN apt-get update

RUN apt-get install -y \
    wget git curl unzip \
    vim sudo zsh

# install oh my zsh & change theme to af-magic
RUN sh -c "$(wget https://gitee.com/Devkings/oh_my_zsh_install/raw/master/install.sh -O -)" && \
    sed -i 's/ZSH_THEME=\"[a-z0-9\-]*\"/ZSH_THEME="af-magic"/g' ~/.zshrc &&\
    chsh -s /bin/zsh

RUN apt-get install -y \
    nodejs npm

RUN npm cache clean --force && \
    npm config set registry https://registry.npmmirror.com

RUN npm install hexo hexo-cli -g