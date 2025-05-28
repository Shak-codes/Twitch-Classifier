import csv
import json

with open('map.json', 'r') as json_file:
    channel_map_by_date = json.load(json_file)

valid_channels = [
    "Ben", "Desmond", "Leland", "Mark", "Dylan"
]

mapping_channels = [
    "rdcgaming", "rdcgamingtwo", "rdcgamingthree", "rdcgamingfour", "rdcgamingfive"
]

input_csv = '../../raw/messages.csv'
output_csv = 'messages.csv'
filtered_output_csv = 'messages_filtered.csv'

valid_channels_lower = [name.lower() for name in valid_channels]

with open(input_csv, 'r', newline='', encoding='utf-8') as infile, \
        open(output_csv, 'w', newline='', encoding='utf-8') as outfile, \
        open(filtered_output_csv, 'w', newline='', encoding='utf-8') as filtered_outfile:

    reader = csv.reader(infile)
    writer = csv.writer(outfile)
    filtered_writer = csv.writer(filtered_outfile)

    seen = set()

    headers = ['username', 'message', 'channel', 'date']
    writer.writerow(headers)
    filtered_writer.writerow(headers)

    for row in reader:
        if len(row) != 4:
            continue

        username, message, channel, date = row
        message = message.strip()
        message_lower = message.lower()

        def contains_name(msg):
            return any(name in msg for name in valid_channels_lower)

        write_row = None

        if channel in valid_channels:
            write_row = [username, message, channel, date]
        elif channel in mapping_channels:
            name_map = channel_map_by_date.get(date, {})
            mapped_channel = name_map.get(channel)
            if mapped_channel:
                write_row = [username, message, mapped_channel, date]

        if write_row and message not in seen:
            writer.writerow(write_row)
            seen.add(message)
            if not contains_name(message_lower):
                filtered_writer.writerow(write_row)
