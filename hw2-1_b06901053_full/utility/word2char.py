# coding = utf-8

from __future__ import print_function
import sys

if __name__ == '__main__':
    for line in sys.stdin :
        line = line.decode('utf-8').rstrip('\n')
        result = ''
        for token in line.split() :
            for char in token :
                if char < u'\u4e00' or char > u'\u9fa5': # is english
                    result += char
                else : # is mandarin
                    result += ' '
                    result += char
                    result += ' '
            result += ' '
        for token in result.split() :
            print(token.encode('utf-8'), end = ' ')
        print('')
