import sys
import os
import os.path

def bin_reversed(hex_bin):
    hex_bin_temp = ""
    for i in range(int(len(hex_bin)/8)):
        hex_bin_temp = hex_bin_temp + hex_bin[i*8+6:i*8+8] + hex_bin[i*8+4:i*8+6] + hex_bin[i*8+2:i*8+4] + hex_bin[i*8:i*8+2]
    return hex_bin_temp    

def bin2data(bin_filename):
    f_bin = open(bin_filename, "rb")
    read_bin = f_bin.read()
    #print("type(read_bin)==bytes is",isinstance(read_bin, bytes))
    data_filename = bin_filename[:-3] + "data"
    f_data = open(data_filename, "w")
    hex_bin = bytearray(read_bin).hex()
    print("type(read_bin)==str is",isinstance(hex_bin, str))
    hex_bin_reversed = bin_reversed(hex_bin)

    j = 0
    for i in hex_bin_reversed:
        f_data.write(i)
        j += 1
        if(j==8):
            f_data.write("\n")
            j = 0
   
    f_bin.close()
    f_data.close()
    print("bin to data success")

def main():
    arg = sys.argv[1]
    bin2data(arg)

if __name__ == "__main__":
    main()
    