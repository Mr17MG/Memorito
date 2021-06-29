#include "qdateconvertor.h"

QDateConvertor::QDateConvertor(QQuickItem *parent)
    : QQuickItem(parent)
{
    // By default, QQuickItem does not draw anything. If you subclass
    // QQuickItem to create a visual item, you will need to uncomment the
    // following line and re-implement updatePaintNode()

    // setFlag(ItemHasContents, true);
    today =QDateTime::currentDateTime();
}

QDateConvertor::~QDateConvertor() {}


int QDateConvertor::div(int a,int b)
{
    return  (a / b);
}

void QDateConvertor::set_months()
{
    Month[1]=QString::fromUtf8("فروردین");
    Month[2]=QString::fromUtf8("اردیبهشت");
    Month[3]=QString::fromUtf8("خرداد");
    Month[4]=QString::fromUtf8("تیر");
    Month[5]=QString::fromUtf8("مرداد");
    Month[6]=QString::fromUtf8("شهریور");
    Month[7]=QString::fromUtf8("مهر");
    Month[8]=QString::fromUtf8("آبان");
    Month[9]=QString::fromUtf8("آذر");
    Month[10]=QString::fromUtf8("دی");
    Month[11]=QString::fromUtf8("بهمن");
    Month[12]=QString::fromUtf8("اسفند");
}
void QDateConvertor::set_days()
{
    Day["Saturday"]=QString::fromUtf8("شنبه");
    Day["Sunday"]=QString::fromUtf8("یکشنبه");
    Day["Monday"]=QString::fromUtf8("دوشنبه");
    Day["Tuesday"]=QString::fromUtf8("سه شنبه");
    Day["Wednesday"]=QString::fromUtf8("چهارشنبه");
    Day["Thursday"]=QString::fromUtf8("پنجشنبه");
    Day["Friday"]=QString::fromUtf8("آدینه");
}

bool QDateConvertor::is_leap(int year)
{
    int mod;
    mod=year%33;
    if (year<=1472 && year >=1343){
        if (mod == 1 || mod == 5 || mod ==9 || mod == 13 || mod == 17||mod==22||mod==26||mod==23)
        {
            return true;
        }
        else{
            return false;
        }

    }
    if (year<=1342 && year>=1244 )
    {
        if (mod == 1 || mod == 5 || mod ==9 || mod == 13 || mod == 17 || mod==21 || mod==26 ||mod==23)
        {
            return true;
        }
        else{
            return false;
        }

    }
    return false;
}

QStringList QDateConvertor::toJalali(QString year, QString month,QString day)
{
    int g_y = year.toInt();
    int g_m = month.toInt();
    int g_d = day.toInt();
    QList<int> g_days_in_month,j_days_in_month  ;
    g_days_in_month << 31 << 28 << 31 << 30 << 31 << 30 << 31 <<31 << 30 << 31<< 30 << 31;
    j_days_in_month <<31 <<31 <<31 << 31 << 31 << 31 << 30 << 30 << 30 << 30 << 30 << 29;
    int  gy = g_y-1600;
    int  gm = g_m-1;
    int  gd = g_d-1;
    int  g_day_no = 365*gy+div(gy+3,4)-div(gy+99,100)+div(gy+399,400);
    for (int i=0; i < gm; ++i){
        g_day_no += g_days_in_month[i];
    }

    if (gm>1 && ((gy%4==0 && gy%100!=0) || (gy%400==0)))
        //leap and after Feb
        g_day_no++;
    g_day_no += gd;
    int j_day_no = g_day_no-79;
    int  j_np = div(j_day_no, 12053); // 12053 = 365*33 + 32/4
    j_day_no = j_day_no % 12053;
    int jy = 979+33*j_np+4*div(j_day_no,1461);// 1461 = 365*4 + 4/4
    j_day_no %= 1461;

    if (j_day_no >= 366) {
        jy += div(j_day_no-1, 365);
        j_day_no = (j_day_no-1)%365;
    }
    int ii=-1;
    for (int i = 0; i < 11 && j_day_no >= j_days_in_month[i]; ++i){
        j_day_no -= j_days_in_month[i];
        ii=i;
    }
    int  jm = ii+2;
    int  jd = j_day_no+1;
    QStringList jalali;
    set_months();
    jalali << QString::number(jy) << QString::number(jm)<< QString::number(jd)<< Month[jm] ;
    return jalali;
}

QStringList QDateConvertor::toMiladi(QString year, QString month,QString day )
{
    //set Date
    int Year;
    int Month;
    int Day;

    Year=year.toInt();//Jalali Year
    Month=month.toInt();//Jalali Month
    Day=day.toInt();//Jalali Day

    QList <int> miladiDate;
    QList <int> farvardin1st;
    //set default value
    miladiDate<<1<<1<<1;
    farvardin1st<<1<<1<<1;

    int miladiYear;
    int marchDayDiff;
    int dayCount;
    QList<int> miladiMonth;
    miladiMonth<<30<<31<<30<<31<<31<<30<<31<<30<<31<<31<<28<<31;
    miladiYear = Year + 621;
    //Detemining the Farvardin the First
    if (QDate::isLeapYear(miladiYear)){
        //this is a Miladi leap year so Shamsi is leap too so the 1st of Farvardin is March 20 (3/20)
        farvardin1st[1] =3; // change default values
        farvardin1st[2]= 20;
        if(miladiYear>1992)
            marchDayDiff = 12;
        else
            marchDayDiff = 11;
    }else{
        //this is not a Miladi leap year so Shamsi is not leap too so the 1st of Farvardin is March 21 (3/21)
        farvardin1st[1] = 3;
        farvardin1st[2] =21;
        marchDayDiff = 11;
    }

    if (QDate::isLeapYear(miladiYear+1)){
        miladiMonth[10] = miladiMonth[10] + 1; //Adding one day to Feb
    }
    //Calculate the day count for input shamsi date from 1st Farvadin
    if (Month >=1 && Month<=6){
        dayCount = ((Month-1) * 31) + Day;
    }else{
        dayCount =(6 * 31) + ((Month - 7) * 30) + Day;
    }

    //Finding the correspond miladi month and day
    int remainDay=0;
    if (dayCount <=marchDayDiff){
        //So we are in 20(for leap year) or 21for none leap year) to 31 march
        miladiDate[2] = dayCount + (31 - marchDayDiff);
        miladiDate[1] = 3;
        miladiDate[0] = miladiYear;
        QStringList mymiladiDate;
        mymiladiDate <<QString::number(miladiDate[0])<<QString::number(miladiDate[1])<<QString::number(miladiDate[2]);
        return mymiladiDate;
    }else{
        remainDay = dayCount - marchDayDiff;
    }

    int i;
    i=0;//starting from April
    while (remainDay>miladiMonth[i]){
        remainDay = remainDay - miladiMonth[i];
        i = i+1;
    }
    miladiDate[2] = remainDay;
    if (i>8){
        // We are in the next Miladi Year
        miladiDate[1] = i - 8;
        miladiDate[0] =  miladiYear + 1;
    }else{
        miladiDate[1] = i + 4;
        miladiDate[0] =  miladiYear;
    }
    QStringList mymiladiDate;
    mymiladiDate <<QString::number(miladiDate[0])<<QString::number(miladiDate[1])<<QString::number(miladiDate[2]);
    return mymiladiDate;
}

QStringList QDateConvertor::Today()
{
    set_days();
    QStringList Date=  this->toJalali( today.toString("yyyy"), today.toString("MM"),today.toString("dd"));
    Date<<Day[today.toString("dddd")];
    return Date;
}
