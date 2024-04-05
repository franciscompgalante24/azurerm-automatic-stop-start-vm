import json
from datetime import datetime, timedelta, timezone

def next_saturday():
    today = datetime.now(timezone.utc)
    next_saturday = today + timedelta((5 - today.weekday() + 7) % 7)  # 5 corresponds to Saturday
    return next_saturday.isoformat()  # .isoformat() should include the colon in the time zone offset

if __name__ == "__main__":
    output = {"start_time": next_saturday()}
    print(json.dumps(output))
