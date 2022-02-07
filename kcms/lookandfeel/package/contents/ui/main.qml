/*
    SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-only
*/

import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtQuick.Controls 2.3 as QtControls
import org.kde.kirigami 2.8 as Kirigami
import org.kde.newstuff 1.62 as NewStuff
import org.kde.kconfig 1.0 // for KAuthorized
import org.kde.kcm 1.3 as KCM

KCM.GridViewKCM {
    id: root
    KCM.ConfigModule.quickHelp: i18n("This module lets you choose the global look and feel.")

    function showConfirmation() { //Show the Kirigami Sheet
        stackSwitcher.currentIndex = 0;
        lessOptionsButton.visible = false;
        moreOptionsButton.visible = true;
        kcm.onClickedCheckboxRefresh(); //TODO: Rename this once we've got functions working
        globalThemeConfirmSheet.open();
        proceedButton.forceActiveFocus();
    }
    Connections {
        target: kcm
        function onShowConfirmation() {
            root.showConfirmation();
        }
    }

    view.model: kcm.lookAndFeelModel
    view.currentIndex: kcm.pluginIndex(kcm.lookAndFeelSettings.lookAndFeelPackage)

    KCM.SettingStateBinding {
        configObject: kcm.lookAndFeelSettings
        settingName: "lookAndFeelPackage"
    }

    view.delegate: KCM.GridDelegate {
        id: delegate

        text: model.display
        subtitle: model.hasDesktopLayout ? i18n("Contains desktop layout") : ""
        toolTip: model.description

        thumbnailAvailable: model.screenshot
        thumbnail: Image {
            anchors.fill: parent
            source: model.screenshot || ""
            sourceSize: Qt.size(delegate.GridView.view.cellWidth * Screen.devicePixelRatio,
                                delegate.GridView.view.cellHeight * Screen.devicePixelRatio)
        }
        actions: [
            Kirigami.Action {
                visible: model.fullScreenPreview !== ""
                iconName: "view-preview"
                tooltip: i18n("Preview Theme")
                onTriggered: {
                    previewWindow.url = model.fullScreenPreview;
                    previewWindow.showFullScreen();
                }
            }
        ]
        onClicked: {
            kcm.lookAndFeelSettings.lookAndFeelPackage = model.pluginName;
            view.forceActiveFocus();

            root.showConfirmation();
        }
    }

    Kirigami.OverlaySheet {
        id: globalThemeConfirmSheet

        header: RowLayout {
            Kirigami.Heading {
                id: globalThemeConfirmHeader
                text: i18n("Apply Global Theme?")
            }
        }
        QtControls.SwipeView {
            id: stackSwitcher
            interactive: false

            //FIXME: Size is inconsistent between the two panes, so there's A LOT of resizing... and there's a glitch by the way with Kirigami's close animation (resized popups' close animations account for their original size, not the new size)
            
            Keys.onEscapePressed: {
                globalThemeConfirmSheet.close()
                event.accepted = true
            }
            ColumnLayout {
                ColumnLayout {
                    id: main

                    spacing: Kirigami.Units.smallSpacing

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing

                    QtControls.CheckBox {
                        id: applyGlobalThemeCheckbox
                        checked: kcm.applyGlobalTheme
                        text: i18n("Apply appearance settings from theme")
                        onCheckedChanged: kcm.applyGlobalTheme = checked;
                        enabled: kcm.applyGlobalThemeAvailable == true;
                    }
                    QtControls.CheckBox {
                        id: resetCheckbox
                        checked: kcm.resetDefaultLayout
                        text: i18n("Use desktop layout from theme")
                        onCheckedChanged: kcm.resetDefaultLayout = checked;
                        enabled: kcm.resetDefaultLayoutAvailable == true;
                    }
                }
            }
            ColumnLayout {
                ColumnLayout {
                    id: subscreen

                    spacing: Kirigami.Units.smallSpacing

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing

                    QtControls.CheckBox {
                        id: resetCheckboxSub
                        checked: kcm.resetDefaultLayout
                        text: i18n("Use desktop layout from theme")
                        onCheckedChanged: kcm.resetDefaultLayout = checked;
                        enabled: kcm.resetDefaultLayoutAvailable == true;
                    }
                    Kirigami.Separator { Layout.fillWidth: true }
                    QtControls.CheckBox {
                        id: colorsCheckbox
                        checked: kcm.applyColors
                        text: i18n("Apply theme's color scheme")
                        onCheckedChanged: kcm.applyColors = checked;
                        enabled: kcm.applyColorsAvailable == true;
                    }
                    QtControls.CheckBox {
                        id: widgetStyleCheckbox
                        checked: kcm.applyWidgetStyle
                        text: i18n("Apply theme's application style")
                        onCheckedChanged: kcm.applyWidgetStyle = checked;
                        enabled: kcm.applyWidgetStyleAvailable == true;
                    }
                    QtControls.CheckBox {
                        id: iconsCheckbox
                        checked: kcm.applyIcons
                        text: i18n("Apply theme's icons")
                        onCheckedChanged: kcm.applyIcons = checked;
                        enabled: kcm.applyIconsAvailable == true;
                    }
                    QtControls.CheckBox {
                        id: plasmaThemeCheckbox
                        checked: kcm.applyPlasmaTheme
                        text: i18n("Apply theme's Plasma style")
                        onCheckedChanged: kcm.applyPlasmaTheme = checked;
                        enabled: kcm.applyPlasmaThemeAvailable == true;
                    }
                    QtControls.CheckBox {
                        id: cursorsCheckbox
                        checked: kcm.applyCursors
                        text: i18n("Apply theme's cursors")
                        onCheckedChanged: kcm.applyCursors = checked;
                        enabled: kcm.applyCursorsAvailable == true;
                    }
                    QtControls.CheckBox {
                        id: splashScreenCheckbox
                        checked: kcm.applySplashScreen
                        text: i18n("Apply theme's splash screen")
                        onCheckedChanged: kcm.applySplashScreen = checked;
                        enabled: kcm.applySplashScreenAvailable == true;
                    }
                    QtControls.CheckBox {
                        id: lockScreenCheckbox
                        checked: kcm.applyLockScreen
                        text: i18n("Apply theme's lock screen")
                        onCheckedChanged: kcm.applyLockScreen = checked;
                        enabled: kcm.applyLockScreenAvailable == true;
                    }
                    QtControls.CheckBox {
                        id: windowDecorationCheckbox
                        checked: kcm.applyWindowDecoration
                        text: i18n("Apply theme's window decorations")
                        onCheckedChanged: kcm.applyWindowDecoration = checked;
                        enabled: kcm.applyWindowDecorationAvailable == true;
                    }
                }
            }
        }
        footer: ColumnLayout {
            Kirigami.InlineMessage {
                Layout.fillWidth: true
                type: Kirigami.MessageType.Warning
                text: i18n("Your current layout and configuration of panels, desktop widgets, and wallpapers will be lost and reset to the default layout provided by the selected theme.")
                visible: resetCheckbox.checked
            }
            
            //TODO: Make these non-generic buttons, especially Proceed and Cancel
            
            RowLayout {
                QtControls.Button {
                    id: moreOptionsButton
                    text: i18n("Choose what is applied...")
                    enabled: applyGlobalThemeCheckbox.enabled //Temporary until there's Desktop Layout options
                    onClicked: {
                        stackSwitcher.currentIndex = 1;
                        lessOptionsButton.visible = true;
                        moreOptionsButton.visible = false;
                        kcm.onClickedCheckboxRefresh(); //Force a refresh to reset button states
                    }
                }
                QtControls.Button {
                    id: lessOptionsButton
                    visible: false
                    text: i18n("Less options...")
                    onClicked: {
                        stackSwitcher.currentIndex = 0;
                        lessOptionsButton.visible = false;
                        moreOptionsButton.visible = true;
                        kcm.onClickedCheckboxRefresh(); //Force a refresh to reset button states
                    }
                }
                Rectangle {
                    Layout.fillWidth: true;
                }
                QtControls.Button {
                    id: proceedButton
                    text: i18n("Proceed")
                    onClicked: {
                        globalThemeConfirmSheet.close();
                        kcm.save();
                    }
                    enabled: resetCheckbox.checked || applyGlobalThemeCheckbox.checked
                }
                QtControls.Button {
                    text: i18n("Cancel")
                    onClicked: {
                        globalThemeConfirmSheet.close();
                    }
                }
            }
        }
    }

    footer: ColumnLayout {
        RowLayout {
            Layout.fillWidth: true

            Kirigami.ActionToolBar {
                flat: false
                alignment: Qt.AlignRight
                actions: [
                    Kirigami.Action {
                        text: i18n("Get New Global Themes…")
                        icon.name: "get-hot-new-stuff"
                        onTriggered: { newStuffPage.open(); }
                    }
                ]
            }
        }
    }

    Loader {
        id: newStuffPage

        // Use this function to open the dialog. It seems roundabout, but this ensures
        // that the dialog is not constructed until we want it to be shown the first time,
        // since it will initialise itself on the first load (which causes it to phone
        // home) and we don't want that until the user explicitly asks for it.
        function open() {
            if (item) {
                item.open();
            } else {
                active = true;
            }
        }
        onLoaded: {
            item.open();
        }

        active: false
        asynchronous: true

        sourceComponent: NewStuff.Dialog {
            configFile: "lookandfeel.knsrc"
            viewMode: NewStuff.Page.ViewMode.Preview
            Connections {
                target: newStuffPage.item.engine
                function onEntryEvent(entry, event) {
                    if (event == 2) { // AdoptedEvent
                        kcm.reloadConfig();
                    } else if (event == 1) { // StatusChangedEvent
                        kcm.knsEntryChanged(entry);
                    }
                }
            }
        }
    }

    Window {
        id: previewWindow
        property alias url: previewImage.source
        color: Qt.rgba(0, 0, 0, 0.7)
        MouseArea {
            anchors.fill: parent
            Image {
                id: previewImage
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                width: Math.min(parent.width, sourceSize.width)
                height: Math.min(parent.height, sourceSize.height)
            }
            onClicked: previewWindow.close()
            QtControls.ToolButton {
                anchors {
                    top: parent.top
                    right: parent.right
                }
                icon.name: "window-close"
                onClicked: previewWindow.close()
            }
            Shortcut {
                onActivated: previewWindow.close()
                sequence: "Esc"
            }
        }
    }
}
