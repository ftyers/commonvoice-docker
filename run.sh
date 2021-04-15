#!/bin/bash 
#LLENGUA=br
## LR {0.001, 0.0001, 0.00001}
#LEARNING_RATE="0.001"
##B_LEARNING_RATE="0.0001"
##C_LEARNING_RATE="0.00001"
## DROPOUT {0.2, 0.4, 0.6}
#DROPOUT="0.2"
##Y_DROPOUT="0.4"
##Z_DROPOUT="0.2"
##SPECAUG: 0, 1
#SPECAUG="--augment frequency_mask[p=0.8,n=2:4,size=2:4]  --augment time_mask[p=0.8,n=2:4,size=10:50,domain=spectrogram]"
##OFF_SPECAUG=""
#
ls /mnt/wikipedia
ls / /mnt /media 
ls /STT
cat /config && source /config  &&
tar -xzf /mnt/$LLENGUA.tar.gz --directory /media &&
python /STT/bin/import_cv2.py --validate_label_locale $LLENGUA /media/cv-corpus-6.1-2020-12-11/$LLENGUA/ &&
wc -l /media/cv-corpus-6.1-2020-12-11/$LLENGUA/*.tsv
wc -l /media/cv-corpus-6.1-2020-12-11/$LLENGUA/clips/*.csv
SP="OFF"
if [[ ! -z "${SPECAUG}" ]]; then
	SP="ON"
fi
mkdir -p /mnt/logs/${LLENGUA}
/bin/bash -x /train.sh >/mnt/logs/${LLENGUA}/train_${LEARNING_RATE}_${DROPOUT}_${SP} 2>&1
/bin/bash -x /test.sh >/mnt/logs/${LLENGUA}/test_${LEARNING_RATE}_${DROPOUT}_${SP} 2>&1
/bin/bash -x /lm.sh >/mnt/logs/${LLENGUA}/lm_${LEARNING_RATE}_${DROPOUT}_${SP} 2>&1
/bin/bash -x /export.sh >/mnt/logs/${LLENGUA}/export_${LEARNING_RATE}_${DROPOUT}_${SP} 2>&1
