# Bundle version: 0.9
#
# File History:
#    - 0.1 : refactoring
#    - 0.2 : fix glib.h: No such file or directory (vala-stacktrace working)
#    - 0.3 : fix library with depending app
#    - 0.4 : add valadoc 

macro(library)
    parse_arguments(ARGS "BINARY_NAME;TITLE;VERSION;RELEASE_NAME;SOVERSION;LINKING;SOURCE_PATH;VALA_FILES;C_FILES;VALA_DEFINES;PACKAGES;C_DEFINES;SCHEMA;VALA_OPTIONS;C_OPTIONS" "" ${ARGN})

    if( NOT ARGS_LINKING)
        message( FATAL_ERROR "${FatalColor}You must specify a LINKING: static or shared${NC}.")
    endif()

    if( NOT ARGS_LINKING STREQUAL "shared" AND NOT ARGS_LINKING STREQUAL "static")
        message( FATAL_ERROR "${FatalColor}The value LINKING must be either static or shared${NC}.")
    endif()

    set (DATADIR "")
    set (PKGDATADIR "")
    set (GETTEXT_PACKAGE "${ARGS_BINARY_NAME}")

    hen_build (
        BINARY_NAME
            ${ARGS_BINARY_NAME}
        TITLE
            ${ARGS_TITLE}
        VERSION
            ${ARGS_VERSION}
        RELEASE_NAME
            ${ARGS_RELEASE_NAME}
        SOURCE_PATH
            ${ARGS_SOURCE_PATH}
        VALA_FILES
            ${ARGS_VALA_FILES}
        C_FILES
            ${ARGS_C_FILES}
        VALA_DEFINES
            ${ARGS_VALA_DEFINES}
        C_DEFINES
            ${ARGS_C_DEFINES}
        PACKAGES
            ${ARGS_PACKAGES}
        SCHEMA
             ${ARGS_SCHEMA}
        VALA_OPTIONS
             ${ARGS_VALA_OPTIONS}
        CONFIG_NAME
            config_lib.vala.cmake
        LINKING
            ${ARGS_LINKING}
        C_OPTIONS
             ${ARGS_C_OPTIONS}
    )

    # Set for the variables substitution in the pc file
    set (DOLLAR "$")
    # TODO fix the output path
    configure_file (${DIR_ELEMENTARY_TEMPLATES}/lib.pc.cmake ${CMAKE_BINARY_DIR}/${ARGS_BINARY_NAME}.pc)
    configure_file (${DIR_ELEMENTARY_TEMPLATES}/lib.deps.cmake ${CMAKE_BINARY_DIR}/${ARGS_BINARY_NAME}.deps)
    add_local_package (${ARGS_BINARY_NAME} ${COMPLETE_DIST_PC_PACKAGES} )

    if( ARGS_LINKING STREQUAL "static")
        add_library (${ARGS_BINARY_NAME} STATIC ${VALA_C} ${C_FILES})
    else()
        add_library (${ARGS_BINARY_NAME} SHARED ${VALA_C} ${C_FILES})
        if( NOT ARGS_SOVERSION)
            message ("${MessageColor}The parameter SO_VERSION is not specified${NC} so '0' is used.")
            set( ARGS_SOVERSION "0")
        endif()

        set_target_properties (${ARGS_BINARY_NAME} PROPERTIES
            OUTPUT_NAME ${ARGS_BINARY_NAME}
            VERSION ${ARGS_VERSION}
            SOVERSION ${ARGS_SOVERSION}
        )
    endif()
    target_link_libraries (${ARGS_BINARY_NAME} ${DEPS_LIBRARIES})

    install_elementary_library (${ARGS_BINARY_NAME} ${ARGS_LINKING})

    # Create dist folder if necessary 
    SET( DIST_PATH "${CMAKE_CURRENT_SOURCE_DIR}/dist")
    if(NOT EXISTS "${DIST_PATH}/valadoc")
        file(MAKE_DIRECTORY "${DIST_PATH}/valadoc")
    endif()
    valadoc ( ${ARGS_BINARY_NAME}  "${DIST_PATH}/valadoc" ${VALA_FILES}
        PACKAGES
            ${VALA_PACKAGES}
        #OPTIONS
        #CUSTOM_VAPIS
        )

endmacro()

macro(install_elementary_library ELEM_NAME BUILD_TYPE)
    if (${BUILD_TYPE} STREQUAL "shared" )
        install (TARGETS ${ELEM_NAME} DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR})
        # Install lib stuffs
        install (FILES ${CMAKE_BINARY_DIR}/${ELEM_NAME}.pc              DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}/pkgconfig/)
        install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${ELEM_NAME}.vapi    DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/vala/vapi/)
        install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${ELEM_NAME}.deps    DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/vala/vapi/)
        install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${ELEM_NAME}.h       DESTINATION ${CMAKE_INSTALL_FULL_INCLUDEDIR}/${ELEM_NAME}/)
    endif ()
    create_uninstall_target ()
endmacro()