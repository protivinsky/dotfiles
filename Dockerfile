FROM ubuntu:latest

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y git wget curl sudo rsync locales vim

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

WORKDIR dotfiles
ADD home ./home
ADD install.sh .

# # These apt installs typically take the longest time, so run early before
# # adding other files, which may otherwise invalidate the cache even though they
# # are unrelated.
# ADD apt-installs.txt setup.sh .
# RUN ./setup.sh --apt-install

# # Now add the rest of the files
# ADD \
# .aliases \
# .bash_profile \
# .bashrc \
# .dircolors \
# .exports \
# .extra \
# .functions \
# .gitconfig \
# git-prompt.sh \
# .path \
# .

# RUN ./setup.sh --install-tmux
# RUN ./setup.sh --install-neovim

# Switch back to home dir
WORKDIR /home/joker

# Create some github repos I can play with and test the tooling
RUN git clone https://github.com/protivinsky/omoment.git
RUN git clone https://github.com/protivinsky/reportree.git

RUN sudo chown -R joker:joker .

# # do the dotfiles setup
ENV DOTFILES_FORCE=1
# RUN dotfiles/install.sh --all

CMD ["/bin/bash"]
