# Prepare and preprocess the iwslt13 fr-en dataset with BPE
bash prepare-iwslt13fr2en-BPE.sh

# Binarize the dataset
TEXT=iwslt13.tokenized.fr-en
fairseq-preprocess \
    --source-lang fr --target-lang en \
    --trainpref $TEXT/train --validpref $TEXT/valid --testpref $TEXT/test \
    --destdir data-bin-CNN-BPE/iwslt13_fr_en --thresholdtgt 0 --thresholdsrc 0 \
    --workers 4

# Train the model
mkdir -p checkpoints/fconv_iwslt_fr_en
CUDA_VISIBLE_DEVICES=0 fairseq-train \
    data-bin-CNN-BPE/iwslt13_fr_en \
    --arch fconv_iwslt_de_en \
    --dropout 0.15 \
    --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
    --optimizer nag --clip-norm 0.1 \
    --lr 0.5 --lr-scheduler fixed --force-anneal 50 \
    --max-tokens 3000 \
    --save-dir checkpoints/fconv_iwslt_fr_en \
    --max-epoch 10 \
    --encoder-layers '[(512, 5)] * 6' \
    --decoder-layers '[(512, 5)] * 6'

# Evaluate
fairseq-generate \
    data-bin-CNN-BPE/iwslt13_fr_en \
    --path checkpoints/fconv_iwslt_fr_en/checkpoint_best.pt \
    --beam 5 --remove-bpe