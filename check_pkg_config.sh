#!/bin/bash

# This script will check which OS you're running it from.
# Then, check which packages you're lacking to continue
# Will ask you whether you want to install them or not.



CODE_OK=0
CODE_NO_INSTALLATION=1
CODE_ERR_PCKG_INSTALL=2
CODE_NO_XCODE=3

OS=`uname`
INSTALL=""

echo ""
echo "Package installation checking..."

# current_config.info file allows a faster access to the current config of the computer. 
# This allows not to browse through the computer every time we launch the script to see if everything is already installed
# The very existance of the hidden files asserts that all the packages are properly installed.
if [ ! -f .current_config.info ]; then
    if [ $OS == "Darwin" ]; then # macOS

        # Xcode Command Line Tools
        if [[ $(find -d /Library/Developer -name "CommandLineTools" 2> /dev/null) == "" ]]; then
            exit $CODE_NO_XCODE
        fi

        # Homebrew
        if [[ $(find -d /usr/local -name "Homebrew" 2> /dev/null) == ""  ]]; then
            INSTALL="$INSTALL Homebrew"
        fi

        # Coreutils
        if [[ $(find -d /usr/local/Cellar -name "coreutils" 2> /dev/null) == ""  ]]; then
            INSTALL="$INSTALL coreutils"
        fi

        # GNU sed
        if [[ $(find -d /usr/local/Cellar -name "gnu-sed" 2> /dev/null) == ""  ]]; then
            INSTALL="$INSTALL gnu-sed"
        fi

        # Python3
        if [[ $(find -d /usr/local/bin -name "python3" 2> /dev/null) == ""  ]]; then
            INSTALL="$INSTALL python3"
        fi

        # Pytvmaze API
        if [[ $(find /Library/Frameworks/Python.framework/Versions/python3* -name "pytvmaze" 2> /dev/null) == "" && \
              $(find /usr/local/lib/python3* -name "pytvmaze" 2> /dev/null) == "" ]]; then
            INSTALL="$INSTALL pytvmaze"
        fi  
    fi


    if [ $OS == "Linux" ];then

        if [[ $(python3 -V 2> /dev/null) == "" ]]; then
            INSTALL="$INSTALL python3"
        fi
        
        if [[ $(pip3 -V 2> /dev/null) == "" ]]; then
            INSTALL="$INSTALL py3-pip"
        fi

        if [[ $(find /usr/local/lib/python3* -name "pytvmaze") == "" ]]; then
            INSTALL="$INSTALL pytvmaze"
        fi
    fi

    if [[ $INSTALL == "" ]]; then   # if first time you run the code but everything is already installed. -> the .info file does not exist yet
        if [ $OS == "Darwin" ];then
            echo "Homebrew: Installed" >> .current_config.info
            echo "Coreutils: Installed" >> .current_config.info
            echo "GNU sed: Installed" >> .current_config.info
            echo "Python3: Installed" >> .current_config.info
            echo "Pytvmaze API: Installed" >> .current_config.info
        fi
        if [ $OS == "Linux" ];then
            echo "Python3: Installed" >> .current_config.info
            echo "Python3 pip pkg: Installed" >> .current_config.info
            echo "Pytvmaze API: Installed" >> .current_config.info
        fi

        echo "System up to date"
        exit $CODE_OK
    else
        echo "The system needs the installation of : $INSTALL"
        until [[ $answer == "y" || $answer == "Y" || $answer == "n" || $answer == "N" ]]; do
            echo -e "Do you want to do the installation now? (y/n) \c"
            read answer
        done
        if [[ $answer == "n" || $answer == "N" ]];then
            exit $CODE_NO_INSTALLATION
        fi
        if [[ $answer == "y" || $answer == "Y" ]];then
            # launch the installation
            ./install_pkg.sh $OS "$INSTALL"   # the .info file will be created here if everything works out
            ret=$?
        fi
    fi

    if [ $ret == $CODE_OK ]; then
        echo -e "Installation success\n"
        exit $CODE_OK
    else
        echo -e "Installation fail\n"
        rm .current_config.info
        exit $CODE_ERR_PCKG_INSTALL
    fi

else
    echo "System up to date"
    exit $CODE_OK

fi




