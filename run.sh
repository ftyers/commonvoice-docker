# LR {0.001, 0.0001, 0.00001}
#A_LEARNING_RATE="0.001"
#B_LEARNING_RATE="0.0001"
#C_LEARNING_RATE="0.00001"
# DROPOUT {0.2, 0.4, 0.6}
#X_DROPOUT="0.2"
#Y_DROPOUT="0.4"
#Z_DROPOUT="0.2"
#SPECAUG: 0, 1
#ON_SPECAUG="--augment frequency_mask[p=0.8,n=2:4,size=2:4]  --augment time_mask[p=0.8,n=2:4,size=10:50,domain=spectrogram]"
#OFF_SPECAUG=""

mkdir -p configs
for lang in br cv ga-IE; do 
	for i in A B C; do
		for j in X Y Z; do
			for k in ON OFF; do
				rm -f config
				cat config.tmpl | sed "s/#LLENGUA=XXX_LANG/LLENGUA=${lang}/g" | sed "s/#${i}_//g" | sed "s/#${j}_//g" | sed "s/#${k}_//g" > configs/config.${lang}.${i}.${j}.${k}
				cat ${PWD}/configs/config.${lang}.${i}.${j}.${k} > config
				docker build -f Dockerfile -t  stt-${lang}:${i}.${j}.${k} .
			done
			exit;
		done
	done
done
