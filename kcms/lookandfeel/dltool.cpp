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

#include "lookandfeelsettings.h"
#include "toolshared.h"

int main(int argc, char **argv)
{
    QApplication app(argc, argv);

    const char version[] = "1.0";
    const static auto m_shared = new ToolShared();

    // About data
    KAboutData aboutData("plasma-apply-desktoplayout",
                         i18n("Desktop Layout Tool"),
                         version,
                         i18n("Command line tool to apply global theme packages for changing the desktop layout."),
                         KAboutLicense::GPL,
                         i18n("Copyright 2022, Dominic Hayes"));
    aboutData.addAuthor(i18n("Dominic Hayes"), i18n("Maintainer"), QStringLiteral("ferenosdev@outlook.com"));
    aboutData.setDesktopFileName("org.kde.plasma-apply-desktoplayout");
    KAboutData::setApplicationData(aboutData);

    const static auto _l = QStringLiteral("list");
    const static auto _a = QStringLiteral("apply");

    QCommandLineOption _list = QCommandLineOption(QStringList() << QStringLiteral("l") << _l, i18n("List available global theme packages"));
    QCommandLineOption _apply =
        QCommandLineOption(QStringList() << QStringLiteral("a") << _a,
                           i18n("Apply a global theme package's desktop layout. This can be the name of a package, or a full path to an installed package, at which "
                                "point this tool will ensure it is a global theme package and then attempt to apply its desktop layout"),
                           i18n("packagename"));

    QCommandLineParser parser;
    parser.addOption(_list);
    parser.addOption(_apply);
    aboutData.setupCommandLine(&parser);

    parser.process(app);
    aboutData.processCommandLine(&parser);
    int returnno = 0;

    if (!parser.isSet(_list) && !parser.isSet(_apply)) {
        parser.showHelp();
    }

    if (parser.isSet(_list)) {
        returnno = m_shared->listPackages();

    } else if (parser.isSet(_apply)) {
        returnno = m_shared->applyPackage(parser.value(_apply), {}, LookAndFeelManager::LayoutToApply(LookAndFeelManager::LayoutSettings));
    }

    return returnno;
}
