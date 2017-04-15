from sys import argv

def tak(x, y, z):
    if y < x:
        return tak(tak(x-1, y, z), tak(y-1, z, x), tak(z-1, x, y))
    else:
        return z

print("Ans: " + str(tak(int(argv[1]), int(argv[2]), int(argv[3]))))
