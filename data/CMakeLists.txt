# install our .desktop file so the Applications menu will see it
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/com.github.treagod.httpinspector.desktop DESTINATION ${DATADIR}/applications/)

# install our .appdata.xml file so AppCenter will see it
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/com.github.treagod.httpinspector.appdata.xml DESTINATION ${DATADIR}/metainfo/)

include (GSettings)
add_schema ("com.github.treagod.httpinspector.gschema.xml")
