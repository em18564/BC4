import csv
a = [[1,2,3],[4,5,6]]
b = [[7,8,9],[22,5,1]]

with open("out.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(a)

with open("out.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(b)