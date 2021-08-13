TEMPLATE = subdirs

CONFIG += ordered

SUBDIRS = \
          MSecurity \
          MSystemInfo  \
          MTools	\
          QCustomDate	\
          QDateConvertor \
          Memorito
unix{
    TARGET = ../FinalExcutable
}
# where to find the sub projects - give the folders
MSecurity.subdir = ./MSecurity
MSystemInfo.subdir  = ./MSystemInfo
MTools.subdir  = ./MTools
QCustomDate.subdir  = ./QCustomDate
QDateConvertor.subdir  = ./QDateConvertor
Memorito.subdir  = ./Memorito

# what subproject depends on others
Memorito.depends =   MSecurity    MSystemInfo     MTools QCustomDate    QDateConvertor
