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
    #print("type(hex_bin)==str is",isinstance(hex_bin, str))
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
    return data_filename

def divide_4_data(data_filename):
    f_data = open(data_filename, "rb")
    read_data = f_data.read()
    #print("type(read_data)==bytes is",isinstance(read_data, bytes))
    read_data_str = str(read_data,'utf-8')
    #print("type(read_data_str)==str is",isinstance(read_data_str, str))
    data_1_filename = "inst1.data"
    data_2_filename = "inst2.data"
    data_3_filename = "inst3.data"
    data_4_filename = "inst4.data"
  
    f1_data = open(data_1_filename, "w")
    f2_data = open(data_2_filename, "w")
    f3_data = open(data_3_filename, "w")
    f4_data = open(data_4_filename, "w")


    for i in range(len(read_data_str)):
        if (i%9 == 0):
            f4_data.write(read_data_str[i:i+2])
            f4_data.write("\n")
        elif (i%9 == 2):
            f3_data.write(read_data_str[i:i+2])
            f3_data.write("\n")
        elif (i%9 == 4):
            f2_data.write(read_data_str[i:i+2])
            f2_data.write("\n")
        elif (i%9 == 6):
            f1_data.write(read_data_str[i:i+2])  
            f1_data.write("\n")

    f1_data.close()
    f2_data.close()
    f3_data.close()
    f4_data.close()
    print("divide data success")

def main():
    arg = sys.argv[1]
    divide_4_data(bin2data(arg))

if __name__ == "__main__":
    main()
    
