/*
 * This file is part of the KDE Baloo Project
 * Copyright (C) 2014  Vishesh Handa <me@vhanda.in>
 * Copyright (C) 2017 David Edmundson <davidedmundson@kde.org>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#include "baloosearchrunner.h"

#include <KLocalizedString>
#include <QAction>
#include <QApplication>
#include <QDBusConnection>
#include <QDir>
#include <QIcon>
#include <QMimeData>
#include <QMimeDatabase>
#include <QTimer>

#include <Baloo/IndexerConfig>
#include <Baloo/Query>

#include <KIO/OpenFileManagerWindowJob>
#include <KIO/OpenUrlJob>
#include <KNotificationJobUiDelegate>
#include <KShell>

#include "krunner1adaptor.h"

static const QString s_openParentDirId = QStringLiteral("openParentDir");

int main(int argc, char **argv)
{
    Baloo::IndexerConfig config;
    if (!config.fileIndexingEnabled()) {
        return -1;
    }
    QCoreApplication::setAttribute(Qt::AA_DisableSessionManager);
    QApplication::setQuitOnLastWindowClosed(false);
    QApplication app(argc, argv); // KRun needs widgets for error message boxes
    SearchRunner r;
    return app.exec();
}

SearchRunner::SearchRunner(QObject *parent)
    : QObject(parent)
{
    new Krunner1Adaptor(this);
    qDBusRegisterMetaType<RemoteMatch>();
    qDBusRegisterMetaType<RemoteMatches>();
    qDBusRegisterMetaType<RemoteAction>();
    qDBusRegisterMetaType<RemoteActions>();
    QDBusConnection::sessionBus().registerObject(QStringLiteral("/runner"), this);
    QDBusConnection::sessionBus().registerService(QStringLiteral("org.kde.runners.baloo"));
}

SearchRunner::~SearchRunner()
{
}

RemoteActions SearchRunner::Actions()
{
    return RemoteActions({RemoteAction{s_openParentDirId, i18n("Open Containing Folder"), QStringLiteral("document-open-folder")}});
}

RemoteMatches SearchRunner::Match(const QString &searchTerm)
{
    // Do not try to show results for queries starting with =
    // this should trigger the calculator, but the AdvancedQueryParser::parse method
    // in baloo interpreted it as an operator, BUG 345134
    if (searchTerm.startsWith(QLatin1Char('='))) {
        return RemoteMatches();
    }

    // Filter out duplicates
    QSet<QUrl> foundUrls;

    RemoteMatches matches;
    matches << matchInternal(searchTerm, QStringLiteral("Audio"), i18n("Audio"), foundUrls);
    matches << matchInternal(searchTerm, QStringLiteral("Image"), i18n("Image"), foundUrls);
    matches << matchInternal(searchTerm, QStringLiteral("Video"), i18n("Video"), foundUrls);
    matches << matchInternal(searchTerm, QStringLiteral("Spreadsheet"), i18n("Spreadsheet"), foundUrls);
    matches << matchInternal(searchTerm, QStringLiteral("Presentation"), i18n("Presentation"), foundUrls);
    matches << matchInternal(searchTerm, QStringLiteral("Folder"), i18n("Folder"), foundUrls);
    matches << matchInternal(searchTerm, QStringLiteral("Document"), i18n("Document"), foundUrls);
    matches << matchInternal(searchTerm, QStringLiteral("Archive"), i18n("Archive"), foundUrls);

    return matches;
}

RemoteMatches SearchRunner::matchInternal(const QString &searchTerm, const QString &type, const QString &category, QSet<QUrl> &foundUrls)
{
    Baloo::Query query;
    query.setSearchString(searchTerm);
    query.setType(type);
    query.setLimit(10);

    Baloo::ResultIterator it = query.exec();

    RemoteMatches matches;

    QMimeDatabase mimeDb;

    // KRunner is absolutely daft and allows plugins to set the global
    // relevance levels. so Baloo should not set the relevance of results too
    // high because then Applications will often appear after if the application
    // runner has not a higher relevance. So stupid.
    // Each runner plugin should not have to know about the others.
    // Anyway, that's why we're starting with .75
    float relevance = .75;
    while (it.next()) {
        RemoteMatch match;
        QString localUrl = it.filePath();
        const QUrl url = QUrl::fromLocalFile(localUrl);

        if (foundUrls.contains(url)) {
            continue;
        }

        foundUrls.insert(url);

        match.id = url.toString();
        match.text = url.fileName();
        match.iconName = mimeDb.mimeTypeForFile(localUrl).iconName();
        match.relevance = relevance;
        match.type = Plasma::QueryMatch::PossibleMatch;
        QVariantMap properties;

        QString folderPath = url.adjusted(QUrl::RemoveFilename | QUrl::StripTrailingSlash).toLocalFile();
        folderPath = KShell::tildeCollapse(folderPath);

        properties[QStringLiteral("urls")] = QStringList({QString::fromLocal8Bit(url.toEncoded())});
        properties[QStringLiteral("subtext")] = folderPath;
        properties[QStringLiteral("category")] = category;

        match.properties = properties;
        relevance -= 0.05;

        matches << match;
    }

    return matches;
}

void SearchRunner::Run(const QString &id, const QString &actionId)
{
    const QUrl url(id);
    if (actionId == s_openParentDirId) {
        KIO::highlightInFileManager({url});
        return;
    }

    auto *job = new KIO::OpenUrlJob(url);
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled));
    job->setRunExecutables(false);
    job->start();
}
