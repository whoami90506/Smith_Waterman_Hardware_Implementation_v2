import argparse 
import math
import sys

#default value
value = dict()
value['o']   = 'src/spec.v'
value['ma']  = 3
value['pe']  = 256
value['sw']  = 24
value['sa']  = 10
value['buf'] = 2
value['t']   = 32

# restriction
restriction = dict()
restriction['sw']  = (lambda x : x >= 9, 'The width of SRAM must be greater or equal to 9.')
restriction['buf'] = (lambda x : x >= 2, 'The size of query buffer must be greater or equal to  2.')

def clog2(num, offset = 1) :
    return math.ceil( math.log(num + offset, 2) )

def check_input(msg, default, restriction =( lambda x : x > 0, 'Please enter the positive value.')):
    errtime = 0
    err_limit = 3
    while True :
        try:
            data = input(msg + ' (default=' + str(default) + ') : ')
            if not data : return default

            result = int(data)
            if(not restriction[0](result) ) : 
                print("ERROR: " + restriction[1] + '\n')
                
                errtime += 1
                if(errtime >= err_limit) : 
                    print('EXIT')
                    sys.exit()
            else : 
                return result

        except Exception as e:
            errtime += 1
            print('ERROR: ' + str(type(e)), str(e))
            if(errtime >= err_limit) : 
                print('EXIT')
                sys.exit()

def check_command(num, restriction) : 
    if not restriction[0](num) :
        print('ERROR: ' + restriction[1] + '\n')
        sys.exit()

def positive(string):
    value = int(string)
    if value <= 0 :
        msg = "%r is not a postivate" % string
        raise argparse.ArgumentTypeError(msg)
    
    return value

parser = argparse.ArgumentParser(description='Set the specification of the Smith-Waterman hardware.\n' + \
    'you can set the number by either the command line or user interface(no any argument). ')
parser.add_argument('-o', dest='file', help="The destinationof output file.", default=value['o'])

param = parser.add_argument_group('input data')
param.add_argument('-ma' , dest='ma' , type=positive, default=value['ma'] , help="the maxinum bits of match.")
param.add_argument('-pe' , dest='pe' , type=positive, default=value['pe'] , help='the maxinum length of query DNA.(i.e. the number of cell PE)')
param.add_argument('-t'  , dest='t'  , type=positive, default=value['t']  , help='the bits of the maxinum amount of target DNA.')

hardware = parser.add_argument_group('hardware')
hardware.add_argument('-sw' , dest='sw' , type=positive, default=value['sw'] , help='the width of SRAM word.')
hardware.add_argument('-sa' , dest='sa' , type=positive, default=value['sa'] , help='the bits of SRAM address.')
hardware.add_argument('-buf', dest='buf', type=positive, default=value['buf'], help='the size of buffer for query DNA.')


args = parser.parse_args()

# no command
if len(sys.argv) == 1 :
    args.ma   = check_input('Enter the maxinum bits of match parameter'         , value['ma'])
    args.pe   = check_input('Enter the number of PE cell'                       , value['pe'])
    args.sw   = check_input('Enter the width of SRAM'                           , value['sw'], restriction['sw'])
    args.sa   = check_input('Enter the bits of SRAM address'                    , value['sa'])
    args.buf  = check_input('Enter the size of buffer for query DNA'            , value['buf'], restriction['buf'])
    args.t    = check_input('Enter the the bits of maximan amount of target DNA', value['t'])
    args.file = check_input('Enter the output file destination'                 , value['o'])
    print('')
else : # by command
    check_command(args.sw , restriction['sw'] )
    check_command(args.buf, restriction['buf'])

with open(args.file, 'w') as f :
    f.write('`ifdef SPEC_V\n')
    f.write('`else\n')
    f.write('`define SPEC_V\n')
    
    f.write('\n')
    f.write('`define MATCH_BIT ' + str(args.ma)  + '\n')
    f.write('`define PE_NUM    ' + str(args.pe)   + '\n')
    f.write('`define CALC_BIT  ' + str(clog2(args.pe) + args.ma +1) + ' //$clog2(`PE_NUM +1) + `MATCH_BIT +1\n')
    
    f.write('\n')
    f.write('`define SRAM_WORD_WIDTH  ' + str(args.sw)   + '\n')
    f.write('`define SRAM_ADDR_BIT    ' + str(args.sa)   + '\n')
    f.write('`define BUFFER_DEPTH     ' + str(args.buf)   + '\n')
    f.write('`define MAX_T_NUM_BIT    ' + str(args.t)   + '\n')

    f.write('\n')
    f.write('`define DNA_PER_WORD     ' + str(args.sw//3)   + ' // WORD_WIDTH/3\n')
    f.write('`define DNA_PER_WORD_BIT ' + str(clog2(args.sw//3, offset=0))   + ' // $clog2(DNA_PER_WORD)\n')
    f.write('`define PE_NUM_BIT       ' + str(clog2(args.pe, offset=0))   + ' // $clog2(PE_NUM)\n')
    f.write('`define BUFFER_DEPTH_BIT ' + str(clog2(args.buf))   + ' // $clog2(BUFFER_DEPTH+1)\n')

    f.write('\n')
    f.write('`endif\n')

print(args.file)