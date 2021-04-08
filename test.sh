LLENGUA=XXX
mkdir -p results

TF_CUDNN_RESET_RND_GEN_STATE=1 python3 train.py \
--show_progressbar True \
--train_cudnn \
--epochs 1 \
--train_batch_size 8 \
--test_batch_size 8 \
--dev_batch_size 8 \
--alphabet_config_path /media/cv-corpus-6.1-2020-12-11/$LLENGUA/alphabet.txt \
--save_checkpoint_dir checkpoints \
--load_checkpoint_dir checkpoints/ \
--test_output_file results/full_test_output.json \
--train_files /media/cv-corpus-6.1-2020-12-11/$LLENGUA/clips/train.csv \
--dev_files /media/cv-corpus-6.1-2020-12-11/$LLENGUA/clips/dev.csv \
--test_files /media/cv-corpus-6.1-2020-12-11/$LLENGUA/clips/test.csv 


