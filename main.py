import sqlite3
from tqdm import tqdm

sample = "the quick brown fox jumps over the lazy dog"

def main():
    with sqlite3.connect("markov.db") as con:
        cur = con.cursor()
        #Create
        with open("sql/drop.sql", "r") as f:
            cur.executescript(f.read())
        #Create
        with open("sql/create.sql", "r") as f:
            cur.executescript(f.read())
        
        #Insert
        with open("data/eng_dict.txt", "r") as di:
            tl = 0
            for line in di:
                tl+=1
            di.seek(0)
            for line in tqdm(di, total=tl):
                words = line.split(" ")
                #States
                for word in words:
                    cur.execute("""INSERT OR IGNORE INTO states (name) VALUES (?);""", (word,))
                #Transitions
                
                for i in range(len(words)-2):
                    cur.execute("""INSERT
                                        INTO
                                        transitions (from_state1,
                                        from_state2,
                                        to_state,
                                        count)
                                    VALUES ((
                                    SELECT
                                        id
                                    FROM
                                        states
                                    WHERE
                                        name = ?
                                    LIMIT 1),
                                    (
                                    SELECT
                                        id
                                    FROM
                                        states
                                    WHERE
                                        name = ?
                                    LIMIT 1),
                                    (
                                    SELECT
                                        id
                                    FROM
                                        states
                                    WHERE
                                        name = ?
                                    LIMIT 1),
                                    1)
                                    ON
                                    CONFLICT(from_state1, from_state2, to_state)
                                    DO
                                    UPDATE
                                    SET
                                        count = count + 1;
                                    """, (words[i], words[i+1], words[i+2]))
        

if __name__ == "__main__":
    main()
