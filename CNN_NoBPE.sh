# Prepare and preprocess the iwslt13 fr-en dataset with No BPE
bash prepare-iwslt13fr2en-NoBPE.sh

# Binarize the dataset
TEXT=iwslt13.tokenized.fr-en
fairseq-preprocess \
    --source-lang fr --target-lang en \
    --trainpref $TEXT/train --validpref $TEXT/valid --testpref $TEXT/test \
    --destdir data-bin-CNN-NoBPE/iwslt13_fr_en --thresholdtgt 0 --thresholdsrc 0 \
    --workers 4

# Train the model
mkdir -p checkpoints/fconv_iwslt_fr_en
CUDA_VISIBLE_DEVICES=5 fairseq-train \
    data-bin-CNN-NoBPE/iwslt13_fr_en \
    --arch fconv_iwslt_de_en \
    --dropout 0.1 \
    --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
    --optimizer nag --clip-norm 0.1 \
    --lr 0.5 --lr-scheduler fixed --force-anneal 50 \
    --max-tokens 3000 \
    --save-dir checkpoints/fconv_iwslt_fr_en \
    --max-epoch 10

# Evaluate
fairseq-generate \
    data-bin-CNN-NoBPE/iwslt13_fr_en \
    --path checkpoints/fconv_iwslt_fr_en/checkpoint_best.pt \
    --beam 5