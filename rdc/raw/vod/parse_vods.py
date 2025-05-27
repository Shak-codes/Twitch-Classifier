import os
import csv
import re

output_file = "../messages.csv"
streamers = ["Ben", "Des", "Dylan", "Leland", "Mark"]
fieldnames = ["username", "message", "chat", "date"]

bot_usernames = {"nightbot", "moobot",
                 "streamelements", "soundalerts", "pretzelrocks"}

seen = set()
if os.path.exists(output_file):
    with open(output_file, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            seen.add((row["username"].strip().lower(),
                      row["message"].strip(), row["chat"], row["date"]))

with open(output_file, "a", newline='', encoding='utf-8') as infile:
    writer = csv.DictWriter(infile, fieldnames=fieldnames)
    if infile.tell() == 0:
        writer.writeheader()

    for streamer in streamers:
        folder_path = os.path.join(os.getcwd(), streamer)
        if not os.path.isdir(folder_path):
            continue

        for filename in os.listdir(folder_path):
            if not filename.endswith(".txt"):
                continue

            date = filename.replace(".txt", "").replace(
                "[", "").replace("]", "")
            file_path = os.path.join(folder_path, filename)

            with open(file_path, encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if ':' not in line:
                        continue

                    parts = line.split(':', 1)
                    username = parts[0].strip()
                    if username in bot_usernames:
                        continue

                    message = parts[1].strip()
                    # keep only letters and spaces
                    message = re.sub(r'[^a-zA-Z\s]', '', message)
                    # collapse multiple spaces
                    message = re.sub(r'\s+', ' ', message).strip()

                    if not message:
                        continue  # skip if message becomes empty after cleaning

                    key = (username, message, streamer, date)
                    if key not in seen:
                        seen.add(key)
                        writer.writerow({
                            "username": username,
                            "message": message,
                            "chat": streamer,
                            "date": date
                        })
