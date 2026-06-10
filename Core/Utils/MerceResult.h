#pragma once

#include <QString>
#include <QStringList>
#include <utility>

class MerceResult
{
public:
    static MerceResult success()
    {
        return MerceResult(true, {});
    }

    static MerceResult failure(QString error)
    {
        return MerceResult(false, { std::move(error) });
    }

    static MerceResult failure(QStringList errors)
    {
        return MerceResult(false, std::move(errors));
    }

    bool ok() const { return m_ok; }
    QStringList errors() const { return m_errors; }

private:
    MerceResult(bool ok, QStringList errors)
        : m_ok(ok),
          m_errors(std::move(errors))
    {
    }

    bool m_ok = false;
    QStringList m_errors;
};
