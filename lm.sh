source /config

mkdir -p /mnt/models/${LLENGUA}
cp -r checkpoints/ /media/cv-corpus-6.1-2020-12-11/${LLENGUA}/alphabet.txt /mnt/models/${LLENGUA}/

mkdir -p /lm/${LLENGUA}

ls /mnt/wikipedia/

XLENGUA=$(echo ${LLENGUA} | cut -f1 -d'-')
covo opus $XLENGUA | grep -e OpenSubtitles -e TED | cut -f2 > /lm/urls.txt
lines=$(cat /lm/urls.txt | wc -l)
if [[ ${lines} -gt 0 ]]; then
	cat /lm/urls.txt | xargs wget -O - | zcat | covo norm $LLENGUA > /lm/wiki.txt
else
	covo dump /mnt/wikipedia/$XLENGUA""wiki-latest-pages-articles.xml.bz2 | covo segment $LLENGUA | covo norm $LLENGUA > /lm/wiki.txt
fi

wc /lm/wiki.txt

python3 /STT/data/lm/generate_lm.py \
  --input_txt /lm/wiki.txt \
  --output_dir /lm/${LLENGUA}/ \
  --top_k 500000 \
  --discount_fallback \
  --kenlm_bins /STT/kenlm/build/bin/ \
  --arpa_order 5 \
  --max_arpa_memory "85%" \
  --arpa_prune "0|0|1" \
  --binary_a_bits 255 \
  --binary_q_bits 8 \
  --binary_type trie

/generate_scorer_package \
  --alphabet /mnt/models/${LLENGUA}/alphabet.txt \
  --lm /lm/${LLENGUA}/lm.binary \
  --vocab /lm/${LLENGUA}/vocab-500000.txt \
  --package /lm/${LLENGUA}/kenlm.scorer \
  --default_alpha 0.931289039105002 \
  --default_beta 1.1834137581510284

cp /lm/${LLENGUA}/kenlm.scorer /mnt/models/${LLENGUA}/

