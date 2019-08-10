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
PKGCONFIG += libxml-2.0

INCLUDEPATH += 3rdparty/libiphb/src \
    3rdparty/libdsme/include \
    3rdparty/nemo-qml-plugin-dbus/src/plugin \
    3rdparty/nemo-qml-plugin-dbus/src/nemo-dbus \
    3rdparty/nemo-qml-plugin-dbus/src/nemo-dbus/private
LIBS += -lrt

DEFINES += QT_VERSION_5

SOURCES += src/harbour-toomiich.cpp \
    src/diskcache.cpp \
    src/diskcacheimageprovider.cpp \
    src/oledify.cpp \
    src/persistenttimer.cpp \
    src/tzdateparser.cpp \
    src/htmllistmodel.cpp \
    src/htmlrole.cpp \
    3rdparty/libiphb/src/libiphb.c \
    3rdparty/nemo-qml-plugin-dbus/src/plugin/declarativedbusadaptor.cpp \
    3rdparty/nemo-qml-plugin-dbus/src/plugin/declarativedbusinterface.cpp \
    3rdparty/nemo-qml-plugin-dbus/src/plugin/declarativedbus.cpp \
    3rdparty/nemo-qml-plugin-dbus/src/nemo-dbus/dbus.cpp \
    3rdparty/nemo-qml-plugin-dbus/src/nemo-dbus/connection.cpp \
    3rdparty/nemo-qml-plugin-dbus/src/nemo-dbus/private/propertychanges.cpp \
    3rdparty/nemo-qml-plugin-dbus/src/nemo-dbus/logging.cpp \
    3rdparty/nemo-qml-plugin-dbus/src/nemo-dbus/response.cpp

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
    qml/helpers/Toholed.qml \
    qml/widgets/WidthLabel.qml \
    qml/models/StandingsModel.qml \
    qml/models/LeaderModel.qml \
    qml/models/PlayerListModel.qml \
    qml/widgets/Heading.qml \
    qml/models/ShotsModel.qml \
    qml/pages/RosterPage.qml \
    qml/models/RosterModel.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-toomiich-fi.ts

RESOURCES += \
    harbour-toomiich.qrc

HEADERS += \
    src/diskcache.h \
    src/diskcacheimageprovider.h \
    src/oledify.h \
    src/persistenttimer.h \
    src/tzdateparser.h \
    src/htmllistmodel.h \
    src/htmlrole.h \
    3rdparty/libiphb/src/libiphb.h \
    3rdparty/nemo-qml-plugin-dbus/src/plugin/declarativedbusadaptor.h \
    3rdparty/nemo-qml-plugin-dbus/src/plugin/declarativedbusinterface.h \
    3rdparty/nemo-qml-plugin-dbus/src/plugin/declarativedbus.h \
    3rdparty/nemo-qml-plugin-dbus/src/nemo-dbus/dbus.h \
    3rdparty/nemo-qml-plugin-dbus/src/nemo-dbus/connection.h \
    3rdparty/nemo-qml-plugin-dbus/src/nemo-dbus/response.h \
    3rdparty/nemo-qml-plugin-dbus/src/nemo-dbus/global.h \
    3rdparty/nemo-qml-plugin-dbus/src/nemo-dbus/private/connectiondata.h \
    3rdparty/nemo-qml-plugin-dbus/src/nemo-dbus/logging.h \
    3rdparty/nemo-qml-plugin-dbus/src/nemo-dbus/private/propertychanges.h
