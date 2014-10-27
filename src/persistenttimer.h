/*
 * 2miich - Liiga scores app
 * Copyright (C) 2014 Santtu Lakkala <inz@inz.fi>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef PERSISTENTTIMER_H
#define PERSISTENTTIMER_H

#include <QObject>
#include <QElapsedTimer>

extern "C" {
#include <libiphb.h>
}

class QSocketNotifier;
class QTimer;

class PersistentTimer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int interval READ interval WRITE setInterval NOTIFY intervalChanged)
    Q_PROPERTY(bool repeat READ repeat WRITE setRepeat NOTIFY repeatChanged)
    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged)
    Q_PROPERTY(bool triggeredOnStart READ triggeredOnStart WRITE setTriggeredOnStart NOTIFY triggeredOnStartChanged)
    Q_PROPERTY(int maxError READ maxError WRITE setMaxError NOTIFY maxErrorChanged)
    Q_PROPERTY(bool wakeUp READ wakeUp WRITE setWakeUp NOTIFY wakeUpChanged)
public:
    explicit PersistentTimer(QObject *parent = 0);
    virtual ~PersistentTimer();

    Q_INVOKABLE int interval() const;
    Q_INVOKABLE bool repeat() const;
    Q_INVOKABLE bool running() const;
    Q_INVOKABLE bool triggeredOnStart() const;
    Q_INVOKABLE int maxError() const;
    Q_INVOKABLE bool wakeUp() const;

    Q_INVOKABLE void setInterval(int interval);
    Q_INVOKABLE void setRepeat(bool repeat);
    Q_INVOKABLE void setRunning(bool running);
    Q_INVOKABLE void setTriggeredOnStart(bool triggeredOnStart);
    Q_INVOKABLE void setMaxError(int maxError);
    Q_INVOKABLE void setWakeUp(bool wakeUp);

public slots:
    void start();
    void restart();
    void stop();

signals:
    void triggered();

    void intervalChanged();
    void repeatChanged();
    void runningChanged();
    void triggeredOnStartChanged();
    void maxErrorChanged();
    void wakeUpChanged();

private slots:
    void readyRead(int sock);

private:
    void _start();
    void _stop();

    QSocketNotifier *m_notifier;
    iphb_t m_iphb;
    QTimer *m_fallback;
    QElapsedTimer m_helper;

    int m_interval;
    bool m_repeat;
    bool m_running;
    bool m_triggeredOnStart;
    int m_maxError;
    bool m_wakeUp;
    bool m_dontEmit;
};

#endif // PERSISTENTTIMER_H
