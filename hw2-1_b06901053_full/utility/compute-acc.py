# coding = utf-8

from __future__ import print_function
from Accuracy import Calculator
from Accuracy import is_chinese
import re
import sys

if __name__ == '__main__':
    calculator = Calculator()
    rec_set = {}
    for line in sys.stdin :
        array = line.decode('utf-8').rstrip('\n').split()
        fid = ''
        rec = []
        for idx, token in enumerate(array) :
            if idx == 0 :
                fid = token
            else :
                rec.append(token)
        rec_set[fid] = rec
    for line in open(sys.argv[1], 'r') :
        array = line.decode('utf-8').rstrip('\n').split()
        fid = ''
        lab = []
        for idx, token in enumerate(array) :
            if idx == 0 :
                fid = token
            else :
                lab.append(token)
        print('fid: {fid}'.format(fid = fid))
        rec = []
        if fid in rec_set :
            rec = rec_set[fid]
        result = calculator.calculate(lab, rec)
        acc = float(result['cor'] - result['ins']) * 100.0 / result['all']
        print('acc: %4.2f %%' % acc, end = ' ')
#        print('acc: {acc}'.format(acc = acc*100), end = ' ')
        print('N: {total}'.format(total = result['all']), end = ' ')
        print('C: {correct}'.format(correct = result['cor']), end = ' ')
        print('S: {substitution}'.format(substitution = result['sub']), end = ' ')
        print('D: {deletion}'.format(deletion = result['del']), end = ' ')
        print('I: {insertion}'.format(insertion = result['ins']))
        space = {}
        space['lab'] = []
        space['rec'] = []
        for idx in xrange(len(result['lab'])) :
            len_lab = len(result['lab'][idx])
            if is_chinese(result['lab'][idx]) :
                len_lab = len_lab * 2
            len_rec = len(result['rec'][idx])
            if is_chinese(result['rec'][idx]) :
                len_rec = len_rec * 2
            length = max(len_lab, len_rec)
            space['lab'].append(length-len_lab)
            space['rec'].append(length-len_rec)
        print('lab:', end = ' ')
        for idx, token in enumerate(result['lab']) :
            print('{token}'.format(token = token.encode('utf-8')), end = ' ')
            for n in xrange(space['lab'][idx]) : 
                print(' ', end = '')
        print()
        print('rec:', end = ' ')
        for idx, token in enumerate(result['rec']) :
            print('{token}'.format(token = token.encode('utf-8')), end = ' ')
            for n in xrange(space['rec'][idx]) :
                print(' ', end = '')
        print()
    cluster_id = []
    cluster_word = []
    if len(sys.argv) > 2 : 
        for line in open(sys.argv[2], 'r') :
            for token in line.decode('utf-8').rstrip('\n').split() :
                if token[0:2] == '<<' and token[len(token)-2:len(token)] == '>>' :
                    cluster_id.append(token[1:len(token)-1])
                    cluster_word.append({})
                    continue
                cluster_word[len(cluster_id)-1][token] = 1
#        for idx, data in enumerate(cluster_word) :
#            print(cluster_id[idx])
#            for token in data :
#                print(token)
    print('===========================================================================')
    print()
    overall = calculator.overall()
    acc = float(overall['cor'] - overall['ins']) * 100.0 / overall['all']
    print('overall accuracy = %4.2f %%' % acc, end = ' ')
    print('N: {total}'.format(total = overall['all']), end = ' ')
    print('C: {correct}'.format(correct = overall['cor']), end = ' ')
    print('S: {substitution}'.format(substitution = overall['sub']), end = ' ')
    print('D: {deletion}'.format(deletion = overall['del']), end = ' ')
    print('I: {insertion}'.format(insertion = overall['ins']))
    for idx, data in enumerate(cluster_word) : 
        result = calculator.cluster(data.keys())
        if result['all'] == 0 :
            continue
        acc = float(result['cor'] - result['ins']) * 100.0 / result['all']
        print('%s accuracy = %4.2f %%' % (cluster_id[idx].encode('utf-8'), acc), end = ' ')
        print('N: {total}'.format(total = result['all']), end = ' ')
        print('C: {correct}'.format(correct = result['cor']), end = ' ')
        print('S: {substitution}'.format(substitution = result['sub']), end = ' ')
        print('D: {deletion}'.format(deletion = result['del']), end = ' ')
        print('I: {insertion}'.format(insertion = result['ins']))
    print()
    print('===========================================================================')
