/*
    SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2014 Vishesh Handa <me@vhanda.in>
    SPDX-FileCopyrightText: 2019 Cyril Rossi <cyril.rossi@enioka.com>
    SPDX-FileCopyrightText: 2021 Benjamin Port <benjamin.port@enioka.com>
    SPDX-FileCopyrightText: 2022 Dominic Hayes <ferenosdev@outlook.com>

    SPDX-License-Identifier: LGPL-2.0-only
*/

#ifndef LOOKANDFEELMANAGER_H
#define LOOKANDFEELMANAGER_H

#include <KConfig>
#include <KConfigGroup>
#include <KPackage/Package>
#include <KService>
#include <QDir>
#include <QObject>

class LookAndFeelData;
class LookAndFeelSettings;

class LookAndFeelManager : public QObject
{
    Q_OBJECT
public:
    enum class Mode {
        Apply, // Apply the look and feel theme, i.e. change the active settings and set them up as new defaults. This is the default.
        Defaults // Only set up the options of the look and feel theme as new defaults without changing any active setting
    };

    enum ItemToApply {
        DesktopLayout = 1 << 0,
        Colors = 1 << 1,
        WidgetStyle = 1 << 2,
        WindowDecoration = 1 << 3,
        Icons = 1 << 4,
        PlasmaTheme = 1 << 5,
        Cursors = 1 << 6,
        DesktopSwitcher = 1 << 7,
        WindowSwitcher = 1 << 8,
        SplashScreen = 1 << 9,
        LockScreen = 1 << 10,
        WindowPlacement = 1 << 11, //FIXME: Do we still want these?
        ShellPackage = 1 << 12,
    };
    Q_DECLARE_FLAGS(ItemsToApply, ItemToApply)
    Q_FLAG(ItemsToApply)

    LookAndFeelManager(QObject *parent = nullptr);

    void setMode(Mode mode);
    /**
     * Apply the theme represented by package, with oldPackage being the currently active package.
     * Effects depend upon the Mode of this object. If Mode is Defaults, oldPackage is ignored.
     */
    void save(const KPackage::Package &package, const KPackage::Package &oldPackage);
    ItemsToApply toApply() const;
    void setToApply(ItemsToApply items);

    QString colorSchemeFile(const QString &schemeName) const;

    // Setters of the various theme pieces
    void setWidgetStyle(const QString &style);
    void setColors(const QString &scheme, const QString &colorFile);
    void setIcons(const QString &theme);
    void setPlasmaTheme(const QString &theme);
    void setCursorTheme(const QString theme);
    void setSplashScreen(const QString &theme);
    void setLatteLayout(const QString &filepath, const QString &name);
    void setLockScreen(const QString &theme);
    void setWindowSwitcher(const QString &theme);
    void setDesktopSwitcher(const QString &theme);
    void setWindowDecoration(const QString &library, const QString &theme);
    void setWindowPlacement(const QString &value);
    void setShellPackage(const QString &name);

    LookAndFeelSettings *settings() const;

Q_SIGNALS:
    void message();
    void toApplyChanged();
    void iconsChanged();
    void colorsChanged();
    void styleChanged(const QString &newStyle);
    void cursorsChanged(const QString &newStyle);
    void refreshServices(const QStringList &toStop, const KService::List &toStart);

private:
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

    QStringList m_cursorSearchPaths;
    LookAndFeelData *const m_data;
    Mode m_mode = Mode::Apply;
    bool m_applyLatteLayout : 1 = false;
    ItemsToApply m_toApply;

    bool m_plasmashellChanged = false;
};
Q_DECLARE_OPERATORS_FOR_FLAGS(LookAndFeelManager::ItemsToApply)

#endif // LOOKANDFEELMANAGER_H
