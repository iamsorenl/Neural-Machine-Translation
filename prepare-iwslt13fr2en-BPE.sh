#!/usr/bin/env bash

echo 'Cloning Moses github repository (for tokenization scripts)...'
if [ ! -d "mosesdecoder" ]; then
    git clone https://github.com/moses-smt/mosesdecoder.git
else
    echo "Moses repository already cloned. Skipping..."
fi

echo 'Cloning Subword NMT repository (for BPE pre-processing)...'
if [ ! -d "subword-nmt" ]; then
    git clone https://github.com/rsennrich/subword-nmt.git
else
    echo "Subword NMT repository already cloned. Skipping..."
fi

SCRIPTS=mosesdecoder/scripts
TOKENIZER=$SCRIPTS/tokenizer/tokenizer.perl
NORM_PUNC=$SCRIPTS/tokenizer/normalize-punctuation.perl
REM_NON_PRINT_CHAR=$SCRIPTS/tokenizer/remove-non-printing-char.perl
CLEAN=$SCRIPTS/training/clean-corpus-n.perl
BPEROOT=subword-nmt/subword_nmt
BPE_TOKENS=40000

CORPORA=(
    "train.tags.fr-en"
)

src=fr
tgt=en
lang=fr-en
prep=iwslt13.tokenized.fr-en
tmp=$prep/tmp
orig=fr-en

mkdir -p $orig $tmp $prep

echo "Pre-processing train data..."
for l in $src $tgt; do
    rm -f $tmp/train.$l
    for f in "${CORPORA[@]}"; do
        # Extract text between <transcript> and </transcript> and clean it
        sed -n '/<transcript>/,/<\/transcript>/p' $orig/$f.$l | \
            sed -e 's/<transcript>//g' | \
            sed -e 's/<\/transcript>//g' | \
            perl $NORM_PUNC $l | \
            perl $REM_NON_PRINT_CHAR | \
            perl $TOKENIZER -threads 8 -a -l $l >> $tmp/train.$l
    done
done

echo "Cleaning train data..."
perl $CLEAN -ratio 1.5 $tmp/train $src $tgt $prep/train 1 250

echo "Training data preprocessing completed!"