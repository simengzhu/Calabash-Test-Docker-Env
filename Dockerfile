# Use an official Ruby runtime as parent image
FROM ruby:2.3-slim

# Set the working directory to ~/work
WORKDIR /~/work

# Copy the current directory contents into the container at /app
ADD . /~/work

# Install dependencies for the Calabash tests
# Dependencies pt.1: install ruby gems
RUN gem install bundler
RUN apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/*
RUN sudo apt-get update
RUN sudo apt-get install -y gcc
RUN apt-get install --reinstall make
RUN bundle install

# Dependencies pt.2: install Java and openjdk
RUN sudo apt-get install -y default-jdk

# Dependencies pt.3: install Android sdk and platform tools
RUN apt-get install -y wget
RUN wget -P /usr/lib/android-sdk/ https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN apt-get install unzip
RUN unzip /usr/lib/android-sdk/sdk-tools-linux-4333796.zip -d /usr/lib/android-sdk/
RUN rm /usr/lib/android-sdk/sdk-tools-linux-4333796.zip
RUN /usr/lib/android-sdk/tools/bin/sdkmanager --update
RUN yes | /usr/lib/android-sdk/tools/bin/sdkmanager "platform-tools" "platforms;android-24" "build-tools;24.0.3" "extras;google;m2repository" "extras;android;m2repository"
RUN keytool -genkey -noprompt \
 -alias calabashtestkeystore \
 -dname "CN=tester, OU=epassimob, O=epassi, L=Helsinki, S=Finland, C=FI" \
 -keystore keystore \
 -storepass storepassword \
 -keypass keypassword
ENV ANDROID_HOME=/usr/lib/android-sdk/
ENV PATH=$PATH:$ANDROID_HOME/tools/:$ANDROID_HOME/platform-tools/

# Create the /work folder
RUN mkdir ~/work

# Make port 80 available to the world outside this container
EXPOSE 80