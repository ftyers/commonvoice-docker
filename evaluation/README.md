## Install

```bash
$ pip install -r requirements.txt
```

## Input 

The input file is the output of the STT training script.

```json
[
  {
    "wav_filename": "/media/cv-corpus-6.1-2020-12-11/pt/clips/common_voice_pt_21847705.wav",
    "src": "um menino está saltando no skate no meio de uma ponte vermelha",
    "res": "um menino está saltando no skate no meio de uma ponte vermelha",
    "loss": 52.179954528808594,
    "char_distance": 0,
    "char_length": 62,
    "word_distance": 0,
    "word_length": 12,
    "cer": 0.0,
    "wer": 0.0
  },
  ...
]
```

You also need the clips in a directory called `clips/`

## Usage

```bash
$ python3 transcribe-evaluate.py full_test_output_lm.json 
      ------------------------------------------------------
      TAB: play clip; ENTER: submit transcription
      CTRL+A: beginning of sentence; CTRL+E: end of sentence
      CTRL+LEFT: skip word left; CTRL+RIGHT: skip word right
      ------------------------------------------------------
      
[001] 
>     um casal de pé no escuro perto de algumas luzes festivas
[001] 6.38 ~ 4.77 | um casal de pé no escuro perto de algumas luzes festivas

[002] 
>     eu não estou com pressa
[002] 5.66 ~ 6.84 | eu não estou com pressa

[003] 
>     eu irei comprar na black friday
[003] 4.34 ~ 6.12 | eu irei comprar na black friday

[004] 
>     você pode ir ao dispensador e fazer um pouco de lava
[004] 5.69 ~ 6.66 | você pode ir ao dispensador e fazer um pouco de lava

1859fa2144e26d19fad0dcef0c95ea09f30940b0045742530e60b2740472a4a4	0.1071	0.2727	0	6.3840	4.7739	6.3840	1.7478
83932df800ebdd79e6d0fefe3969db28f0a28aabbdec3b91388723186decc6f3	0.0000	0.0000	1	5.6640	6.8388	6.8388	2.2074
5318ab7f9f108a1ddfefeb2cccd4817e00811b6eb73259de02c99fea674748aa	0.5161	0.6667	1	4.3440	6.1179	6.1179	2.4084
e3b7dcf3d9e4caf089e589c8bed24d6a9f537ac43b099bf3d80ac0c675596fb4	0.1346	0.2727	0	5.6880	6.6559	6.6559	2.1702
```

## Output format

The output is a table with:

| Hash | CER | WER | Type | Length of clip | Response time | Response time (norm.) | Ratio  |
|------|-----|-----|------|----------------|---------------|-----------------------|--------|
| 1859fa214 | 0.1071	| 0.2727| 	0	| 6.3840	| 4.7739| 	6.3840| 	1.7478|

**Type**:
* `0` without ASR
* `1` with ASR
