/*
    SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2014 Vishesh Handa <me@vhanda.in>
    SPDX-FileCopyrightText: 2019 Cyril Rossi <cyril.rossi@enioka.com>
    SPDX-FileCopyrightText: 2021 Benjamin Port <benjamin.port@enioka.com>
    SPDX-FileCopyrightText: 2022 Dominic Hayes <ferenosdev@outlook.com>

    SPDX-License-Identifier: LGPL-2.0-only
*/

#ifndef TOOLSHARED_H
#define TOOLSHARED_H

#include <KConfig>
#include <KConfigGroup>
#include <KPackage/Package>
#include <KService>
#include <QDir>
#include <QObject>
#include "lookandfeelmanager.h"

class ToolShared : public QObject
{
    Q_OBJECT
public:
    int listPackages();
    int applyPackage(const QString &theme, const LookAndFeelManager::AppearanceToApply &appearanceItems, const LookAndFeelManager::LayoutToApply &layoutItems);
};


#endif // TOOLSHARED_H
