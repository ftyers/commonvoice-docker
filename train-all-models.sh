
for line in $(cat models.txt | grep -v '^#' | cut -f1 -d';'); do
	# hsb:0.0001:0.4:ON:100;1:26:58
	lang=$(echo ${line} | cut -f1 -d':')
	lr=$(echo ${line} | cut -f2 -d':')
	dropout=$(echo ${line} | cut -f3 -d':')
	specaug=$(echo ${line} | cut -f4 -d':')
	epochs=$(echo ${line} | cut -f5 -d':')
	cat config.tmpl | sed "s/#LLENGUA=XXX_LANG/LLENGUA=${lang}/g" | sed "s/XXX_EP/${epochs}/g"  | sed "s/XXX_DR/${dropout}/g" | sed "s/XXX_LR/${lr}/g" | sed "s/#${specaug}_//g" > configs/config.${lang}-${lr}_${dropout}_${specaug}
	cat configs/config.${lang}-${lr}_${dropout}_${specaug} > config
	cat config

	llang=`echo ${lang} | uconv -x lower`
	docker build -f Dockerfile -t  stt-${llang}:${lr}-${dropout}-${specaug} .
	docker run -it --rm --name X-stt-${llang} --gpus all --mount type=bind,src=/data,dst=/mnt stt-${llang}:${lr}-${dropout}-${specaug}
done
