/*
 * Copyright (c) 2020 Benjamin Port <benjamin.port@enioka.com>
 * Copyright (c) 2020 Dominic Hayes <ferenosdev@outlook.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef DESKTOPLAYOUTDATA_H
#define DESKTOPLAYOUTDATA_H

#include <QObject>

#include "kcmoduledata.h"

class DesktopLayoutSettings;

class DesktopLayoutData : public KCModuleData
{
    Q_OBJECT

public:
    explicit DesktopLayoutData(QObject *parent = nullptr, const QVariantList &args = QVariantList());
    DesktopLayoutSettings *settings() const;

private:
    DesktopLayoutSettings *m_settings;
};

#endif
