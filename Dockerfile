###############################################
### DOCKER FILE for FRAN'S CRAZY COMMON VOICE SPRINT ###
###############################################

# Please refer to the TRAINING documentation, "Basic Dockerfile for training"

FROM tensorflow/tensorflow:1.15.4-gpu-py3
ENV DEBIAN_FRONTEND=noninteractive

### INSTALL SYSTEMWIDE STT DEPS
##
#
RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-utils \
        bash-completion \
        build-essential \
        cmake \
        curl \
        git \
        libboost-all-dev \
        libbz2-dev \
        locales \
        vim \
        nano \
        python3-venv \
        unzip \
        wget
# We need to remove it because it's breaking STT install later with
# weird errors about setuptools
RUN apt-get purge -y python3-xdg
# Install dependencies for audio augmentation
RUN apt-get install -y --no-install-recommends libopus0 libsndfile1
# Try and free some space
RUN rm -rf /var/lib/apt/lists/*

### WGET ASSETS
##
#
# wget checkpoints

WORKDIR /

ADD coqui-stt-0.9.3-checkpoint.tar.gz /
ADD convert_graphdef_memmapped_format.linux.amd64.zip /
ADD native_client.amd64.cuda.linux.tar.xz /

RUN ls /

#RUN tar -xzvf /coqui-stt-0.9.3-checkpoint.tar.gz
RUN unzip /convert_graphdef_memmapped_format.linux.amd64.zip
#RUN tar -xJvf /native_client.amd64.cuda.linux.tar.xz

#RUN wget https://github.com/coqui-ai/STT/releases/download/v0.9.3/coqui-stt-0.9.3-checkpoint.tar.gz && tar -xzvf coqui-stt-0.9.3-checkpoint.tar.gz
#RUN wget https://github.com/coqui-ai/STT/releases/download/v0.9.3/convert_graphdef_memmapped_format.linux.amd64.zip && unzip convert_graphdef_memmapped_format.linux.amd64.zip
# wget native_client (for generate_scorer_package) 
#RUN wget https://github.com/mozilla/DeepSpeech/releases/download/v0.9.3/native_client.amd64.cuda.linux.tar.xz && tar -xJvf native_client.amd64.cuda.linux.tar.xz
# Covo tools for doing transcript processing and alphabet stuff

RUN pip install git+https://github.com/ftyers/commonvoice-utils.git

### CLONE and INSTALL STT
##
#
ENV STT_REPO=https://github.com/coqui-ai/STT.git
ENV STT_SHA=f2e9c85880dff94115ab510cde9ca4af7ee51c19
WORKDIR /
RUN git clone $STT_REPO STT
WORKDIR /STT
RUN git checkout $STT_SHA
# Build CTC decoder first, to avoid clashes on incompatible versions upgrades
RUN cd native_client/ctcdecode && make NUM_PROCESSES=$(nproc) bindings
RUN pip3 install --upgrade native_client/ctcdecode/dist/*.whl
# Prepare deps
RUN pip3 install --upgrade pip==20.2.2 wheel==0.34.2 setuptools==49.6.0
# Install STT
#  - No need for the decoder since we did it earlier
#  - There is already correct TensorFlow GPU installed on the base image,
#    we don't want to break that
RUN DS_NODECODER=y DS_NOTENSORFLOW=y pip3 install --upgrade -e .

ADD kenlm /STT/kenlm/

# Build KenLM to generate new scorers
WORKDIR /STT/native_client

#RUN rm -rf kenlm && \
#        git clone https://github.com/kpu/kenlm && \
#        cd kenlm && \
#        git checkout 87e85e66c99ceff1fab2500a7c60c01da7315eec && \
#        mkdir -p build && \
#        cd build && \
#        cmake .. && \
#        make -j $(nproc)
WORKDIR /STT

#################################
### BEGIN LANGUAGE-SPECFIC TRAINING ###
#################################

WORKDIR /

# move all bash scripts to /
ADD train.sh /
ADD test.sh /
ADD export.sh /
ADD lm.sh /
ADD importers.py /
ADD import_cv2.py /
ADD config /

# Monkey patched versions of import_cv2 and imports.py including Covo
RUN mv /import_cv2.py /STT/bin/import_cv2.py

RUN find /STT/training

RUN mv /importers.py /STT/training/deepspeech_training/util/importers.py

# assumes the user has mounted the docker image with language tarballs under /mnt
#RUN tar -xzf /mnt/$LLENGUA.tar.gz --directory /media

#RUN python bin/import_cv2.py --validate_label_locale $LLENGUA /media/cv-corpus-6.1-2020-12-11/$LLENGUA/

###

RUN mkdir /logs

#RUN /bin/bash -x /train.sh >/logs/train.log 2>&1 
#RUN /bin/bash -x /test.sh >/logs/test.log 2>&1 
#RUN /bin/bash -x /lm.sh >/logs/lm.log 2>&1 
#RUN /bin/bash -x /export.sh > /logs/export.log 2>&1

ENTRYPOINT ["bash" , "source /config && tar -xzf /mnt/$LLENGUA.tar.gz --directory /media && python /STT/bin/import_cv2.py --validate_label_locale $LLENGUA /media/cv-corpus-6.1-2020-12-11/$LLENGUA/ && /bin/bash -x /train.sh >/logs/train.log 2>&1"]
