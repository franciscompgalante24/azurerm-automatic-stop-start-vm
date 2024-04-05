import json
from datetime import datetime, timedelta, timezone

def next_sunday():
    today = datetime.now(timezone.utc)
    next_sunday = today + timedelta((6 - today.weekday() + 7) % 7)  # 6 corresponds to Sunday
    return next_sunday.isoformat()  # .isoformat() should include the colon in the time zone offset

if __name__ == "__main__":
    output = {"start_time": next_sunday()}
    print(json.dumps(output))
