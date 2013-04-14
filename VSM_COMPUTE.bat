rem Figure 1

goto last

perl vsm_full_compute_reduce.pl fict 2 1 1 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 2 1 5 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 2 1 10 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 2 1 20 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 2 1 30 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 2 1 40 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 2 1 50 1000000 cosine 1 0

perl vsm_full_compute_reduce.pl fict 2 1 1 1000000 jaccard 0 0
perl vsm_full_compute_reduce.pl fict 2 1 5 1000000 jaccard 0 0
perl vsm_full_compute_reduce.pl fict 2 1 10 1000000 jaccard 0 0
perl vsm_full_compute_reduce.pl fict 2 1 20 1000000 jaccard 0 0
perl vsm_full_compute_reduce.pl fict 2 1 30 1000000 jaccard 0 0
perl vsm_full_compute_reduce.pl fict 2 1 40 1000000 jaccard 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 1000000 jaccard 0 0

perl vsm_full_compute_reduce.pl fict 2 1 1 1000000 js 0 0
perl vsm_full_compute_reduce.pl fict 2 1 5 1000000 js 0 0
perl vsm_full_compute_reduce.pl fict 2 1 10 1000000 js 0 0
perl vsm_full_compute_reduce.pl fict 2 1 20 1000000 js 0 0
perl vsm_full_compute_reduce.pl fict 2 1 30 1000000 js 0 0
perl vsm_full_compute_reduce.pl fict 2 1 40 1000000 js 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 1000000 js 0 0

perl vsm_full_compute_reduce.pl fict 2 1 1 1000000 kl 0 0.00001
perl vsm_full_compute_reduce.pl fict 2 1 5 1000000 kl 0 0.00001
perl vsm_full_compute_reduce.pl fict 2 1 10 1000000 kl 0 0.00001
perl vsm_full_compute_reduce.pl fict 2 1 20 1000000 kl 0 0.00001
perl vsm_full_compute_reduce.pl fict 2 1 30 1000000 kl 0 0.00001
perl vsm_full_compute_reduce.pl fict 2 1 40 1000000 kl 0 0.00001
perl vsm_full_compute_reduce.pl fict 2 1 50 1000000 kl 0 0.00001

rem Figure 2

perl vsm_full_compute_reduce.pl fict 2 1 50 1000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 2 1 50 5000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 2 1 50 10000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 2 1 50 20000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 2 1 50 30000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 2 1 50 40000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 2 1 50 50000 cosine 1 0

perl vsm_full_compute_reduce.pl fict 2 1 50 1000 jaccard 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 5000 jaccard 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 10000 jaccard 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 20000 jaccard 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 30000 jaccard 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 40000 jaccard 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 50000 jaccard 0 0

perl vsm_full_compute_reduce.pl fict 2 1 50 1000 js 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 5000 js 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 10000 js 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 20000 js 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 30000 js 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 40000 js 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 50000 js 0 0

perl vsm_full_compute_reduce.pl fict 2 1 50 1000 kl 0 0.00001
perl vsm_full_compute_reduce.pl fict 2 1 50 5000 kl 0 0.00001
perl vsm_full_compute_reduce.pl fict 2 1 50 10000 kl 0 0.00001
perl vsm_full_compute_reduce.pl fict 2 1 50 20000 kl 0 0.00001
perl vsm_full_compute_reduce.pl fict 2 1 50 30000 kl 0 0.00001
perl vsm_full_compute_reduce.pl fict 2 1 50 40000 kl 0 0.00001
perl vsm_full_compute_reduce.pl fict 2 1 50 50000 kl 0 0.00001

rem Figure 3

perl vsm_full_compute_reduce.pl fict 1 1 5 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 2 1 5 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 3 1 5 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl fict 4 1 5 1000000 cosine 1 0

perl vsm_full_compute_reduce.pl np 1 1 5 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl np 2 1 5 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl np 3 1 5 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl np 4 1 5 1000000 cosine 1 0

perl vsm_full_compute_reduce.pl full 1 1 5 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl full 2 1 5 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl full 3 1 5 1000000 cosine 1 0
perl vsm_full_compute_reduce.pl full 4 1 5 1000000 cosine 1 0

rem Figure 4

perl vsm_full_compute_reduce.pl fict 1 1 50 1000 js 0 0
perl vsm_full_compute_reduce.pl fict 2 1 50 1000 js 0 0
perl vsm_full_compute_reduce.pl fict 3 1 50 1000 js 0 0
perl vsm_full_compute_reduce.pl fict 4 1 50 1000 js 0 0

perl vsm_full_compute_reduce.pl np 1 1 50 1000 js 0 0
perl vsm_full_compute_reduce.pl np 2 1 50 1000 js 0 0
perl vsm_full_compute_reduce.pl np 3 1 50 1000 js 0 0
perl vsm_full_compute_reduce.pl np 4 1 50 1000 js 0 0

perl vsm_full_compute_reduce.pl full 1 1 100 2000 js 0 0
perl vsm_full_compute_reduce.pl full 2 1 100 2000 js 0 0
perl vsm_full_compute_reduce.pl full 3 1 100 2000 js 0 0
perl vsm_full_compute_reduce.pl full 4 1 100 2000 js 0 0

pause