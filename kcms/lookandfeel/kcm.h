/*
    SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2014 Vishesh Handa <me@vhanda.in>
    SPDX-FileCopyrightText: 2019 Cyril Rossi <cyril.rossi@enioka.com>
    SPDX-FileCopyrightText: 2021 Benjamin Port <benjamin.port@enioka.com>

    SPDX-License-Identifier: LGPL-2.0-only
*/

#pragma once

#include <KConfig>
#include <KConfigGroup>
#include <KNSCore/EntryWrapper>
#include <KSharedConfig>

#include <QDir>
#include <QStandardItemModel>

#include <KPackage/Package>
#include <KQuickAddons/ManagedConfigModule>

#include "lookandfeelsettings.h"

class QQuickItem;
class LookAndFeelData;

class KCMLookandFeel : public KQuickAddons::ManagedConfigModule
{
    Q_OBJECT
    Q_PROPERTY(LookAndFeelSettings *lookAndFeelSettings READ lookAndFeelSettings CONSTANT)
    Q_PROPERTY(QStandardItemModel *lookAndFeelModel READ lookAndFeelModel CONSTANT)
    Q_PROPERTY(bool resetDefaultLayout READ resetDefaultLayout WRITE setResetDefaultLayout NOTIFY resetDefaultLayoutChanged)
    
    Q_PROPERTY(bool applyGlobalTheme READ applyGlobalTheme WRITE setApplyGlobalTheme NOTIFY applyGlobalThemeChanged)
    Q_PROPERTY(bool applyColors READ applyColors WRITE setApplyColors NOTIFY applyColorsChanged)
    Q_PROPERTY(bool applyWidgetStyle READ applyWidgetStyle WRITE setApplyWidgetStyle NOTIFY applyWidgetStyleChanged)
    Q_PROPERTY(bool applyIcons READ applyIcons WRITE setApplyIcons NOTIFY applyIconsChanged)
    Q_PROPERTY(bool applyPlasmaTheme READ applyPlasmaTheme WRITE setApplyPlasmaTheme NOTIFY applyPlasmaThemeChanged)
    Q_PROPERTY(bool applyCursors READ applyCursors WRITE setApplyCursors NOTIFY applyCursorsChanged)
    Q_PROPERTY(bool applySplashScreen READ applySplashScreen WRITE setApplySplashScreen NOTIFY applySplashScreenChanged)
    Q_PROPERTY(bool applyLockScreen READ applyLockScreen WRITE setApplyLockScreen NOTIFY applyLockScreenChanged)
    Q_PROPERTY(bool applyWindowDecoration READ applyWindowDecoration WRITE setApplyWindowDecoration NOTIFY applyWindowDecorationChanged)

    Q_PROPERTY(bool resetDefaultLayoutAvailable READ resetDefaultLayoutAvailable WRITE setResetDefaultLayoutAvailable NOTIFY resetDefaultLayoutAvailableChanged)
    Q_PROPERTY(bool applyGlobalThemeAvailable READ applyGlobalThemeAvailable WRITE setApplyGlobalThemeAvailable NOTIFY applyGlobalThemeAvailableChanged)
    Q_PROPERTY(bool applyColorsAvailable READ applyColorsAvailable WRITE setApplyColorsAvailable NOTIFY applyColorsAvailableChanged)
    Q_PROPERTY(bool applyWidgetStyleAvailable READ applyWidgetStyleAvailable WRITE setApplyWidgetStyleAvailable NOTIFY applyWidgetStyleAvailableChanged)
    Q_PROPERTY(bool applyIconsAvailable READ applyIconsAvailable WRITE setApplyIconsAvailable NOTIFY applyIconsAvailableChanged)
    Q_PROPERTY(bool applyPlasmaThemeAvailable READ applyPlasmaThemeAvailable WRITE setApplyPlasmaThemeAvailable NOTIFY applyPlasmaThemeAvailableChanged)
    Q_PROPERTY(bool applyCursorsAvailable READ applyCursorsAvailable WRITE setApplyCursorsAvailable NOTIFY applyCursorsAvailableChanged)
    Q_PROPERTY(bool applySplashScreenAvailable READ applySplashScreenAvailable WRITE setApplySplashScreenAvailable NOTIFY applySplashScreenAvailableChanged)
    Q_PROPERTY(bool applyLockScreenAvailable READ applyLockScreenAvailable WRITE setApplyLockScreenAvailable NOTIFY applyLockScreenAvailableChanged)
    Q_PROPERTY(bool applyWindowDecorationAvailable READ applyWindowDecorationAvailable WRITE setApplyWindowDecorationAvailable NOTIFY applyWindowDecorationAvailableChanged)

public:
    enum Roles {
        PluginNameRole = Qt::UserRole + 1,
        ScreenshotRole,
        FullScreenPreviewRole,
        DescriptionRole,
        HasSplashRole,
        HasLockScreenRole,
        HasRunCommandRole,
        HasLogoutRole,
        HasColorsRole,
        HasWidgetStyleRole,
        HasIconsRole,
        HasPlasmaThemeRole,
        HasCursorsRole,
        HasWindowSwitcherRole,
        HasDesktopSwitcherRole,
        HasWindowDecorationRole,
        HasDesktopLayoutRole,
        HasGlobalThemeRole,
    };

    KCMLookandFeel(QObject *parent, const QVariantList &args);
    ~KCMLookandFeel() override;

    LookAndFeelSettings *lookAndFeelSettings() const;
    QStandardItemModel *lookAndFeelModel() const;

    Q_INVOKABLE int pluginIndex(const QString &pluginName) const;
    
    //Extras for Global Theme checkboxes
    bool isGlobalThemeSubChecked();
    void setGlobalThemeSubCheckboxes(bool apply);
    void setApplyColorsAvailable(bool value);
    void setApplyWidgetStyleAvailable(bool value);
    void setApplyIconsAvailable(bool value);
    void setApplyPlasmaThemeAvailable(bool value);
    void setApplyCursorsAvailable(bool value);
    void setApplySplashScreenAvailable(bool value);
    void setApplyLockScreenAvailable(bool value);
    void setApplyWindowDecorationAvailable(bool value);
    void setApplyGlobalThemeAvailable(bool value);
    void setResetDefaultLayoutAvailable(bool value);

    bool resetDefaultLayout() const;
    void setResetDefaultLayout(bool reset);
    void setApplyGlobalTheme(bool apply);
    bool applyGlobalTheme() const;
    bool applyColors() const;
    void setApplyColors(bool apply);
    bool applyWidgetStyle() const;
    void setApplyWidgetStyle(bool apply);
    bool applyIcons() const;
    void setApplyIcons(bool apply);
    bool applyPlasmaTheme() const;
    void setApplyPlasmaTheme(bool apply);
    bool applyCursors() const;
    void setApplyCursors(bool apply);
    bool applySplashScreen() const;
    void setApplySplashScreen(bool apply);
    bool applyLockScreen() const;
    void setApplyLockScreen(bool apply);
    bool applyWindowDecoration() const;
    void setApplyWindowDecoration(bool apply);

    bool resetDefaultLayoutAvailable() const;
    bool applyGlobalThemeAvailable() const;
    bool applyColorsAvailable() const;
    bool applyWidgetStyleAvailable() const;
    bool applyIconsAvailable() const;
    bool applyPlasmaThemeAvailable() const;
    bool applyCursorsAvailable() const;
    bool applySplashScreenAvailable() const;
    bool applyLockScreenAvailable() const;
    bool applyWindowDecorationAvailable() const;

    // Setters of the various theme pieces
    void setWidgetStyle(const QString &style);
    void setColors(const QString &scheme, const QString &colorFile);
    void setIcons(const QString &theme);
    void setPlasmaTheme(const QString &theme);
    void setCursorTheme(const QString theme);
    void setSplashScreen(const QString &theme);
    void setLockScreen(const QString &theme);
    void setWindowSwitcher(const QString &theme);
    void setDesktopSwitcher(const QString &theme);
    void setWindowDecoration(const QString &library, const QString &theme);
    void setWindowPlacement(const QString &value);
    void setShellPackage(const QString &name);

