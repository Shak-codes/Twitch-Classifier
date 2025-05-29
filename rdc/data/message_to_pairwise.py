import pandas as pd
import itertools
import csv
import os


def write_pairwise(infile, combinations, chats, concat_length, shuffle):
    output = f"pairwise/{'filtered' if 'filtered' in infile else 'regular'}/pairwise{concat_length}{'_shuffled' if shuffle else ''}"
    df = pd.read_csv(infile)
    df = df.sample(frac=1, random_state=1995).reset_index(drop=True)

    for chat in chats:
        pairwise = {pair: 0 for pair in combinations}
        chars = 0
        string = ""
        for message in df[df['channel'] == chat].message:
            message = str(message).lower()
            prev = None
            for char in message:
                string += char
                if char == " " and chars >= concat_length:
                    string.replace("  ", " ")
                    string += "."
                    pairwise['message'] = string
                    pairwise['result'] = chat
                    exists = os.path.exists(output)
                    with open(output, mode='a', newline='') as outfile:
                        writer = csv.DictWriter(
                            outfile, fieldnames=pairwise.keys())
                        if not exists:
                            writer.writeheader()
                        writer.writerow(pairwise)
                    chars = 0
                    pairwise = {pair: 0 for pair in combinations}
                    string = ""
                if not char.isalnum():
                    prev = None
                    continue
                if prev:
                    pairwise[f"{prev}{char}"] += 1
                chars += 1
                prev = char
            string += ". "


def get_extremes(files, combinations, chats):
    for input, _ in files:
        df = pd.read_csv(input)
        for chat in chats:
            pairs = 0
            pairwise = {pair: 0 for pair in combinations}
            chars = 0
            for message in df[df['channel'] == chat].message:
                message = str(message).lower()
                prev = None
                for char in message:
                    if not char.isalnum():
                        prev = None
                        continue
                    if prev:
                        pairwise[f"{prev}{char}"] += 1
                        pairs += 1
                    chars += 1
                    prev = char

            filtered_dict = {k: v / pairs for k,
                             v in pairwise.items() if v > 100}
            top_5 = dict(
                sorted(filtered_dict.items(), key=lambda item: item[1], reverse=True)[:5])
            bot_5 = dict(
                sorted(filtered_dict.items(), key=lambda item: item[1], reverse=True)[-5:])

            top_5_str = ', '.join([f"{k}: {v:.5f}" for k, v in top_5.items()])
            bot_5_str = ', '.join([f"{k}: {v:.5f}" for k, v in bot_5.items()])
            print(
                f"{chat} | Char count: {chars} | Top 5: {{{top_5_str}}} | Bottom 5: {{{bot_5_str}}}")
        print()


def main():
    infiles = ["messages.csv", "messages_filtered.csv"]
    concat_lengths = [500, 1000, 1500]
    shuffled = [True, False]

    chats = ['Mark', 'Dylan', 'Desmond', 'Leland', 'Ben']

    letters = 'abcdefghijklmnopqrstuvwxyz'
    combinations = [''.join(pair)
                    for pair in itertools.product(letters, repeat=2)]

    for file in infiles:
        for length in concat_lengths:
            for shuffle in shuffled:
                write_pairwise(file, combinations, chats, length, shuffle)
    # get_extremes(files, combinations, chats)


if __name__ == "__main__":
    main()
