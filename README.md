# Overview

This repository contains some data and soft related to distributional modelling of meaning. Specifically, our aim is to provide [vector space models of meaning](http://www.wordspace.collocations.de/doku.php) for Russian, based on medium-size corpora (tens of millions of tokens), and certain non-generic, but highly parameterizable software infrastructure to compute semantic distances.

To run scripts you will need Perl 5.x, preferably 5.10 or higher. Note the ANSI 1251 encoding of all files.

# ITaS 2013

These are data and scripts accompanying the paper: V. Poritski, O. Volchek. [Building a vector space model of meaning for Russian: A preliminary study](http://www.itas2013.iitp.ru/pdf/1569758773.pdf) (ITaS'13). The resource still remains incomplete and undocumented; actually, it is to be completely rewritten.

# Dialog 2014

These are data and scripts accompanying the paper: V. Dikonov, V. Poritski. [A virtual Russian sense tagged corpus and catching errors in Russian <=> semantic pivot dictionary](http://www.dialog-21.ru/digests/dialog2014/materials/pdf/DikonovVGPoritskiVV.pdf) (Dialog'14). Here you will find further instructions on how to use the resource.

## Preparing VSMs

Vector space models required to compute similarity between UDC universal words and their purported Russian equivalents must be serialized two-dimensional Perl hashes: word, context &#rarr; frequency. (Note that this format is obsolete and subject to future revisions.)

Pre-computed models based on the benchmark Russian corpus can be found in `/benchmark`; they only need to be extracted to the root directory to start using. The designation `full` indicates that each of the VSMs has been built from the complete benchmark corpus, which amounts to 17.5 mln tokens of fiction and newspaper articles. Number `1`, `2`, or `3` indicates linear context window size in tokens. The model with context window 4 turns out to be too bulky to keep it on GitHub.

To build a faithful VSM based on co-occurrence data from the virtual corpus, check out `/virtual` and extract any co-occurrence table you like to the root directory. (Just to play around, `frequency_lts3b.csv` would suffise; detailed descriptions of the co-occurrence tables will be provided later.) Having this done, run:

`perl vsm_full_pre_new.pl <co-occurrence table signature> <MWE handling> <frequency handling>`

Here, "co-occurrence table signature" is the segment between `_` and `.csv`, e.g. `lts3b`. "MWE handling" is a boolean value, `1` if you want to remove all multiword Russian translations, `0` if you want to proceed with multiword units only (actually, this alternative is not handled properly). "Frequency handling" is the strategy of computing overall frequencies of Russian words within the virtual corpus. Two available options are `sum` and `max`. With `sum`, frequency of a target Russian word is said to be the sum of frequencies over all UDC universal words which are observed to have the target word as their translation. With `max`, only the highest frequency is taken.

As an example, to process only single-word translations in `frequency_lts3b.csv` with frequency handling by maximum, run:

`perl vsm_full_pre_new.pl lts3b 1 max`

Now observe that the basis of the benchmark VSM (same for any window size) is already here, it's `vsm-freq-full.txt`. The basis of the virtual corpus based VSM has just been computed, with the parameters mentioned above it should be `vsm-cfreq-lts3bsemcor-1-max.txt`. Intersecting these two lists, we get the common basis:

`perl freq_intersection_new.pl lts3b 1 max`

This would yield `common_basis-lts3b-1-max.txt`.

## Computing similarity scores

The evaluation proceeds as follows. One of the previous steps gave us, as a by-product, the set of all word<=>sense links attested in the virtual corpus, e.g. `EVAL_lts3b_1.txt`. Now let's assign a similarity score to each link: 

`perl vsm_full_compute_reduce_new.pl <window size> <similarity measure> <PMI reweighting> <co-occurrence table signature> <MWE handling> <frequency handling>`

The last three parameters describe the virtual corpus based VSM, same as before. Another three command line arguments define properties of the benchmark VSM and the computation procedure. "Window size" is linear context window size in tokens, from `1` to `3` with available pre-computed models. "Similarity measure" is invariantly `cosine`. (In earlier builds, `jaccard` for Jaccard coefficient, `kl` for symmetrized Kullback-Leibler divergence, and `js` for Jensen-Shannon divergence were also available. If necessary, you can restore the respective subroutines, just take a look at `vsm_full_compute_reduce.pl` in `/ITaS_2013`.) "PMI reweighting" is a boolean value: `1` to apply PMI, `0` to operate with raw frequency counts. Note that the virtual corpus size in tokens is somewhat guesstimated to be 10^6, in fact it should be around 1.4*10^5.

As an example, take the benchmark VSM with 2-token window and turn PMI reweighting on:

`perl vsm_full_compute_reduce_new.pl 2 cosine 1 lts3b 1 max`

This would yield a table of similarity scores named `res-full-2-cosine-1-lts3b-1-max.txt`. Use any external program you like (e.g. LibreOffice Calc or R) for further processing.
