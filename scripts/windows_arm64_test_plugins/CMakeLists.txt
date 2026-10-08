cmake_minimum_required(VERSION 3.15)
project(PedalboardTestPlugins VERSION 1.0.0)

set(PEDALBOARD_JUCE_DIR "" CACHE PATH "Path to pedalboard's JUCE submodule")
set(CHOW_SOURCE_DIR "" CACHE PATH "Checkout of jatinchowdhury18/AnalogTapeModel at v2.7.0")
set(M8BP_SOURCE_DIR "" CACHE PATH "Checkout of yokemura/Magical8bitPlug2 at v1.0.1")
set(CHOW_PLUGIN_DIR "${CHOW_SOURCE_DIR}/Plugin")

add_subdirectory("${PEDALBOARD_JUCE_DIR}" JUCE)
include("${CMAKE_CURRENT_LIST_DIR}/sources.cmake")

# CHOWTapeModel 2.7.0. The plugin code matches the one Projucer derived from the
# project ID, so that the VST3 class ID (and thus presets) match the x64 build.
juce_add_module("${CHOW_PLUGIN_DIR}/foleys_gui_magic")
juce_add_plugin(CHOWTapeModel
    VERSION 2.7.0
    COMPANY_NAME chowdsp
    COMPANY_EMAIL chowdsp@gmail.com
    PLUGIN_MANUFACTURER_CODE Chow
    PLUGIN_CODE Jdox
    PRODUCT_NAME CHOWTapeModel
    FORMATS VST3)
juce_generate_juce_header(CHOWTapeModel)
juce_add_binary_data(CHOWTapeModelData SOURCES ${CHOW_RESOURCES})
target_sources(CHOWTapeModel PRIVATE ${CHOW_SOURCES})
target_compile_definitions(CHOWTapeModel PUBLIC
    JUCE_VST3_CAN_REPLACE_VST2=0
    JUCE_STRICT_REFCOUNTEDPOINTER=1
    JUCE_WEB_BROWSER=0
    JUCE_USE_CURL=0
    FOLEYS_SHOW_GUI_EDITOR_PALLETTE=0
    FOLEYS_ENABLE_BINARY_DATA=1
    # Built against JUCE 6.0, which still had modal FileChooser methods:
    JUCE_MODAL_LOOPS_PERMITTED=1)
target_compile_options(CHOWTapeModel PRIVATE /wd4458)
target_compile_features(CHOWTapeModel PRIVATE cxx_std_17)
target_link_libraries(CHOWTapeModel
    PRIVATE
        CHOWTapeModelData
        foleys_gui_magic
        juce::juce_audio_utils
        juce::juce_dsp
        juce::juce_opengl
    PUBLIC
        juce::juce_recommended_config_flags
        juce::juce_recommended_lto_flags)

# Magical8bitPlug2 1.0.1
juce_add_plugin(Magical8bitPlug2
    VERSION 1.0.1
    COMPANY_NAME Ymck
    COMPANY_WEBSITE http://ymck.net
    COMPANY_EMAIL info@ymck.net
    PLUGIN_MANUFACTURER_CODE Ymck
    PLUGIN_CODE synj
    PRODUCT_NAME Magical8bitPlug2
    PLUGIN_NAME "Magical 8bit Plug 2"
    DESCRIPTION "8bit sound generator 2nd ver. by YMCK"
    BUNDLE_ID com.ymck.magical8bitPlug2Juce
    IS_SYNTH TRUE
    NEEDS_MIDI_INPUT TRUE
    FORMATS VST3)
juce_generate_juce_header(Magical8bitPlug2)
juce_add_binary_data(Magical8bitPlug2Data SOURCES ${M8BP_RESOURCES})
target_sources(Magical8bitPlug2 PRIVATE ${M8BP_SOURCES})
target_compile_definitions(Magical8bitPlug2 PUBLIC
    JUCE_VST3_CAN_REPLACE_VST2=0
    JUCE_STRICT_REFCOUNTEDPOINTER=1
    JUCE_WEB_BROWSER=0
    JUCE_USE_CURL=0
    "JucePlugin_PreferredChannelConfigurations={0,2}")
target_link_libraries(Magical8bitPlug2
    PRIVATE
        Magical8bitPlug2Data
        juce::juce_audio_utils
        juce::juce_cryptography
        juce::juce_opengl
    PUBLIC
        juce::juce_recommended_config_flags
        juce::juce_recommended_lto_flags)
