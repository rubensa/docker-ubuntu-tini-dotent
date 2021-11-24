FROM rubensa/ubuntu-tini-dev
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# .Net Core Version to install (https://github.com/dotnet/installer/releases)
ARG DOTNET_VERSION=6.0.100
ENV DOTNET_ROOT=/opt/dotnet

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME=/root

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update \
    # 
    # Install software and needed libraries
    && apt-get -y install --no-install-recommends libicu-dev 2>&1 \
    #
    # Setup .Net
    && mkdir -p ${DOTNET_ROOT} \
    && curl -o ${DOTNET_ROOT}/dotnet-install.sh -sSL https://dot.net/v1/dotnet-install.sh \
    && chmod +x ${DOTNET_ROOT}/dotnet-install.sh \
    && ${DOTNET_ROOT}/dotnet-install.sh --version ${DOTNET_VERSION} --install-dir ${DOTNET_ROOT} \
    #
    # Assign group folder ownership
    && chgrp -R ${GROUP_NAME} ${DOTNET_ROOT} \
    #
    # Set the segid bit to the folder
    && chmod -R g+s ${DOTNET_ROOT} \
    #
    # Give write and exec acces so anyobody can use it
    && chmod -R ga+wX ${DOTNET_ROOT} \
    #
    # Configure .Net for the non-root user
    && printf "\nPATH=\$PATH:\$DOTNET_ROOT" >> /home/${USER_NAME}/.bashrc \
    #
    # Configure dotnet bash completion
    && curl -o /etc/bash_completion.d/dotnet -sSL "https://github.com/dotnet/cli/raw/master/scripts/register-completions.bash" \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=

# Tell docker that all future commands should be run as the non-root user
USER ${USER_NAME}

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME /home/$USER_NAME
