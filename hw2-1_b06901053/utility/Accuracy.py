# coding = utf-8

import re
import sys

class Calculator :
    def __init__(self) :
        self.data = {}
        self.space = []
        self.cost = {}
        self.cost['cor'] = 0
        self.cost['sub'] = 1
        self.cost['del'] = 1
        self.cost['ins'] = 1
    def calculate(self, lab, rec) :
        lab.insert(0, '')
        rec.insert(0, '')
        while len(self.space) < len(lab) :
            self.space.append([])
        for row in self.space :
            for element in row :
                element['dist'] = 0
                element['error'] = 'non'
            while len(row) < len(rec) :
                row.append({'dist' : 0, 'error' : 'non'})
        for i in xrange(len(lab)) :
            self.space[i][0]['dist'] = i
            self.space[i][0]['error'] = 'del'
        for j in xrange(len(rec)) :
            self.space[0][j]['dist'] = j
            self.space[0][j]['error'] = 'ins'
        self.space[0][0]['error'] = 'non'
        for token in lab :
            if token not in self.data and len(token) > 0 :
                self.data[token] = {'all' : 0, 'cor' : 0, 'sub' : 0, 'ins' : 0, 'del' : 0}
        for token in rec :
            if token not in self.data and len(token) > 0 :
                self.data[token] = {'all' : 0, 'cor' : 0, 'sub' : 0, 'ins' : 0, 'del' : 0}
        for i, lab_token in enumerate(lab) : 
            for j, rec_token in enumerate(rec) :
                if i == 0 or j == 0 :
                    continue
                min_dist = sys.maxint
                min_error = 'none'
                dist = self.space[i-1][j]['dist'] + self.cost['del']
                error = 'del'
                if dist < min_dist :
                    min_dist = dist
                    min_error = error
                dist = self.space[i][j-1]['dist'] + self.cost['ins']
                error = 'ins'
                if dist < min_dist :
                    min_dist = dist
                    min_error = error
                if lab_token == rec_token :
                    dist = self.space[i-1][j-1]['dist'] + self.cost['cor']
                    error = 'cor'
                else :
                    dist = self.space[i-1][j-1]['dist'] + self.cost['sub']
                    error = 'sub'
                if dist < min_dist :
                    min_dist = dist
                    min_error = error
                self.space[i][j]['dist'] = min_dist
                self.space[i][j]['error'] = min_error
#        for row in self.space :
#            for element in row :
#                print('{dist}'.format(dist = element['dist']), end = ' ')
#            print()
#        for row in self.space :
#            for element in row :
#                print('{error}'.format(error = element['error']), end = ' ')
#            print()
        result = {'lab':[], 'rec':[], 'all':0, 'cor':0, 'sub':0, 'ins':0, 'del':0}
#        print('[{length}]'.format(length = len(lab)), end = ' ')
#        for token in lab :
#            print('[{token}]'.format(token = token.encode('utf-8')), end = ' ')
#        print()
#        print('[{length}]'.format(length = len(rec)), end = ' ')
#        for token in rec :
#            print('[{token}]'.format(token = token.encode('utf-8')), end = ' ')
#        print()
        i = len(lab) - 1
        j = len(rec) - 1
        while True :
#            print('i = {i} j = {j}'.format(i = i, j = j), end = ' ')
#            print('error = {error} dist = {dist}'.format(error = self.space[i][j]['error'], dist = self.space[i][j]['dist']))
            if self.space[i][j]['error'] == 'cor' :
                if len(lab[i]) > 0 :
                    self.data[lab[i]]['all'] = self.data[lab[i]]['all'] + 1
                    self.data[lab[i]]['cor'] = self.data[lab[i]]['cor'] + 1
                    result['all'] = result['all'] + 1
                    result['cor'] = result['cor'] + 1
                result['lab'].insert(0, lab[i])
                result['rec'].insert(0, rec[j])
                i = i - 1
                j = j - 1
            elif self.space[i][j]['error'] == 'sub' :
                if len(lab[i]) > 0 :
                    self.data[lab[i]]['all'] = self.data[lab[i]]['all'] + 1
                    self.data[lab[i]]['sub'] = self.data[lab[i]]['sub'] + 1
                    result['all'] = result['all'] + 1
                    result['sub'] = result['sub'] + 1
                result['lab'].insert(0, lab[i])
                result['rec'].insert(0, rec[j])
                i = i - 1
                j = j - 1
            elif self.space[i][j]['error'] == 'del' :
                if len(lab[i]) > 0 :
                    self.data[lab[i]]['all'] = self.data[lab[i]]['all'] + 1
                    self.data[lab[i]]['del'] = self.data[lab[i]]['del'] + 1
                    result['all'] = result['all'] + 1
                    result['del'] = result['del'] + 1
                result['lab'].insert(0, lab[i])
                result['rec'].insert(0, "")
                i = i - 1
            elif self.space[i][j]['error'] == 'ins' :
                if len(rec[j]) > 0 :
                    self.data[rec[j]]['ins'] = self.data[rec[j]]['ins'] + 1
                    result['ins'] = result['ins'] + 1
                result['lab'].insert(0, "")
                result['rec'].insert(0, rec[j])
                j = j - 1
            elif self.space[i][j]['error'] == 'non' :
                break
            else :
                print('this should not happen , i = {i} , j = {j} , error = {error}'.format(i = i, j = j, error = self.space[i][j]['error']))
        return result
    def overall(self) : 
        result = {'all':0, 'cor':0, 'sub':0, 'ins':0, 'del':0}
        for token in self.data :
            result['all'] = result['all'] + self.data[token]['all']
            result['cor'] = result['cor'] + self.data[token]['cor']
            result['sub'] = result['sub'] + self.data[token]['sub']
            result['ins'] = result['ins'] + self.data[token]['ins']
            result['del'] = result['del'] + self.data[token]['del']
        return result
    def cluster(self, data) :
        result = {'all':0, 'cor':0, 'sub':0, 'ins':0, 'del':0}
        for token in data :
            if token in self.data :
                result['all'] = result['all'] + self.data[token]['all']
                result['cor'] = result['cor'] + self.data[token]['cor']
                result['sub'] = result['sub'] + self.data[token]['sub']
                result['ins'] = result['ins'] + self.data[token]['ins']
                result['del'] = result['del'] + self.data[token]['del']
        return result
    def keys(self) :
        return self.data.keys()

def is_chinese(word):
    for char in word :
        if char < u'\u4e00' or char > u'\u9fa5':
            return False
    return True

