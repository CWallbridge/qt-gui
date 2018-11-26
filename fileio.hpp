#ifndef FILEIO_HPP
#define FILEIO_HPP
#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QStandardPaths>
#include <QDir>
#include <iostream>

class FileIO : public QObject
{
    Q_OBJECT

public slots:
    bool write(const QString& source, const QString& data)
    {


        if (source.isEmpty())
            return false;

        QDir basepath = QDir(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation)).absoluteFilePath(source);
        std::cout<<basepath.absolutePath().toStdString()<<std::endl;
        if (!basepath.exists()) {
            basepath.mkpath(".");
        }

        QFile file(basepath.absolutePath()+"/logs.csv");
        if (!file.open(QFile::WriteOnly | QFile::Append))
            return false;

        QTextStream out(&file);
        out << data << "\n";
        file.close();
        return true;
    }

public:
    FileIO() {}
};

#endif // FILEIO_HPP
