source /config

mkdir -p /models
chmod +x ./convert_graphdef_memmapped_format 

python3 /STT/DeepSpeech.py \
    --alphabet_config_path /media/cv-corpus-6.1-2020-12-11/$LLENGUA/alphabet.txt \
 --load_checkpoint_dir /checkpoints/ \
  --checkpoint_dir /checkpoints/ \
  --save_checkpoint_dir /checkpoints/ \
   --export_dir /models

/convert_graphdef_memmapped_format \
    --in_graph=/models/output_graph.pb \
    --out_graph=/models/output_graph.pbmm

python3 /STT/DeepSpeech.py \
    --alphabet_config_path /media/cv-corpus-6.1-2020-12-11/$LLENGUA/alphabet.txt \
     --checkpoint_dir /checkpoints \
     --export_dir /models/ \
     --export_tflite

cp /models/* /mnt/models/$LLENGUA/
cp results/* /mnt/models/$LLENGUA/
cp /media/cv-corpus-6.1-2020-12-11/$LLENGUA/clips/test.csv /mnt/models/$LLENGUA/

python3 /STT/evaluate.py --load_cudnn --scorer /mnt/models/$LLENGUA/kenlm.scorer --load_evaluate best --load_checkpoint_dir /mnt/models/$LLENGUA/checkpoints/ --test_files /media/cv-corpus-6.1-2020-12-11/$LLENGUA/clips/test.csv --alphabet_config_path /mnt/models/$LLENGUA/alphabet.txt --test_batch_size 8 --test_output_file /mnt/models/$LLENGUA/full_test_output_lm.json

