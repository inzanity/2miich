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

#include <QSocketNotifier>
#include <QTimer>
#include "persistenttimer.h"

#include <QtGlobal>
#include <QDebug>

PersistentTimer::PersistentTimer(QObject *parent) :
    QObject(parent),
    m_notifier(NULL),
    m_fallback(NULL),
    m_interval(1000),
    m_repeat(false),
    m_running(false),
    m_triggeredOnStart(false),
    m_maxError(1000),
    m_wakeUp(false),
    m_dontEmit(false)
{
    int fd = -1;
    m_iphb = iphb_open(NULL);

    if (m_iphb) {
        fd = iphb_get_fd(m_iphb);

        if (fd == -1) {
            iphb_close(m_iphb);
            m_iphb = NULL;
        }
    }

    if (m_iphb) {
        m_notifier = new QSocketNotifier(fd, QSocketNotifier::Read, this);

        connect(m_notifier, SIGNAL(activated(int)), SLOT(readyRead(int)));
        m_notifier->setEnabled(true);
    } else {
        m_fallback = new QTimer;
        m_fallback->setInterval(m_interval);

        connect(m_fallback, SIGNAL(timeout()), SIGNAL(triggered()));
    }
}

PersistentTimer::~PersistentTimer()
{
    m_dontEmit = true;
    stop();

    if (m_notifier) {
        m_notifier->setEnabled(false);
        delete m_notifier;
    }

    if (m_iphb)
        iphb_close(m_iphb);
}



void PersistentTimer::start()
{
    if (m_running)
        return;

    if (m_iphb) {
        iphb_wait2(m_iphb,
                   (m_interval - m_maxError) / 1000,
                   (m_interval + m_maxError) / 1000,
                   0, m_wakeUp);
    } else {
        m_fallback->start();
    }

    m_running = true;

    if (m_triggeredOnStart)
        emit triggered();

    if (!m_dontEmit)
        emit runningChanged();
}

void PersistentTimer::restart()
{
    bool wasRunning = m_running;
    m_dontEmit = true;
    stop();
    start();
    m_dontEmit = false;

    if (m_running != wasRunning)
        emit runningChanged();
}

void PersistentTimer::stop()
{
    if (!m_running)
        return;

    if (m_iphb) {
        iphb_I_woke_up(m_iphb);
    } else {
        m_fallback->stop();
    }

    m_running = false;

    if (!m_dontEmit)
        emit runningChanged();
}

int PersistentTimer::interval() const
{
    return m_interval;
}

bool PersistentTimer::repeat() const
{
    return m_repeat;
}

bool PersistentTimer::running() const
{
    return m_running;
}

bool PersistentTimer::triggeredOnStart() const
{
    return m_triggeredOnStart;
}

int PersistentTimer::maxError() const
{
    return m_maxError;
}

bool PersistentTimer::wakeUp() const
{
    return m_wakeUp;
}

void PersistentTimer::setInterval(int interval)
{
    if (m_fallback)
        m_fallback->setInterval(interval);
    m_interval = interval;

    emit intervalChanged();
}

void PersistentTimer::setRepeat(bool repeat)
{
    if (m_fallback)
        m_fallback->setSingleShot(!repeat);
    m_repeat = repeat;

    emit repeatChanged();
}

void PersistentTimer::setRunning(bool running)
{
    if (m_running && !running)
        stop();
    else if (running && !m_running)
        start();
}

void PersistentTimer::setTriggeredOnStart(bool triggeredOnStart)
{
    m_triggeredOnStart = triggeredOnStart;

    emit triggeredOnStartChanged();
}

void PersistentTimer::setMaxError(int maxError)
{
    m_maxError = maxError;

    emit maxErrorChanged();
}

void PersistentTimer::setWakeUp(bool wakeUp)
{
    if (wakeUp == m_wakeUp)
        return;
    m_wakeUp = wakeUp;

    if (m_iphb && m_running)
        restart();

    emit wakeUpChanged();
}

void PersistentTimer::readyRead(int)
{
    bool wasRunning = m_running;

    m_dontEmit = true;
    stop();

    if (m_repeat) {
        bool tmp = m_triggeredOnStart;
        m_triggeredOnStart = false;
        start();
        m_triggeredOnStart = tmp;
    }

    if (m_running != wasRunning)
        emit runningChanged();

    emit triggered();
}
