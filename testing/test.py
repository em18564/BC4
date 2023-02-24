import csv
a = [[1,2,3],[4,5,6]]
b = [[7,8,9],[22,5,1]]
flat_list_a = [item for sublist in a for item in sublist]
flat_list_b = [item for sublist in b for item in sublist]

print(flat_list_a)
with open("data/test.csv", "a", newline="") as f:
    writer = csv.writer(f)
    flat = [item for sublist in a for item in sublist]
    print(flat)
    writer.writerow(flat)