for i in range(0,512):
    print(f"(SELECT id FROM states WHERE name = ? LIMIT 1),")
