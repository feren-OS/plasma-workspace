/*
    SPDX-FileCopyrightText: 2017 Marco MArtin <mart@kde.org>
    SPDX-FileCopyrightText: 2022 Dominic Hayes <ferenosdev@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "kcm.h"

#include <iostream>

#include <QApplication>
#include <QCommandLineParser>
#include <QDebug>

// Frameworks
#include <KAboutData>
#include <KLocalizedString>

#include <KPackage/Package>
#include <KPackage/PackageLoader>

#include "toolshared.h"
#include "lookandfeelsettings.h"

int ToolShared::listPackages()
{
    const QList<KPluginMetaData> pkgs = KPackage::PackageLoader::self()->listPackages("Plasma/LookAndFeel");

    for (const KPluginMetaData &data : pkgs) {
        std::cout << data.pluginId().toStdString() << std::endl;
    }

    return 0;
}

int ToolShared::applyPackage(const QString &theme, const LookAndFeelManager::AppearanceToApply &appearanceItems, const LookAndFeelManager::LayoutToApply &layoutItems) {
    QString requestedTheme{theme};
    QFileInfo info(requestedTheme);
    // Check if the theme name passed validates as the absolute path for a folder
    if (info.isDir()) {
        // absolute paths need to be passed with trailing shash to KPackage
        requestedTheme += QStringLiteral("/");
    }
    KPackage::Package p = KPackage::PackageLoader::self()->loadPackage("Plasma/LookAndFeel");
    p.setPath(requestedTheme);

    // can't use package.isValid as lnf packages always fallback, even when not existing
    if (p.metadata().pluginId() != requestedTheme) {
        if (!p.path().isEmpty() && p.path() == requestedTheme && QFile(p.path()).exists()) {
            std::cout << "Absolute path to theme passed in, set that" << std::endl;
            requestedTheme = p.metadata().pluginId();
        } else {
            std::cout << "Unable to find the theme named " << requestedTheme.toStdString() << std::endl;
            return 1;
        }
    }

    KCMLookandFeel *kcm = new KCMLookandFeel(nullptr, KPluginMetaData(), QVariantList());
    kcm->load();
    kcm->setLayoutToApply(layoutItems);
    kcm->setAppearanceToApply(appearanceItems);
    kcm->lookAndFeelSettings()->setLookAndFeelPackage(requestedTheme);
    // Save manually as we aren't in an event loop
    kcm->lookAndFeelSettings()->save();
    kcm->save();
    delete kcm;

    return 0;
}
