from argparse import ArgumentParser

table = {"A" : "100", "a" : "100", "C" : "101", 'c' : '101', 'G' : '110', 'g' : '110', 'T' : '111', 't' : '111', 'NP' : '000', 'END':'001'}
idx = 0
word = 0

def myReadLine(f) :
    ans = f.readline()
    if not ans : return ""

    while ans[-1] == '\n' or ans[-1] == '\r' or ans[-1] == ' ': ans = ans[:-1]

    return ans

def writeDNA(f,dat = 'NP') :
    global idx, word
    f.write(table[dat])
    idx += 3
    if idx+3 > word  : 
        for _ in range(word - idx) : f.write('0')
        f.write('\n')
        idx = 0



def main() :
    global idx, word
    parser = ArgumentParser(description='A program that convert the DNA sequence to hardware format.')
    parser.add_argument('i', help='input file.')
    parser.add_argument('o', help='output file.')
    parser.add_argument('-w', dest='word', type=int, default=24, help='How many elements per word.')
    args = parser.parse_args()
    word = args.word

    with open(args.i, 'r') as fin :

        with open(args.o, 'w') as fout :
            idx = 0

            buffer = myReadLine(fin)
            num = int(buffer)
            
            for i in range(num) :
                buffer = myReadLine(fin)
                for element in buffer : writeDNA(fout,element)
                writeDNA(fout) if i != num -1 else writeDNA(fout, 'END')

            if idx < word and idx != 0 : 
                for _ in range(word - idx) : fout.write('0')
                fout.write('\n')




if  __name__ == "__main__":
    main()