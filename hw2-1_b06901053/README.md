# mandarin-digit-asr
DSP hw2
# My modification:
1. numiters in train.sh:
    Increase number of iteration to 30
    acc ->76.28%
2. the number of gaussian in train.sh:
    Increase totgauss to 100
    maxiterinc to 25
    acc -> 85.61%
    Increase totgauss to 1000
    maxiterinc to 25
    acc -> % 90.73%
    Increase totgauss to 5000
    maxiterinc to 45
    numiters to 50
    acc -> 92.75%
    realign_iters="1 2 3 4 5 10 15 20 25 30 35 40 45"
    test_beam = 30.0
    acc -> 93.15%
    Change number of state(silence phone)to 5:
    acc -> 93.9%

    New:
    numiters=30                                   
    maxiterinc=25                                 
    numgauss=10                                   
    totgauss=3000
    realign_iters="1 2 3 4 5 10 15 20";
    92.23%
    change number of state(silence phone) to 5:
    86.76% WTF
    Changen number of state + test_beam60:
    93.84%
    Changen number of state + test_beam60 + change opt_acwt to 0.15
    97.01%:

