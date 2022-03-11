/*
    SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2022 Dominic Hayes <ferenosdev@outlook.com>

    SPDX-License-Identifier: LGPL-2.0-only
*/

import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtQuick.Controls 2.3 as QtControls
import org.kde.kirigami 2.8 as Kirigami
import org.kde.newstuff 1.81 as NewStuff
import org.kde.kconfig 1.0 // for KAuthorized
import org.kde.kcm 1.3 as KCM
import org.kde.private.kcms.lookandfeel 1.0 as Private

KCM.GridViewKCM {
    id: root
    KCM.ConfigModule.quickHelp: i18n("This module lets you choose the global look and feel.")

    function showConfirmation() { //Show the Kirigami Sheet
        stackSwitcher.currentIndex = 0
        lessOptionsButton.visible = false
        moreOptionsButton.visible = true
        resetCheckboxes()
        globalThemeConfirmSheet.open()
        proceedButton.forceActiveFocus()
    }
    function resetCheckboxes() { //This call is used whenever you switch pages (More/Less Options) or trigger the Kirigami Sheet
        setGlobalThemeCheckboxes(true)
        setDesktopLayoutCheckboxes(!globalThemeCheckbox.enabled)
    }
    function setGlobalThemeCheckboxes(value) { //Set the subcheckboxes too so nothing is unintentionally applied
        if (value === undefined) {
            value = false
        }
        globalThemeCheckbox.checked = globalThemeCheckbox.enabled && value
        colorsCheckbox.checked = colorsCheckbox.enabled && value
        widgetStyleCheckbox.checked = widgetStyleCheckbox.enabled && value
        windowDecorationCheckbox.checked = windowDecorationCheckbox.enabled && value
        iconsCheckbox.checked = iconsCheckbox.enabled && value
        plasmaThemeCheckbox.checked = plasmaThemeCheckbox.enabled && value
        cursorsCheckbox.checked = cursorsCheckbox.enabled && value
        windowSwitcherCheckbox.checked = windowSwitcherCheckbox.enabled && value
        splashScreenCheckbox.checked = splashScreenCheckbox.enabled && value
        lockScreenCheckbox.checked = lockScreenCheckbox.enabled && value
    }
    function setDesktopLayoutCheckboxes(value) { //Same with Desktop layout's subcheckboxes
        if (value === undefined) {
            value = false
        }
        resetCheckbox.checked = resetCheckbox.enabled && value
        resetCheckboxSub.checked = resetCheckbox.enabled && value
        titlebarLayoutCheckbox.checked = resetCheckbox.enabled && value
    }
    Connections {
        target: kcm
        function onShowConfirmation() {
            root.showConfirmation()
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
        subtitle: model.hasDesktopLayout ? i18n("Contains Desktop layout") : ""
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
                    previewWindow.url = model.fullScreenPreview
                    previewWindow.showFullScreen()
                }
            }
        ]
        onClicked: {
            kcm.lookAndFeelSettings.lookAndFeelPackage = model.pluginName
            root.showConfirmation()
        }
        onDoubleClicked: {
            kcm.save()
        }
    }

    Kirigami.OverlaySheet {
        id: globalThemeConfirmSheet
        property int selectedOptions
        title: i18nc("Confirmation question about applying the Global Theme - %1 is the Global Theme's name",
                     "Apply %1?", view.model.data(view.model.index(view.currentIndex, 0),
                                    Qt.Display))
        QtControls.SwipeView {
            id: stackSwitcher
            interactive: false
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
            ColumnLayout {
                id: main
                Kirigami.FormLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing

                    QtControls.Label {
                        Layout.fillWidth: true
                        text: i18n("The following will be applied by this Global Theme:")
                        wrapMode: Text.WordWrap
                    }
                    //Checkboxes NOTE: onCheckedChanged is used here due to resetCheckboxes and
                    //setGlobalThemeCheckboxes, etc. - onToggled only accounts for user-done changes,
                    //NOT code-done changes, to 'checked'
                    QtControls.CheckBox {
                        id: globalThemeCheckbox
                        checked: enabled
                        text: i18n("Appearance settings")
                        onCheckedChanged: {
                            if (checked) {
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.GlobalTheme
                            } else {
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.GlobalTheme
                            }
                            setGlobalThemeCheckboxes(checked) //Set the checkboxes on the More Options page to match this new state
                        }
                        enabled: view.model.data(view.model.index(view.currentIndex, 0), Private.KCMLookandFeel.HasGlobalThemeRole)
                        //enabled is needed because lblsub can make it invisible
                        visible: enabled && !globalThemeCheckboxLblSub.visible
                    }
                    QtControls.Label { //These labels sub in for the checkboxes when they're the only visible checkbox in this page
                        id: globalThemeCheckboxLblSub
                        visible: !resetCheckbox.enabled && globalThemeCheckbox.enabled
                        Layout.fillWidth: true
                        text: i18nc("List item", "• Appearance settings")
                        wrapMode: Text.WordWrap
                    }
                    QtControls.CheckBox {
                        id: resetCheckbox
                        checked: enabled && !globalThemeCheckbox.enabled
                        text: i18n("Desktop and window layout")
                        onCheckedChanged: {
                            if (checked) {
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.DesktopLayout
                                //FIXME: We should really consider the future of these options (make them checkboxes, or remove them):
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.DesktopSwitcher
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.WindowPlacement
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.ShellPackage
                            } else {
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.DesktopLayout
                                //FIXME: same as above
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.DesktopSwitcher
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.WindowPlacement
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.ShellPackage
                            }
                            setDesktopLayoutCheckboxes(checked) //Set the checkboxes on the More Options page for layout to match this new state
                        }
                        enabled: view.model.data(view.model.index(view.currentIndex, 0), Private.KCMLookandFeel.HasDesktopLayoutRole) ||
                            view.model.data(view.model.index(view.currentIndex, 0), Private.KCMLookandFeel.HasLayoutSettingsRole)
                        //enabled is needed because lblsub can make it invisible
                        visible: enabled && !resetCheckboxLblSub.visible
                    }
                    QtControls.Label { //These labels sub in for the checkboxes when they're the only visible checkbox in this page
                        id: resetCheckboxLblSub
                        visible: resetCheckbox.enabled && !globalThemeCheckbox.enabled
                        Layout.fillWidth: true
                        text: i18nc("List item", "• Desktop and window layout")
                        wrapMode: Text.WordWrap
                    }
                    QtControls.Label {
                        Layout.fillWidth: true
                        text: i18n("Applying a Desktop layout replaces your current configuration of desktops, panels, and widgets")
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        font: Kirigami.Theme.smallFont
                        visible: resetCheckbox.visible || resetCheckboxLblSub.visible
                        color: Kirigami.Theme.neutralTextColor
                    }
                    QtControls.Label { //This label shouldn't ever appear, but it's good to let the user know
                        //why the dialog has no options in the rare scenario they provide an
                        //an empty Global Theme
                        visible: !resetCheckbox.visible && !globalThemeCheckbox.visible && !resetCheckboxLblSub.visible && !globalThemeCheckboxLblSub.visible
                        Layout.fillWidth: true
                        text: i18n("This Global Theme does not provide any applicable settings. Please contact the maintainer of this Global Theme as it might be broken.")
                        wrapMode: Text.WordWrap
                    }
                }
            }
            ColumnLayout {
                id: subscreen
                Kirigami.FormLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing

                    QtControls.CheckBox {
                        Kirigami.FormData.label: i18n("Layout settings:")
                        id: resetCheckboxSub
                        checked: enabled && !globalThemeCheckbox.enabled
                        text: i18n("Desktop layout")
                        onCheckedChanged: {
                            if (checked) {
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.DesktopLayout
                                //FIXME: We should really consider the future of these options (make them checkboxes, or remove them):
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.DesktopSwitcher
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.WindowPlacement
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.ShellPackage
                            } else {
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.DesktopLayout
                                //FIXME: same as above
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.DesktopSwitcher
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.WindowPlacement
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.ShellPackage
                            }
                            setDesktopLayoutCheckboxes(checked)
                        }
                        enabled: view.model.data(view.model.index(view.currentIndex, 0), Private.KCMLookandFeel.HasDesktopLayoutRole)
                        visible: enabled
                    }
                    QtControls.Label {
                        Layout.fillWidth: true
                        text: i18n("Applying a Desktop layout replaces your current configuration of desktops, panels, and widgets")
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        font: Kirigami.Theme.smallFont
                        visible: resetCheckboxSub.visible
                        color: Kirigami.Theme.neutralTextColor
                    }
                    QtControls.CheckBox {
                        id: titlebarLayoutCheckbox
                        checked: enabled
                        text: i18n("Titlebar buttons layout")
                        onCheckedChanged: {
                            if (checked) {
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.TitlebarLayout
                            } else {
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.TitlebarLayout
                            }
                        }
                        enabled: view.model.data(view.model.index(view.currentIndex, 0), Private.KCMLookandFeel.HasTitlebarLayoutRole)
                        visible: enabled
                    }
                    QtControls.CheckBox {
                        Kirigami.FormData.label: i18n("Appearance settings:")
                        id: colorsCheckbox
                        checked: enabled
                        text: i18n("Colors")
                        onCheckedChanged: {
                            if (checked) {
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.Colors
                            } else {
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.Colors
                            }
                        }
                        enabled: view.model.data(view.model.index(view.currentIndex, 0), Private.KCMLookandFeel.HasColorsRole)
                        visible: enabled
                    }
                    QtControls.CheckBox {
                        id: widgetStyleCheckbox
                        checked: enabled
                        text: i18n("Application Style")
                        onCheckedChanged: {
                            if (checked) {
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.WidgetStyle
                            } else {
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.WidgetStyle
                            }
                        }
                        enabled: view.model.data(view.model.index(view.currentIndex, 0), Private.KCMLookandFeel.HasWidgetStyleRole)
                        visible: enabled
                    }
                    QtControls.CheckBox {
                        id: windowDecorationCheckbox
                        checked: enabled
                        text: i18n("Window Decorations")
                        onCheckedChanged: {
                            if (checked) {
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.WindowDecoration
                            } else {
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.WindowDecoration
                            }
                        }
                        enabled: view.model.data(view.model.index(view.currentIndex, 0), Private.KCMLookandFeel.HasWindowDecorationRole)
                        visible: enabled
                    }
                    QtControls.CheckBox {
                        id: iconsCheckbox
                        checked: enabled
                        text: i18n("Icons")
                        onCheckedChanged: {
                            if (checked) {
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.Icons
                            } else {
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.Icons
                            }
                        }
                        enabled: view.model.data(view.model.index(view.currentIndex, 0), Private.KCMLookandFeel.HasIconsRole)
                        visible: enabled
                    }
                    QtControls.CheckBox {
                        id: plasmaThemeCheckbox
                        checked: enabled
                        text: i18n("Plasma Style")
                        onCheckedChanged: {
                            if (checked) {
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.PlasmaTheme
                            } else {
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.PlasmaTheme
                            }
                        }
                        enabled: view.model.data(view.model.index(view.currentIndex, 0), Private.KCMLookandFeel.HasPlasmaThemeRole)
                        visible: enabled
                    }
                    QtControls.CheckBox {
                        id: cursorsCheckbox
                        checked: enabled
                        text: i18n("Cursors")
                        onCheckedChanged: {
                            if (checked) {
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.Cursors
                            } else {
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.Cursors
                            }
                        }
                        enabled: view.model.data(view.model.index(view.currentIndex, 0), Private.KCMLookandFeel.HasCursorsRole)
                        visible: enabled
                    }
                    QtControls.CheckBox {
                        id: windowSwitcherCheckbox
                        checked: enabled
                        text: i18n("Task Switcher")
                        onCheckedChanged: {
                            if (checked) {
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.WindowSwitcher
                            } else {
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.WindowSwitcher
                            }
                        }
                        enabled: view.model.data(view.model.index(view.currentIndex, 0), Private.KCMLookandFeel.HasWindowSwitcherRole)
                        visible: enabled
                    }
                    QtControls.CheckBox {
                        id: splashScreenCheckbox
                        checked: enabled
                        text: i18n("Splash Screen")
                        onCheckedChanged: {
                            if (checked) {
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.SplashScreen
                            } else {
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.SplashScreen
                            }
                        }
                        enabled: view.model.data(view.model.index(view.currentIndex, 0), Private.KCMLookandFeel.HasSplashRole)
                        visible: enabled
                    }
                    QtControls.CheckBox {
                        id: lockScreenCheckbox
                        checked: enabled
                        text: i18n("Lock Screen")
                        onCheckedChanged: {
                            if (checked) {
                                globalThemeConfirmSheet.selectedOptions |= Private.LookandFeelManager.LockScreen
                            } else {
                                globalThemeConfirmSheet.selectedOptions &=  ~ Private.LookandFeelManager.LockScreen
                            }
                        }
                        enabled: view.model.data(view.model.index(view.currentIndex, 0), Private.KCMLookandFeel.HasLockScreenRole)
                        visible: enabled
                    }
                }
            }
        }
        footer: ColumnLayout {
            RowLayout {
                QtControls.Button {
                    id: moreOptionsButton
                    text: i18n("Choose what to apply…")
                    icon.name: "settings-configure"
                    enabled: globalThemeCheckbox.enabled
                    onClicked: {
                        stackSwitcher.currentIndex = 1
                        lessOptionsButton.visible = true
                        moreOptionsButton.visible = false
                        resetCheckboxes() //Force a refresh to reset button states
                    }
                }
                QtControls.Button {
                    id: lessOptionsButton
                    visible: false
                    text: i18n("Show fewer options…")
                    icon.name: "go-previous"
                    onClicked: {
                        stackSwitcher.currentIndex = 0
                        lessOptionsButton.visible = false
                        moreOptionsButton.visible = true
                        resetCheckboxes() //Force a refresh to reset button states
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                }
                QtControls.Button {
                    id: proceedButton
                    text: i18n("Proceed")
                    icon.name: "dialog-ok-apply"
                    onClicked: {
                        kcm.toApply = globalThemeConfirmSheet.selectedOptions
                        kcm.save()
                        globalThemeConfirmSheet.close()
                        view.forceActiveFocus()
                    }
                    enabled: resetCheckbox.checked || globalThemeCheckbox.checked
                }
                QtControls.Button {
                    text: i18n("Cancel")
                    icon.name: "dialog-cancel"
                    onClicked: {
                        globalThemeConfirmSheet.close()
                        view.forceActiveFocus()
                    }
                }
            }
        }
    }

    footer: Kirigami.ActionToolBar {
        flat: false
        alignment: Qt.AlignRight
        actions: [
            NewStuff.Action {
                configFile: "lookandfeel.knsrc"
                text: i18n("Get New Global Themes…")
                onEntryEvent: function (entry, event) {
                    if (event == 1) { // StatusChangedEvent
                        kcm.knsEntryChanged(entry)
                    } else if (event == 2) { // AdoptedEvent
                        kcm.reloadConfig()
                    }
                }
            }
        ]
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
