fairseq-generate data-bin-transformer-NoBPE/iwslt13.tokenized.fr-en \
    --path checkpoints/checkpoint_best.pt \
    --batch-size 128 --beam 5