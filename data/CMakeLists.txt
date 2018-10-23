# install our .desktop file so the Applications menu will see it
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/com.github.treagod.httpinspector.desktop DESTINATION ${DATADIR}/applications/)

# install our .appdata.xml file so AppCenter will see it
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/com.github.treagod.httpinspector.appdata.xml DESTINATION ${DATADIR}/metainfo/)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/16x16/com.github.treagod.httpinspector.svg
    DESTINATION ${DATADIR}/icons/hicolor/16x16/apps/)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/24x24/com.github.treagod.httpinspector.svg
    DESTINATION ${DATADIR}/icons/hicolor/24x24/apps/)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/32x32/com.github.treagod.httpinspector.svg
    DESTINATION ${DATADIR}/icons/hicolor/32x32/apps/)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/48x48/com.github.treagod.httpinspector.svg
    DESTINATION ${DATADIR}/icons/hicolor/48x48/apps/)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/64x64/com.github.treagod.httpinspector.svg
    DESTINATION ${DATADIR}/icons/hicolor/64x64/apps/)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/128x128/com.github.treagod.httpinspector.svg
    DESTINATION ${DATADIR}/icons/hicolor/128x128/apps/)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/128x128/com.github.treagod.httpinspector.svg
    DESTINATION ${DATADIR}/icons/hicolor/scalable/apps/)

include (GSettings)
add_schema ("com.github.treagod.httpinspector.gschema.xml")
