#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

target="sky"

Sky="$PWD/../Sky"

backend="$PWD/../backend"

script="$PWD/script"

bash="$PWD/bash"

#--------------------------------------------------------------------------------------------------
# environment

compiler_win="mingw"

qt="qt6"

storage="storageDefault"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

copyQml()
{
    cp "$path"/$1/*.$2   $deploy/$1
    cp "$path"/$1/qmldir $deploy/$1
}

copyAndroid()
{
    path="build/$1/android-build/build/outputs"

    if [ $storage = "storageLight" ]; then

        mv $path/apk/release/android-build-release-unsigned.apk $deploy/$target-$1.apk

        mv $path/bundle/release/android-build-release.aab $deploy/$target-$1.aab
    else
        cp $path/apk/release/android-build-release-unsigned.apk $deploy/$target-$1.apk

        cp $path/bundle/release/android-build-release.aab $deploy/$target-$1.aab
    fi
}

installMacOS()
{
    install_name_tool -change @rpath/$1.framework/Versions/$qx/$1 @loader_path/$1.dylib "$2"
}

copyFolder()
{
   find "$1" -type f -iname "$3" | while read -r file; do

       path="${file#$1/}"

       target="$2/$(dirname "$path")"

       mkdir -p "$target"

       cp "$file" "$target/"
   done
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 -a $# != 2 ] \
   || \
   [ $1 != "win32" -a $1 != "win64" -a $1 != "macOS" -a $1 != "iOS" -a $1 != "linux" -a \
     $1 != "android" ] \
   || \
   [ $# = 2 -a "$2" != "clean" ]; then

    echo "Usage: deploy <win32 | win64 | macOS | iOS | linux | android> [clean]"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $1 = "win32" -o $1 = "win64" ]; then

    os="windows"

    compiler="$compiler_win"
else
    if [ $1 = "iOS" -o $1 = "android" ]; then

        os="mobile"
    else
        os="default"
    fi

    compiler="default"
fi

if [ $qt = "qt5" ]; then

    QtX="Qt5"

    qx="5"

elif [ $qt = "qt6" ]; then

    QtX="Qt6"

    if [ $1 = "macOS" ]; then

        qx="A"
    else
        qx="6"
    fi
fi

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

echo "CLEANING"

rm -rf deploy/*

touch deploy/.gitignore

if [ "$2" = "clean" ]; then

    exit 0
fi

echo ""

#--------------------------------------------------------------------------------------------------
# Bundle
#--------------------------------------------------------------------------------------------------

if [ $1 = "macOS" ]; then

    cp -r bin/$target.app deploy

    deploy="deploy/$target.app/Contents/MacOS"
else
    deploy="deploy"
fi

#--------------------------------------------------------------------------------------------------
# Sky
#--------------------------------------------------------------------------------------------------

echo "DEPLOYING Sky"
echo "-------------"

cd "$Sky"

sh deploy.sh $1 tools

cd -

path="$Sky/deploy"

#--------------------------------------------------------------------------------------------------
# Qt
#--------------------------------------------------------------------------------------------------

if [ $qt = "qt5" ]; then

    QtQuick="QtQuick.2"

elif [ $qt = "qt6" ]; then

    QtQuick="QtQuick"
fi

if [ $qt != "qt4" ]; then

    mkdir $deploy/platforms
    mkdir $deploy/imageformats
    mkdir $deploy/$QtQuick
    mkdir $deploy/QtMultimedia

    if [ $qt = "qt5" ]; then

        mkdir -p $deploy/mediaservice
    else
        mkdir -p $deploy/tls
        mkdir -p $deploy/multimedia

        mkdir -p $deploy/QtQml/WorkerScript

        if [ $compiler != "mingw" ]; then

            mkdir -p $deploy/QtWebView
            mkdir -p $deploy/QtWebEngine
            mkdir -p $deploy/QtWebChannel

            cp -r "$path"/webview $deploy
        fi
    fi
fi

if [ $os = "windows" ]; then

    if [ $compiler = "mingw" ]; then

        cp "$path"/libgcc_s_*-1.dll    $deploy
        cp "$path"/libstdc++-6.dll     $deploy
        cp "$path"/libwinpthread-1.dll $deploy
    fi

    if [ $qt = "qt4" ]; then

        mkdir $deploy/imageformats

        cp "$path"/QtCore4.dll        $deploy
        cp "$path"/QtGui4.dll         $deploy
        cp "$path"/QtDeclarative4.dll $deploy
        cp "$path"/QtNetwork4.dll     $deploy
        cp "$path"/QtOpenGL4.dll      $deploy
        cp "$path"/QtScript4.dll      $deploy
        cp "$path"/QtSql4.dll         $deploy
        cp "$path"/QtSvg4.dll         $deploy
        cp "$path"/QtWebKit4.dll      $deploy
        cp "$path"/QtXml4.dll         $deploy
        cp "$path"/QtXmlPatterns4.dll $deploy

        cp "$path"/imageformats/qsvg4.dll  $deploy/imageformats
        cp "$path"/imageformats/qjpeg4.dll $deploy/imageformats
    else
        if [ $qt = "qt5" ]; then

            cp "$path"/libEGL.dll    deploy
            cp "$path"/libGLESv2.dll deploy
        else
            if [ $compiler != "mingw" ]; then

                # NOTE: Required for the webview.
                cp -r "$path"/resources $deploy

                cp "$path"/QtWebEngineProcess* $deploy
            fi

            # FFmpeg
            cp "$path"/av*.dll deploy
            cp "$path"/sw*.dll deploy
        fi

        cp "$path/$QtX"Core.dll            $deploy
        cp "$path/$QtX"Gui.dll             $deploy
        cp "$path/$QtX"Network.dll         $deploy
        cp "$path/$QtX"OpenGL.dll          $deploy
        cp "$path/$QtX"Qml.dll             $deploy
        cp "$path/$QtX"Quick.dll           $deploy
        cp "$path/$QtX"Svg.dll             $deploy
        cp "$path/$QtX"Widgets.dll         $deploy
        cp "$path/$QtX"Xml.dll             $deploy
        cp "$path/$QtX"Multimedia.dll      $deploy
        cp "$path/$QtX"MultimediaQuick.dll $deploy

        if [ $qt = "qt5" ]; then

            cp "$path/$QtX"XmlPatterns.dll $deploy
            cp "$path/$QtX"WinExtras.dll   $deploy
        else
            cp "$path/$QtX"Core5Compat.dll $deploy
            cp "$path/$QtX"QmlMeta.dll     $deploy

            if [ $compiler != "mingw" ]; then

                cp "$path/$QtX"Positioning.dll $deploy
                cp "$path/$QtX"Web*.dll        $deploy
            fi
        fi

        if [ -f "$path/$QtX"QmlModels.dll ]; then

            cp "$path/$QtX"QmlModels.dll       $deploy
            cp "$path/$QtX"QmlWorkerScript.dll $deploy
        fi

        cp "$path"/platforms/qwindows.dll $deploy/platforms

        cp "$path"/imageformats/qsvg.dll  $deploy/imageformats
        cp "$path"/imageformats/qjpeg.dll $deploy/imageformats
        cp "$path"/imageformats/qwebp.dll $deploy/imageformats

        if [ $qt = "qt5" ]; then

            cp "$path"/mediaservice/dsengine.dll $deploy/mediaservice
        else
            cp "$path"/tls/qopensslbackend.dll  $deploy/tls
            cp "$path"/tls/qschannelbackend.dll $deploy/tls

            cp "$path"/multimedia/ffmpegmediaplugin.dll $deploy/multimedia
        fi

        cp "$path"/$QtQuick/qtquick2plugin.dll $deploy/$QtQuick
        cp "$path"/$QtQuick/qmldir             $deploy/$QtQuick

        cp "$path"/QtMultimedia/*multimedia*.dll $deploy/QtMultimedia
        cp "$path"/QtMultimedia/qmldir           $deploy/QtMultimedia

        if [ $qt = "qt6" ]; then

            copyQml QtQml/WorkerScript dll

            if [ $compiler != "mingw" ]; then

                copyQml QtWebView    dll
                copyQml QtWebEngine  dll
                copyQml QtWebChannel dll
            fi
        fi
    fi

elif [ $1 = "macOS" ]; then

    if [ $qt != "qt4" ]; then

        if [ $qt = "qt6" ]; then

            # NOTE: Required for the webview.
            cp -r "$path"/resources/* $deploy

            cp "$path"/QtWebEngineProcess* $deploy
        fi

        # FIXME Qt 5.14 macOS: We have to copy qt.conf to avoid a segfault.
        cp "$path"/qt.conf $deploy

        cp "$path"/QtCore.dylib            $deploy
        cp "$path"/QtGui.dylib             $deploy
        cp "$path"/QtNetwork.dylib         $deploy
        cp "$path"/QtOpenGL.dylib          $deploy
        cp "$path"/QtCore.dylib            $deploy
        cp "$path"/QtQml.dylib             $deploy
        cp "$path"/QtQuick.dylib           $deploy
        cp "$path"/QtSvg.dylib             $deploy
        cp "$path"/QtWidgets.dylib         $deploy
        cp "$path"/QtXml.dylib             $deploy
        cp "$path"/QtMultimedia.dylib      $deploy
        cp "$path"/QtMultimediaQuick.dylib $deploy
        cp "$path"/QtDBus.dylib            $deploy
        cp "$path"/QtPrintSupport.dylib    $deploy

        if [ $qt = "qt5" ]; then

            cp "$path"/QtXmlPatterns.dylib $deploy
        else
            cp "$path"/QtCore5Compat.dylib $deploy
            cp "$path"/QtQmlMeta.dylib     $deploy
            cp "$path"/QtPositioning.dylib $deploy
            cp "$path"/QtWeb*.dylib        $deploy
        fi

        if [ -f "$path"/QtQmlModels.dylib ]; then

            cp "$path"/QtQmlModels.dylib       $deploy
            cp "$path"/QtQmlWorkerScript.dylib $deploy
        fi

        cp "$path"/platforms/libqcocoa.dylib $deploy/platforms

        cp "$path"/imageformats/libqsvg.dylib  $deploy/imageformats
        cp "$path"/imageformats/libqjpeg.dylib $deploy/imageformats
        cp "$path"/imageformats/libqwebp.dylib $deploy/imageformats

        if [ $qt = "qt5" ]; then

            cp "$path"/mediaservice/libqavfcamera.dylib $deploy/mediaservice
        else
            cp "$path"/tls/libqopensslbackend.dylib         $deploy/tls
            cp "$path"/tls/libqsecuretransportbackend.dylib $deploy/tls

            cp "$path"/multimedia/libffmpegmediaplugin.dylib $deploy/multimedia
        fi

        cp "$path"/$QtQuick/libqtquick2plugin.dylib $deploy/$QtQuick
        cp "$path"/$QtQuick/qmldir                  $deploy/$QtQuick

        cp "$path"/QtMultimedia/lib*multimedia*.dylib $deploy/QtMultimedia
        cp "$path"/QtMultimedia/qmldir                $deploy/QtMultimedia

        if [ $qt = "qt6" ]; then

            copyQml QtQml/WorkerScript dylib

            copyQml QtWebView    dylib
            copyQml QtWebEngine  dylib
            copyQml QtWebChannel dylib
        fi
    fi

elif [ $1 = "linux" ]; then

    if [ $qt = "qt4" ]; then

        mkdir $deploy/imageformats

        #cp "$path"/libpng16.so.16 $deploy

        cp "$path"/libQtCore.so.4        $deploy
        cp "$path"/libQtGui.so.4         $deploy
        cp "$path"/libQtDeclarative.so.4 $deploy
        cp "$path"/libQtNetwork.so.4     $deploy
        cp "$path"/libQtOpenGL.so.4      $deploy
        cp "$path"/libQtScript.so.4      $deploy
        cp "$path"/libQtSql.so.4         $deploy
        cp "$path"/libQtSvg.so.4         $deploy
        cp "$path"/libQtWebKit.so.4      $deploy
        cp "$path"/libQtXml.so.4         $deploy
        cp "$path"/libQtXmlPatterns.so.4 $deploy

        cp "$path"/imageformats/libqsvg.so  $deploy/imageformats
        cp "$path"/imageformats/libqjpeg.so $deploy/imageformats
    else
        if [ $qt = "qt6" ]; then

            # NOTE: Required for the webview.
            cp -r "$path"/resources/* $deploy

            cp "$path"/QtWebEngineProcess* $deploy
        fi

        mkdir $deploy/xcbglintegrations

        #cp "$path"/libz.so.* $deploy

        cp "$path"/libicudata.so.* $deploy
        cp "$path"/libicui18n.so.* $deploy
        cp "$path"/libicuuc.so.*   $deploy

        #cp "$path"/libdouble-conversion.so.* $deploy
        #cp "$path"/libpng16.so.*             $deploy
        #cp "$path"/libharfbuzz.so.*          $deploy
        #cp "$path"/libxcb-xinerama.so.*      $deploy

        # NOTE: Required for Ubuntu 20.04.
        #if [ -f "$path"/libpcre2-16.so.0 ]; then

            #cp "$path"/libpcre2-16.so.0 $deploy
        #fi

        cp "$path/lib$QtX"Core.so.$qx            $deploy
        cp "$path/lib$QtX"Gui.so.$qx             $deploy
        cp "$path/lib$QtX"Network.so.$qx         $deploy
        cp "$path/lib$QtX"OpenGL.so.$qx          $deploy
        cp "$path/lib$QtX"Qml.so.$qx             $deploy
        cp "$path/lib$QtX"Quick.so.$qx           $deploy
        cp "$path/lib$QtX"Svg.so.$qx             $deploy
        cp "$path/lib$QtX"Widgets.so.$qx         $deploy
        cp "$path/lib$QtX"Xml.so.$qx             $deploy
        cp "$path/lib$QtX"Multimedia.so.$qx      $deploy
        cp "$path/lib$QtX"MultimediaQuick.so.$qx $deploy
        cp "$path/lib$QtX"XcbQpa.so.$qx          $deploy
        cp "$path/lib$QtX"DBus.so.$qx            $deploy

        if [ $qt = "qt5" ]; then

            cp "$path/lib$QtX"XmlPatterns.so.$qx $deploy
        else
            cp "$path/lib$QtX"Core5Compat.so.$qx $deploy
            cp "$path/lib$QtX"QmlMeta.so.$qx     $deploy
            cp "$path/lib$QtX"Positioning.so.$qx $deploy
            cp "$path/lib$QtX"Web*.so.$qx        $deploy
        fi

        if [ -f "$path/lib$QtX"QmlModels.so.$qx ]; then

            cp "$path/lib$QtX"QmlModels.so.$qx       $deploy
            cp "$path/lib$QtX"QmlWorkerScript.so.$qx $deploy
        fi

        cp "$path"/platforms/libqxcb.so $deploy/platforms

        cp "$path"/imageformats/libqsvg.so  $deploy/imageformats
        cp "$path"/imageformats/libqjpeg.so $deploy/imageformats

        if [ -f "$path"/imageformats/libqwebp.so ]; then

            cp "$path"/imageformats/libqwebp.so $deploy/imageformats
        fi

        if [ $qt = "qt5" ]; then

            cp "$path"/mediaservice/libgstcamerabin.so $deploy/mediaservice
        else
            cp "$path"/tls/libqopensslbackend.so $deploy/tls

            cp "$path"/multimedia/libffmpegmediaplugin.so $deploy/multimedia
        fi

        cp "$path"/xcbglintegrations/libqxcb-egl-integration.so $deploy/xcbglintegrations
        cp "$path"/xcbglintegrations/libqxcb-glx-integration.so $deploy/xcbglintegrations

        cp "$path"/$QtQuick/libqtquick2plugin.so $deploy/$QtQuick
        cp "$path"/$QtQuick/qmldir               $deploy/$QtQuick

        cp "$path"/QtMultimedia/lib*multimedia*.so $deploy/QtMultimedia
        cp "$path"/QtMultimedia/qmldir             $deploy/QtMultimedia

        if [ $qt = "qt6" ]; then

            copyQml QtQml/WorkerScript so

            copyQml QtWebView    so
            copyQml QtWebEngine  so
            copyQml QtWebChannel so
        fi
    fi
fi

#--------------------------------------------------------------------------------------------------
# SSL
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    if [ $qt = "qt4" ]; then

        cp "$path"/libeay32.dll $deploy
        cp "$path"/ssleay32.dll $deploy
    else
        cp "$path"/libssl*.dll    $deploy
        cp "$path"/libcrypto*.dll $deploy
    fi

elif [ $1 = "linux" ]; then

    cp "$path"/libssl.so*    $deploy
    cp "$path"/libcrypto.so* $deploy
fi

#--------------------------------------------------------------------------------------------------
# VLC
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    cp -r "$path"/plugins $deploy

    cp "$path"/libvlc*.dll $deploy

elif [ $1 = "macOS" ]; then

    cp -r "$path"/plugins $deploy

    cp "$path"/libvlc*.dylib $deploy

elif [ $1 = "linux" ]; then

    cp -r "$path"/vlc $deploy

    cp "$path"/libvlc*.so* $deploy

    if [ -f "$path"/libidn.so* ]; then

        cp "$path"/libidn.so* $deploy
    fi
fi

#--------------------------------------------------------------------------------------------------
# libtorrent
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    cp "$path"/*torrent-rasterbar.dll $deploy

elif [ $1 = "macOS" ]; then

    cp "$path"/libtorrent-rasterbar.dylib $deploy

elif [ $1 = "linux" ]; then

    cp "$path"/libtorrent-rasterbar*.so* $deploy
fi

#--------------------------------------------------------------------------------------------------
# Boost
#--------------------------------------------------------------------------------------------------

if [ $1 = "macOS" ]; then

    cp "$path"/libboost*.dylib $deploy

elif [ $1 = "linux" ]; then

    cp "$path"/libboost*.so* $deploy
fi

echo "-------------"
echo ""

#--------------------------------------------------------------------------------------------------
# sky
#--------------------------------------------------------------------------------------------------

echo "COPYING $target"

if [ $os = "windows" ]; then

    cp bin/$target.exe $deploy

    cp dist/script/sky.sh $deploy

    chmod +x $deploy/sky.sh

elif [ $1 = "macOS" ]; then

    cd $deploy

    #----------------------------------------------------------------------------------------------
    # target

    installMacOS QtCore    $target
    installMacOS QtGui     $target
    installMacOS QtNetwork $target
    installMacOS QtOpenGL  $target
    installMacOS QtQml     $target

    if [ -f QtQmlModels.dylib ]; then

        installMacOS QtQmlModels $target
    fi

    installMacOS QtQuick      $target
    installMacOS QtSvg        $target
    installMacOS QtWidgets    $target
    installMacOS QtXml        $target
    installMacOS QtMultimedia $target

    if [ $qt = "qt5" ]; then

        installMacOS QtXmlPatterns $target
    else
        installMacOS QtCore5Compat     $target
        installMacOS QtQmlWorkerScript $target
        installMacOS QtQmlMeta         $target
        installMacOS QtPositioning     $target
        installMacOS QtWebView         $target
        installMacOS QtWebChannel      $target
        installMacOS QtWebChannelQuick $target
        installMacOS QtWebEngineCore   $target
        installMacOS QtWebEngineQuick  $target
    fi

    otool -L $target

    #----------------------------------------------------------------------------------------------
    # QtWebEngineProcess

    if [ $qt = "qt6" ]; then

        installMacOS QtCore            $target
        installMacOS QtGui             $target
        installMacOS QtNetwork         $target
        installMacOS QtOpenGL          $target
        installMacOS QtQml             $target
        installMacOS QtQuick           $target
        installMacOS QtQmlModels       $target
        installMacOS QtQmlWorkerScript $target
        installMacOS QtQmlMeta         $target
        installMacOS QtPositioning     $target
        installMacOS QtWebChannel      $target
        installMacOS QtWebEngineCore   $target
        installMacOS QtWebEngineQuick  $target

        otool -L $target
    fi

    #----------------------------------------------------------------------------------------------
    # QtGui

    if [ $qt = "qt6" ]; then

        install_name_tool -change @rpath/QtDBus.framework/Versions/$qx/QtDBus \
                                  @loader_path/QtDBus.dylib QtGui.dylib
    fi

    otool -L QtGui.dylib

    #----------------------------------------------------------------------------------------------
    # platforms

    if [ $qt = "qt5" ]; then

        install_name_tool -change @rpath/QtDBus.framework/Versions/$qx/QtDBus \
                                  @loader_path/../QtDBus.dylib platforms/libqcocoa.dylib

        install_name_tool -change @rpath/QtPrintSupport.framework/Versions/$qx/QtPrintSupport \
                                  @loader_path/../QtPrintSupport.dylib platforms/libqcocoa.dylib
    fi

    otool -L platforms/libqcocoa.dylib

    #----------------------------------------------------------------------------------------------
    # QtQml

    #if [ $qt = "qt6" ]; then
    #
    #   install_name_tool -change \
    #                      @rpath/QtQmlWorkerScript.framework/Versions/$qx/QtQmlWorkerScript \
    #                      @loader_path/../QtQmlWorkerScript.dylib \
    #                      QtQml/WorkerScript/libworkerscriptplugin.dylib
    #
    #    otool -L QtQml/WorkerScript/libworkerscriptplugin.dylib
    #fi

    #----------------------------------------------------------------------------------------------
    # QtQuick

    if [ $qt = "qt5" ]; then

        if [ -f QtQmlModels.dylib ]; then

            install_name_tool -change \
                              @rpath/QtQmlWorkerScript.framework/Versions/$qx/QtQmlWorkerScript \
                              @loader_path/../QtQmlWorkerScript.dylib \
                              $QtQuick/libqtquick2plugin.dylib
        fi
    fi

    otool -L $QtQuick/libqtquick2plugin.dylib

    #----------------------------------------------------------------------------------------------
    # QtMultimedia

    if [ $qt = "qt5" ]; then

        libmultimedia="libdeclarative_multimedia"
    else
        libmultimedia="libquickmultimediaplugin"
    fi

    install_name_tool -change \
                      @rpath/QtMultimedia.framework/Versions/$qx/QtMultimedia \
                      @loader_path/../QtMultimedia.dylib \
                      QtMultimedia/$libmultimedia.dylib

    install_name_tool -change \
                      @rpath/QtMultimediaQuick.framework/Versions/$qx/QtMultimediaQuick \
                      @loader_path/../QtMultimediaQuick.dylib \
                      QtMultimedia/$libmultimedia.dylib

    otool -L QtMultimedia/$libmultimedia.dylib

    #----------------------------------------------------------------------------------------------
    # QtWebView

    if [ $qt = "qt6" ]; then

        install_name_tool -change \
                          @rpath/QtWebViewQuick.framework/Versions/$qx/QtWebViewQuick \
                          @loader_path/../QtWebViewQuick.dylib \
                          QtWebView/libqtwebviewquickplugin.dylib

        otool -L QtWebView/libqtwebviewquickplugin.dylib
    fi

    #----------------------------------------------------------------------------------------------
    # VLC

    install_name_tool -change @rpath/libvlccore.dylib \
                              @loader_path/libvlccore.dylib libvlc.dylib

    otool -L libvlc.dylib

    #----------------------------------------------------------------------------------------------
    # libtorrent

    install_name_tool -change libboost_system.dylib \
                              @loader_path/libboost_system.dylib libtorrent-rasterbar.dylib

    otool -L libtorrent-rasterbar.dylib

    #----------------------------------------------------------------------------------------------

    cd -

elif [ $1 = "iOS" ]; then

    cp -r bin/$target.app $deploy

elif [ $1 = "linux" ]; then

    cp bin/$target $deploy

    # NOTE: This script is useful for compatibilty. It enforces the application path for libraries.
    cp dist/script/start.sh $deploy

    chmod +x $deploy/start.sh

elif [ $1 = "android" ]; then

    copyAndroid armeabi-v7a
    copyAndroid arm64-v8a
    copyAndroid x86
    copyAndroid x86_64
fi

#--------------------------------------------------------------------------------------------------
# backend
#--------------------------------------------------------------------------------------------------

if [ $os != "mobile" ]; then

    echo "COPYING backend"

    mkdir -p $deploy/backend/cover

    cp "$backend"/cover/* $deploy/backend/cover

    cp "$backend"/*.vbml $deploy/backend
fi

#--------------------------------------------------------------------------------------------------
# script
#--------------------------------------------------------------------------------------------------

if [ $os != "mobile" ]; then

    echo "COPYING script"

    copyFolder "$script" $deploy/script "*.sky"

    echo "COPYING bash"

    copyFolder "$bash" $deploy/bash "*.sh"

    echo "COPYING doc"

    copyFolder "$bash" $deploy/doc "*.md"
fi
