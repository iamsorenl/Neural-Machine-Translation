bash prepare-iwslt13fr2en-BPE.sh

# Preprocess/binarize the data
TEXT=iwslt13.tokenized.fr-en
fairseq-preprocess --source-lang fr --target-lang en \
    --trainpref $TEXT/train --validpref $TEXT/valid --testpref $TEXT/test \
    --destdir data-bin-transformer-BPE/iwslt13.tokenized.fr-en \
    --workers 4
    