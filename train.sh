source /config

mkdir -p /checkpoints

TF_CUDNN_RESET_RND_GEN_STATE=1 python /STT/DeepSpeech.py \
    --show_progressbar True \
    --train_cudnn \
    --epochs ${EPOCHS} \
    --noearly_stop \
    --learning_rate ${LEARNING_RATE} \
    --dropout_rate ${DROPOUT} \
    --max_to_keep 1 \
    --drop_source_layers 2 \
    --train_batch_size 8 \
    --test_batch_size 8 \
    --dev_batch_size 8 \
    --alphabet_config_path /media/cv-corpus-6.1-2020-12-11/${LLENGUA}/alphabet.txt \
    --save_checkpoint_dir /checkpoints \
    --load_checkpoint_dir /deepspeech-0.9.3-checkpoint/ \
    --train_files /media/cv-corpus-6.1-2020-12-11/${LLENGUA}/clips/train.csv \
    --dev_files /media/cv-corpus-6.1-2020-12-11/${LLENGUA}/clips/dev.csv \
    --test_files /media/cv-corpus-6.1-2020-12-11/${LLENGUA}/clips/test.csv \
    ${SPECAUG}

