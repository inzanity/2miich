# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-toomiich

CONFIG += sailfishapp
QT += network dbus

INCLUDEPATH += 3rdparty/libiphb/src \
    3rdparty/libdsme/include \
    3rdparty/nemo-qml-plugin-dbus/src
LIBS += -lrt

DEFINES += QT_VERSION_5

SOURCES += src/harbour-toomiich.cpp \
    src/diskcache.cpp \
    src/oledify.cpp \
    src/persistenttimer.cpp \
    src/tzdateparser.cpp \
    3rdparty/libiphb/src/libiphb.c \
    3rdparty/nemo-qml-plugin-dbus/src/declarativedbusadaptor.cpp \
    3rdparty/nemo-qml-plugin-dbus/src/declarativedbusinterface.cpp

OTHER_FILES += \
    rpm/harbour-toomiich.changes.in \
    rpm/harbour-toomiich.spec \
    translations/*.ts \
    harbour-toomiich.desktop \
    qml/harbour-toomiich.qml \
    qml/pages/ScoresPage.qml \
    qml/pages/DetailsPage.qml \
    qml/cover/DummyCover.qml \
    qml/cover/ScoresCover.qml \
    qml/pages/StatisticsPage.qml \
    qml/pages/SchedulePage.qml \
    qml/widgets/GoalLabel.qml \
    qml/models/GameModel.qml \
    qml/models/LiigaModel.qml \
    qml/widgets/Logo.qml \
    qml/models/ScheduleModel.qml \
    qml/effects/MonochromeEffect.qml \
    qml/helpers/Toholed.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-toomiich-fi.ts

RESOURCES += \
    harbour-toomiich.qrc

HEADERS += \
    src/diskcache.h \
    src/oledify.h \
    src/persistenttimer.h \
    src/tzdateparser.h \
    3rdparty/libiphb/src/libiphb.h \
    3rdparty/nemo-qml-plugin-dbus/src/declarativedbusadaptor.h \
    3rdparty/nemo-qml-plugin-dbus/src/declarativedbusinterface.h
