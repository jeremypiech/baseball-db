import datetime


def date_range(start_date: datetime.date, end_date: datetime.date, days_step: int = 1):
    date = start_date
    while date <= end_date:
        yield date

        date += datetime.timedelta(days=days_step)
