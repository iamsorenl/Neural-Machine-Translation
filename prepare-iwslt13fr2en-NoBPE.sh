#!/usr/bin/env bash

echo 'Cloning Moses github repository (for tokenization scripts)...'
if [ ! -d "mosesdecoder" ]; then
    git clone https://github.com/moses-smt/mosesdecoder.git
else
    echo "Moses repository already cloned. Skipping..."
fi

SCRIPTS=mosesdecoder/scripts
TOKENIZER=$SCRIPTS/tokenizer/tokenizer.perl
LC=$SCRIPTS/tokenizer/lowercase.perl
CLEAN=$SCRIPTS/training/clean-corpus-n.perl

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

# Rename the cleaned training files
mv $tmp/train.tags.$lang.$src $prep/train.$src
mv $tmp/train.tags.$lang.$tgt $prep/train.$tgt

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

# Rename the validation and test files
mv $tmp/IWSLT13.TED.dev2010.fr-en.$src $prep/valid.$src
mv $tmp/IWSLT13.TED.dev2010.fr-en.$tgt $prep/valid.$tgt
mv $tmp/IWSLT13.TED.tst2010.fr-en.$src $prep/test.$src
mv $tmp/IWSLT13.TED.tst2010.fr-en.$tgt $prep/test.$tgt

echo "File renaming completed! Processed files:"
echo "$prep/train.$src, $prep/train.$tgt, $prep/valid.$src, $prep/valid.$tgt, $prep/test.$src, $prep/test.$tgt"