add_definitions("-DQT_NO_CAST_FROM_ASCII -DQT_NO_CAST_TO_ASCII")
add_definitions(-DQT_NO_NARROWING_CONVERSIONS_IN_CONNECT)

set(plasmawindowed-app_SRCS
    plasmawindowedcorona.cpp
    plasmawindowedview.cpp
    plasmawindowedcorona.h
    plasmawindowedview.h
    main.cpp
)

add_executable(plasmawindowed ${plasmawindowed-app_SRCS})

target_link_libraries(
    plasmawindowed
    Qt::Widgets
    Qt::Quick
    Qt::Qml
    KF5::I18n
    KF5::IconThemes
    KF5::XmlGui
    KF5::PlasmaQuick
    KF5::Plasma
    KF5::DBusAddons
    KF5::Notifications
    KF5::Package
)

install(TARGETS plasmawindowed ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
#even if hidden, the desktop file is needed anyways for kdbusservice::unique
configure_file(org.kde.plasmawindowed.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/org.kde.plasmawindowed.desktop @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.kde.plasmawindowed.desktop DESTINATION ${KDE_INSTALL_APPDIR})
