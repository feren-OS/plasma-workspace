set(ion_wettercom_SRCS ion_wettercom.cpp)
ecm_qt_declare_logging_category(ion_wettercom_SRCS
    HEADER ion_wettercomdebug.h
    IDENTIFIER IONENGINE_WETTERCOM
    CATEGORY_NAME kde.dataengine.ion.wettercom
    DEFAULT_SEVERITY Info
)
add_library(ion_wettercom MODULE ${ion_wettercom_SRCS})
target_link_libraries(ion_wettercom
    weather_ion
    KF5::KIOCore
    KF5::UnitConversion
    KF5::I18n
)

install(TARGETS ion_wettercom DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/dataengine)

