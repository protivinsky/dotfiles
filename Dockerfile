FROM ubuntu:latest

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y git wget curl sudo rsync locales vim fzf
# stuff that I would otherwise install in dotfiles
RUN apt-get install -y htop stow
RUN apt-get install -y tmux
RUN apt-get install -y linux-libc-dev && apt-get clean
RUN apt-get install -y gcc libc6-dev make
RUN apt-get install -y python3 python3-venv python3-pip
RUN apt-get install -y cargo
# RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

# RUN apt-get install -y build-essential

# Locale is set in .bash_profile; needs to be created
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen en_US.UTF-8

# From now on, use login shell so that bashrc gets sourced
ENV SHELL /bin/bash

# Create a new user, 'joker' with password 'aceofspades'
RUN useradd -m joker -s /bin/bash && \
    echo "joker:aceofspades" | chpasswd && \
    usermod -aG sudo joker

# Allow joker to run sudo commands without a password prompt
RUN echo 'joker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to the new user
USER joker
WORKDIR /home/joker

ENV TMPDIR=/tmp
RUN mkdir -p $HOME
RUN mkdir -p $TMPDIR

# # Don't prompt for user input when using setup.sh
# ENV DOTFILES_FORCE=true

RUN mkdir -p dotfiles
COPY . dotfiles/

# Create some github repos I can play with and test the tooling
RUN git clone https://github.com/protivinsky/omoment.git
RUN git clone https://github.com/protivinsky/reportree.git

RUN sudo chown -R joker:joker .

# do the dotfiles setup
ENV DOTFILES_FORCE=1
# RUN dotfiles/install.sh --dotfiles --tmux
RUN dotfiles/install.sh --dotfiles --tmux --node --lazygit --nvims

CMD ["/bin/bash"]
