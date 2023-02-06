### STAGE 1:BUILD ###
# Defining a node image to be used as giving it an alias of "build"
# Which version of Node image to use depends on project dependencies 
# This is needed to build and compile our code 
# while generating the docker image
FROM node:14.21.2-alpine AS build
# Create a Virtual directory inside the docker image
WORKDIR /dist/src/app
# Copy files to virtual directory
# COPY package.json package-lock.json ./
# Run command in Virtual directory
RUN npm cache clean --force
# Copy files from local machine to virtual directory in docker image
COPY . .
RUN npm install
RUN npm run build --prod


### STAGE 2:RUN ###
# Defining nginx image to be used
# FROM nginx:stable AS ngi
FROM nginx:1.21.6 AS ngi
RUN apt-get update && apt-get upgrade -y && apt-get clean

# Copying compiled code and nginx config to different folder
# NOTE: This path may change according to your project's output folder 
COPY --from=build /dist/src/app/dist/realm12 /usr/share/nginx/html
COPY ./nginx/default.conf  /etc/nginx/conf.d/default.conf
RUN touch /var/run/nginx.pid
RUN chmod  g+rwx /var/cache/nginx /var/run /var/log/nginx /var/run/nginx.pid 
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
# Exposing a port, here it means that inside the container 
# the app will be using Port 80 while running
EXPOSE 8024
