fairseq-generate data-bin-transformer-BPE/iwslt13.tokenized.fr-en \
    --path checkpoints/checkpoint_best.pt \
    --batch-size 128 --beam 5 --remove-bpe \
    --gen-subset valid > valid.en.BPE.generated.txt