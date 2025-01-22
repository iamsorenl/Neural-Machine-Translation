bash prepare-iwslt13fr2en-BPE.sh

# Preprocess/binarize the data
TEXT=iwslt13.tokenized.fr-en
fairseq-preprocess --source-lang de --target-lang en \
    --trainpref $TEXT/train --validpref $TEXT/valid --testpref $TEXT/test \
    --destdir data-bin/iwslt14.tokenized.de-en \
    --workers 20