    Q_INVOKABLE void knsEntryChanged(KNSCore::EntryWrapper *wrapper);
    Q_INVOKABLE void reloadConfig()
    {
        ManagedConfigModule::load();
    }

    void addKPackageToModel(const KPackage::Package &pkg);

    bool isSaveNeeded() const override;

public Q_SLOTS:
    void load() override;
    void save() override;
    void defaults() override;
    void onClickedCheckboxRefresh();

Q_SIGNALS:
    void showConfirmation();

    void resetDefaultLayoutChanged();
    void applyGlobalThemeChanged();
    void applyColorsChanged();
    void applyWidgetStyleChanged();
    void applyIconsChanged();
    void applyPlasmaThemeChanged();
    void applyCursorsChanged();
    void applySplashScreenChanged();
    void applyLockScreenChanged();
    void applyWindowDecorationChanged();

    void resetDefaultLayoutAvailableChanged();
    void applyGlobalThemeAvailableChanged();
    void applyColorsAvailableChanged();
    void applyWidgetStyleAvailableChanged();
    void applyIconsAvailableChanged();
    void applyPlasmaThemeAvailableChanged();
    void applyCursorsAvailableChanged();
    void applySplashScreenAvailableChanged();
    void applyLockScreenAvailableChanged();
    void applyWindowDecorationAvailableChanged();

private:
    // List only packages which provide at least one of the components
    QList<KPackage::Package> availablePackages(const QStringList &components);
    void loadModel();
    QDir cursorThemeDir(const QString &theme, const int depth);
    const QStringList cursorSearchPaths();

    void revertKeyIfNeeded(KConfigGroup &group, KConfigGroup &home, KConfigGroup &defaults);

    void writeNewDefaults(const QString &filename,
                          const QString &group,
                          const QString &key,
                          const QString &value,
                          KConfig::WriteConfigFlags writeFlags = KConfig::Normal);
    void writeNewDefaults(KConfig &config,
                          KConfig &configDefault,
                          const QString &group,
                          const QString &key,
                          const QString &value,
                          KConfig::WriteConfigFlags writeFlags = KConfig::Normal);
    void
    writeNewDefaults(KConfigGroup &cg, KConfigGroup &cgd, const QString &key, const QString &value, KConfig::WriteConfigFlags writeFlags = KConfig::Normal);

    static KConfig configDefaults(const QString &filename);

    LookAndFeelData *m_data;
    QStandardItemModel *m_model;
    KPackage::Package m_package;
    QStringList m_cursorSearchPaths;

    KSharedConfig::Ptr m_config;
    KConfigGroup m_configGroup;

    bool m_applyColors : 1 = true;
    bool m_applyWidgetStyle : 1 = true;
    bool m_applyIcons : 1 = true;
    bool m_applyPlasmaTheme : 1 = true;
    bool m_applyCursors : 1 = true;
    bool m_applyWindowSwitcher : 1 = true;
    bool m_applyDesktopSwitcher : 1 = true;
    bool m_applySplashScreen : 1 = true;
    bool m_applyLockScreen : 1 = true;
    bool m_applyWindowPlacement : 1 = true;
    bool m_applyShellPackage : 1 = true;
    bool m_resetDefaultLayout : 1;
    bool m_applyGlobalTheme : 1;
    bool m_applyWindowDecoration : 1 = true;

    bool m_applyColorsAvailable : 1;
    bool m_applyWidgetStyleAvailable : 1;
    bool m_applyIconsAvailable : 1;
    bool m_applyPlasmaThemeAvailable : 1;
    bool m_applyCursorsAvailable : 1;
    bool m_applyWindowSwitcherAvailable : 1;
    bool m_applyDesktopSwitcherAvailable : 1;
    bool m_applySplashScreenAvailable : 1;
    bool m_applyLockScreenAvailable : 1;
    bool m_resetDefaultLayoutAvailable : 1;
    bool m_applyGlobalThemeAvailable : 1;
    bool m_applyWindowDecorationAvailable : 1;

    bool m_plasmashellChanged = false;
};
