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
LC=$SCRIPTS/tokenizer/lowercase.perl
NORM_PUNC=$SCRIPTS/tokenizer/normalize-punctuation.perl
REM_NON_PRINT_CHAR=$SCRIPTS/tokenizer/remove-non-printing-char.perl
CLEAN=$SCRIPTS/training/clean-corpus-n.perl
BPEROOT=subword-nmt/subword_nmt
BPE_TOKENS=10000

CORPORA=(
    "fr-en/train.tags.fr-en"
)

DEVFILES=(
    "fr-en/IWSLT13.TED.dev2010.fr-en.en.xml"
    "fr-en/IWSLT13.TED.dev2010.fr-en.fr.xml"
)

TESTFILES=(
    "fr-en/IWSLT13.TED.tst2010.fr-en.en.xml"
    "fr-en/IWSLT13.TED.tst2010.fr-en.fr.xml"
)

src=fr
tgt=en
lang=fr-en
prep=iwslt13.tokenized.fr-en
tmp=$prep/tmp
orig=orig

mkdir -p $orig $tmp $prep

echo "pre-processing train data..."
for l in $src $tgt; do
    f=train.tags.$lang.$l
    tok=train.tags.$lang.tok.$l

    cat $orig/$lang/$f | \
    grep -v '<url>' | \
    grep -v '<talkid>' | \
    grep -v '<keywords>' | \
    sed -e 's/<title>//g' | \
    sed -e 's/<\/title>//g' | \
    sed -e 's/<description>//g' | \
    sed -e 's/<\/description>//g' | \
    perl $TOKENIZER -threads 8 -l $l > $tmp/$tok
    echo ""
done
perl $CLEAN -ratio 1.5 $tmp/train.tags.$lang.tok $src $tgt $tmp/train.tags.$lang.clean 1 175
for l in $src $tgt; do
    perl $LC < $tmp/train.tags.$lang.clean.$l > $tmp/train.tags.$lang.$l
done

echo "Training data preprocessing completed!"

echo "pre-processing valid/test data..."
for l in $src $tgt; do
    for o in `ls $orig/$lang/IWSLT13.TED*.$l.xml`; do
    fname=${o##*/}
    f=$tmp/${fname%.*}
    echo $o $f
    grep '<seg id' $o | \
        sed -e 's/<seg id="[0-9]*">\s*//g' | \
        sed -e 's/\s*<\/seg>\s*//g' | \
        sed -e "s/\’/\'/g" | \
    perl $TOKENIZER -threads 8 -l $l | \
    perl $LC > $f
    echo ""
    done
done

TRAIN=$tmp/train.fr-en
rm -f $TRAIN
for l in $src $tgt; do
    cat $tmp/train.tags.fr-en.clean.$l >> $TRAIN
done

BPE_CODE=$prep/code

echo "learn_bpe.py on ${TRAIN}..."
python $BPEROOT/learn_bpe.py -s $BPE_TOKENS < $TRAIN > $BPE_CODE

# Apply BPE to the appropriate files in your directory
for L in $src $tgt; do
    # Apply BPE to training data
    echo "apply_bpe.py to train.$L..."
    python $BPEROOT/apply_bpe.py -c $BPE_CODE < $tmp/train.tags.fr-en.clean.$L > $prep/train.$L

    # Apply BPE to validation data
    echo "apply_bpe.py to valid.$L..."
    python $BPEROOT/apply_bpe.py -c $BPE_CODE < $tmp/IWSLT13.TED.dev2010.fr-en.$L > $prep/valid.$L

    # Apply BPE to test data
    echo "apply_bpe.py to test.$L..."
    python $BPEROOT/apply_bpe.py -c $BPE_CODE < $tmp/IWSLT13.TED.tst2010.fr-en.$L > $prep/test.$L
done
