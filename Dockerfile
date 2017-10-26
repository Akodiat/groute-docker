# Use cuda image as base image
FROM nvidia/cuda:9.0-devel

RUN apt-get update
RUN echo "yes" | apt-get install git
RUN echo "yes" | apt-get install cmake
RUN apt-get install wget
RUN apt-get install unzip

# Get Groute
RUN cd /usr/src/ && git clone https://github.com/groute/groute.git

# Clone dependencies --recursive not working, invalid cub commit
COPY deps /usr/src/groute/deps

# Download & extract metis
RUN cd /usr/src/groute \
    && wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz \
    && tar xf metis-5.1.0.tar.gz \
    && mv metis-5.1.0 metis \
    && rm -f metis-5.1.0.tar.gz \
    && sed -i 's/IDXTYPEWIDTH 32/IDXTYPEWIDTH 64/g' metis/include/metis.h

# Build metis
RUN cd /usr/src/groute/metis \
    && make config BUILDDIR=build \
    && cd build && make -j8

# Build Groute
RUN cd /usr/src/groute && mkdir build && cd build && cmake  .. && make -j8
