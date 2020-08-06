FROM ls12styler/dind:19.03.9 

# Install basics (HAVE to install bash for tpm to work)
RUN apk update && apk add -U --no-cache \
    bash zsh git git-perl less curl bind-tools \
    man build-base su-exec shadow openssh-client 

# RUN apk add neovim

RUN apk add fzf htop unzip

RUN apk add rsync python3 py3-pip


ENV RG_VERSION=12.1.1
RUN set -x \
  && wget https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz \
  && tar xzf ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz \
  && mv ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl/rg /usr/local/bin/rg
# COPY --from=build /rg /usr/local/bin/
#COPY --from=ls12styler/dind:19.03.9 /rg /usr/local/bin/
#COPY /rg /usr/local/bin/

# Set Timezone
RUN apk add tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Europe/London" > /etc/timezone && \
    apk del tzdata

# RUN apk add -U --no-cache \
#     tmux  ncurses docker py-pip
# RUN pip install docker-compose

# RUN pip3 install neovim
##########################################################################################################
RUN apk add --update \
  git \
  alpine-sdk build-base\
  libtool \
  automake \
  m4 \
  autoconf \
  linux-headers \
  unzip \
  ncurses ncurses-dev ncurses-libs ncurses-terminfo \
  python \
  python-dev \
  py-pip \
  clang \
  go \
  nodejs \
  xz \
  curl \
  make \
  cmake \
  libintl gettext-dev outils-md5 \
  && rm -rf /var/cache/apk/*

RUN apk add --virtual build-deps --update \
        autoconf \
        automake \
        cmake \
        ncurses ncurses-dev ncurses-libs ncurses-terminfo \
        gcc \
        g++ \
        libtool \
        libuv \
        linux-headers \
        lua5.3-dev \
        m4 \
        unzip \
        make 


RUN apk add --update \
        curl \
        git \
        python \
        py-pip \
        python-dev \
        python3-dev \
        python3 &&\
        python3 -m ensurepip && \
        rm -r /usr/lib/python*/ensurepip && \
        pip3 install --upgrade pip setuptools && \
        rm -r /root/.cache

ENV CMAKE_EXTRA_FLAGS=-DENABLE_JEMALLOC=OFF
WORKDIR /tmp

RUN git clone https://github.com/neovim/libtermkey.git && \
  cd libtermkey && \
  make && \
  make install && \
  cd ../ && rm -rf libtermkey

RUN git clone https://github.com/neovim/libvterm.git && \
  cd libvterm && \
  make && \
  make install && \
  cd ../ && rm -rf libvterm

RUN git clone https://github.com/neovim/unibilium.git && \
  cd unibilium && \
  make && \
  make install && \
  cd ../ && rm -rf unibilium

RUN curl -L https://github.com/neovim/neovim/archive/nightly.tar.gz | tar xz && \
  cd neovim-nightly && \
  make && \
  make install && \
  cd ../ && rm -rf neovim-nightly

# # Install neovim python support
RUN pip3 install neovim
RUN pip2 install neovim

RUN apk del build-deps &&\
   rm -rf /var/cache/apk/*
##########################################################################################################
ENV HOME /home/me

# Install tmux
COPY --from=ls12styler/tmux:3.1b /usr/local/bin/tmux /usr/local/bin/tmux

# Install jQ!
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O /bin/jq && chmod +x /bin/jq

# Configure text editor - vim!
RUN curl -fLo ${HOME}/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Consult the vimrc file to see what's installed
COPY .vimrc ${HOME}/.config/nvim/init.vim

# In the entrypoint, we'll create a user called `me`
WORKDIR ${HOME}

# Setup my $SHELL
ENV SHELL /bin/zsh
# Install oh-my-zsh
RUN wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O - | zsh || true
RUN wget https://gist.githubusercontent.com/xfanwu/18fd7c24360c68bab884/raw/f09340ac2b0ca790b6059695de0873da8ca0c5e5/xxf.zsh-theme -O ${HOME}/.oh-my-zsh/custom/themes/xxf.zsh-theme
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${HOME}/.oh-my-zsh/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting

COPY .aliases ${HOME}/.aliases

# Copy ZSh config
COPY .zshrc ${HOME}/.zshrc

# Install FZF (fuzzy finder on the terminal and used by a Vim plugin).
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf 
RUN ${HOME}/.fzf/install || true

# Install TMUX
COPY .tmux.conf ${HOME}/.tmux.conf
RUN git clone https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm 

# Copy git config over
COPY .gitconfig ${HOME}/.gitconfig

# Install plugins
# RUN nvim +PlugInstall +qall >> /dev/null
# RUN timeout 20m nvim '+PlugInstall --sync' +qa || true
RUN nvim '+PlugInstall --sync' +qa || true

# Entrypoint script creates a user called `me` and `chown`s everything
COPY entrypoint.sh /bin/entrypoint.sh

# Set working directory to /workspace
WORKDIR /workspace

# Default entrypoint, can be overridden
CMD ["/bin/entrypoint.sh"]
