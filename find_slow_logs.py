import argparse
import os
import re
from collections import defaultdict
import gzip


def find_slow_logs(log_lines, min_sql, min_misc):
    endpoint_stats = defaultdict(int)
    database_stats = defaultdict(int)

    def slow_logs():
        # 2024-01-23 23:59:33,894 230139 INFO mnour-master-583991 werkzeug: 41.35.93.158 - - [23/Jan/2024 23:59:33] "POST /longpolling/im_status HTTP/1.0" 200 - 6 0.007 0.012
        # extract "POST /longpolling/im_status HTTP/1.0" and the duration 0.007
        pattern = re.compile(
            r"(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d+) (\d+) (\w+) ([\w\-\d]+) (\w+:) (\d+\.\d+\.\d+\.\d+) .* \"(.*)\" \d+ - (\d+) (\d+\.?\d+) (\d+\.?\d+)"
        )
        for line in log_lines:
            match = pattern.match(line)
            if match:
                timestamp = match.group(1)
                pid = match.group(2)
                prefix = match.group(3)
                database = match.group(4)
                model = match.group(5)
                ip = match.group(6)
                endpoint = match.group(7)
                num_sql = int(match.group(8))
                sql_time = float(match.group(9))
                misc_time = float(match.group(10))

                database_stats[database] += 1
                
                if sql_time > min_sql or misc_time > min_misc:
                    # color the response time red and endpoint in green
                    misc_time_str = f"\033[91m{misc_time}\033[0m" if misc_time > min_misc else misc_time
                    sql_time_str = f"\033[91m{sql_time}\033[0m" if sql_time > min_sql else sql_time
                    yield f"\033[94m{timestamp}\033[0m  {pid} {prefix} {database} {model} {ip} \033[92m{endpoint}\033[0m | {num_sql} | {sql_time_str} | {misc_time_str}"
                    endpoint_stats[endpoint] += 1

    
    stats = {"endpoint": endpoint_stats, "database": database_stats}

    return slow_logs(), stats


def process_files(paths, min_sql, min_misc, disable_statistics):
    all_stats = defaultdict(int)
    for path in paths:
        # handle file if it is gzipped
        if path.endswith(".gz"):
            with gzip.open(path, "r") as f:
                log_lines = (l.decode() for l in f.readlines())
        else:
            with open(path) as f:
                log_lines = f.readlines()
        slow_logs, stats = find_slow_logs(log_lines, min_sql, min_misc)
        for line in slow_logs:
            print(line)

        for title, count in stats[statistics].items():
            all_stats[title] += count

    if disable_statistics:
        return

    print("=====================================")
    print("statistics")
    print("=====================================")

    print(f"{statistics} |\tCount")
    for database, count in sorted(all_stats.items(), key=lambda item: item[1]):
        print(f"{database} |\t{count}")


if __name__ == "__main__":
    # add multiline description
    parser = argparse.ArgumentParser(
        description="""
parses odoo.log files and returns requests that took more than a certain amount of time
example usage:
- python find_slow_logs.py -p odoo.log* -d 5
- python find_slow_logs.py -p odoo.log* -s 30 -m 10 | less


output format:
request body | <number of sql queries> | <sql time> | <misc time>
sql time: time spent in sql queries
misc time: time spent in other operations (e.g. python functions, rendering templates, io, etc.)

statistics:
Endpoint | Count
* a line is counted if it has a sql time or misc time that is greater than the supplied duration
""",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    # required arguments
    parser.add_argument("--paths", "-p", nargs="+", help="path(s) to log file(s)", required=True)
    # optional_arguments
    parser.add_argument("--min-duration", "-d", help="min duration of the slow logs in seconds", default=5)
    parser.add_argument(
        "--min-sql-duration",
        help="min duration for sql in seconds. Defaults to min_duration",
        default=None,
    )
    parser.add_argument(
        "--min-misc-duration",
        help="min duration for things other than sql in seconds. Defaults to min_duration",
        default=None,
    )
    parser.add_argument(
        "--statistics",
        "-s",
        help="Choose content of statistics",
        default="endpoint"
    )
    parser.add_argument(
        "--disable-statistics",
        help="disable printing statistics",
        action="store_true",
    )
    args = parser.parse_args()
    paths = sorted(args.paths)
    min_duration = args.min_duration  # in seconds
    min_sql = min_duration if args.min_sql_duration is None else args.min_sql_duration
    min_misc = min_duration if args.min_misc_duration is None else args.min_misc_duration
    disable_statistics = args.disable_statistics
    statistics = args.statistics

    possible_stats = ["endpoint", "database"]
    try:
        possible_stats.index(statistics)
    except:
        print(f"The possible value are: {possible_stats}")
        exit(1)

    try:
        min_duration = float(min_duration)
        min_sql = float(min_sql)
        min_misc = float(min_misc)
    except ValueError:
        print("one or more duration(s) is not a valid number")
        exit(1)

    for path in paths:
        if not os.path.isfile(path):
            print(f"{path} is not a valid file")
            exit(1)

    try:
        process_files(paths, min_sql=min_sql, min_misc=min_misc, disable_statistics=disable_statistics)
    except (BrokenPipeError, KeyboardInterrupt):
        exit(0)
