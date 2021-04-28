import readline
import time
import json
import sys
import random
import difflib
import hashlib

from pynput import keyboard

from mutagen.mp3 import MP3
from playsound import playsound
from prompt_toolkit import prompt

class Global():
	def __init__(self):
		self.start_time = 0.0

def evaluate(clips, output_file='output.log', max_clips=10, oracle=False):
	gs = Global()

	def on_press(key):
		if gs.start_time == 0.0:
			gs.start_time = time.time()
		if key == keyboard.Key.tab:
			playsound(current_audio)
			return
		else:
			return key

	print('      ------------------------------------------------------', file=sys.stderr)
	print('      TAB: play clip; ENTER: submit transcription', file=sys.stderr)
	print('      CTRL+A: beginning of sentence; CTRL+E: end of sentence', file=sys.stderr)
	print('      CTRL+LEFT: skip word left; CTRL+RIGHT: skip word right', file=sys.stderr)
	print('      ------------------------------------------------------', file=sys.stderr)
	print('      ', file=sys.stderr)

	MAXCLIPS = max_clips
	responses = []
	qs = [0 for i in range(0, MAXCLIPS)] + [1 for i in range(0, MAXCLIPS)]
	random.shuffle(qs)
	current_audio = ''

	listener = keyboard.Listener(on_press=on_press)
	listener.start()


	for (i, tipus) in enumerate(qs):
		clip = clips[i]
		gs.start_time = 0.0

		current_audio = './clips/' + clip['wav_filename'].split('/')[-1]
		current_audio = current_audio.replace('.wav','.mp3')

		afd = open(current_audio, "rb")
		audio = MP3(afd)
		afd.close()
		audio_length = audio.info.length


		
		if oracle:
			print('[' + str(i+1).zfill(3) + '] ' + clip['src'])
		else:
			print('[' + str(i+1).zfill(3) + '] ')

		clue = ""
		if tipus == 0:
			clue = clip['res']

		user_answer = prompt(">     ", default=clue)
		end_time = time.time()

		clip['hash'] = hashlib.sha256(clip['src'].encode("utf-8")).hexdigest()
		clip['type'] = tipus
		clip['audio_length'] = audio_length
		clip['start_time'] = gs.start_time
		clip['end_time'] = end_time 
		clip['edit_time'] = end_time - gs.start_time 
		clip['edit_time_norm'] = end_time - gs.start_time 
		if clip['edit_time_norm'] < clip['audio_length']:
			clip['edit_time_norm'] = clip['audio_length']
		clip['edit_ratio'] = (audio_length + clip['edit_time']) / audio_length
		print('%s\t%.4f\t%.4f\t%d\t%.4f\t%.4f\t%.4f\t%.4f' % 
			(clip['hash'], clip['cer'], clip['wer'], clip['type'], clip['audio_length'], clip['edit_time'], clip['edit_time_norm'], clip['edit_ratio']),
			file=output_file)
		responses.append(clip)

		if tipus == 0:
			differences = difflib.ndiff(clip['res'].split(' '), clip['src'].split(' '))
			scr = ''
			for d in differences:
				if d.strip()[0] == '-' or d.strip()[0] == '+':
					scr += ' [' + d.strip() + ']'
				else:
					scr += ' ' + d.strip()
#			print('      ' + scr.strip())

		if oracle:
			print('[%s] %.2f ~ %.2f' % (str(i+1).zfill(3), audio_length, end_time - gs.start_time))
		else:
			print('[%s] %.2f ~ %.2f | %s' % (str(i+1).zfill(3), audio_length, end_time - gs.start_time, clip['src']))
		print()

	output_file.close()

	for clip in responses:
		# ({'wav_filename': 'common_voice_pt_19347423.wav', 'src': 'uma vez por todas', 'res': 'uma vez por todas', 
		#   'loss': 13.21805191040039, 'char_distance': 0, 'char_length': 17, 'word_distance': 0, 
		#   'word_length': 4, 'cer': 0.0, 'wer': 0.0}, 1, 2, 3.58, 1619483553.10, 1619483556.69)
		print('%s\t%.4f\t%.4f\t%d\t%.4f\t%.4f\t%.4f\t%.4f' % 
			(clip['hash'], clip['cer'], clip['wer'], clip['type'], clip['audio_length'], clip['edit_time'], clip['edit_time_norm'], clip['edit_ratio']))
		#print(response)


def main():

	output_fd = open(sys.argv[1].replace('.json', '.log'), 'w')

	fd = open(sys.argv[1])
	tst = json.load(fd)

	random.seed(10)
	random.shuffle(tst)
	random.seed()

	evaluate(tst, output_file=output_fd, max_clips=2, oracle=False)
	
main()
