import os
import gzip
import pickle
from typing import Dict, List, Tuple

PATH = "/dev/shm/THUCNews/THUCNews"

DOCUMENTS: Dict[str, List[Tuple[str, str]]] = {}

for root, dirs, files in os.walk(PATH):
    if root != PATH:
        _, category = os.path.split(root)
        print("category: ", category)
        for filename in files:
            path = os.path.join(root, filename)
            with open(path, "r", encoding="utf8") as file:
                title = file.readlines()[0]
            if category in DOCUMENTS:
                DOCUMENTS[category].append((filename, title))
            else:
                DOCUMENTS[category] = [(filename, title)]
        DOCUMENTS[category].sort(key=lambda file: file[0])

for item in DOCUMENTS["财经"][:10]:
    print(item)

with gzip.open("THUCNews.pickle.gz", "w") as file:
    pickle.dump(DOCUMENTS, file)
